# Usage:
# make        # compile all binary

# You can change the default config with `make cnf="config_special.env" build`
ver ?= deploy.env
include $(ver)
export $(shell sed 's/=.*//' $(ver))

get_magic: read_variables # Download magic's configuracion file
	wget -O $(shell pwd)/config.env https://gitlab.pic.es/bruzzese/pic-rucio-cfg-k8s/-/raw/main/config.env
	
get_icfo: read_variables # Download icfo's configuracion file
	wget -O $(shell pwd)/config.env https://gitlab.pic.es/bruzzese/pic-rucio-cfg-k8s-icfo/-/raw/icfo-v1.0.0/config.env
	
get_cta: read_variables # Download cta's configuracion file
	wget -O $(shell pwd)/config.env https://gitlab.pic.es/bruzzese/pic-rucio-cfg-k8s-cta/-/raw/cta-v1.0.0/config.env

cnf ?= config.env
include $(cnf)
export $(shell sed 's/=.*//' $(cnf))
	
DOCKER_TRACK_BUILD := | while read line ; do echo "$(shell date)| $$line" | tee -a $(shell pwd)/docker/docker-build.txt ; done;


# HELP
# This will output the help for each task
# thanks to https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
.PHONY: help

# If you're using GNU make, this is easy to do. The only problem is that make will interpret non-option arguments in the command line as targets. The solution is to turn them into do-nothing targets, so make won't complain:
# If the first argument is "run"...
ifeq (hdp,$(firstword $(MAKECMDGOALS)))
  # use the rest as arguments for "run"
  RUN_ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
  # ...and turn them into do-nothing targets
  $(eval $(RUN_ARGS):;@:)
endif


help: ## This help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

ccyellow = $(shell echo "\033[33m")
ccend = $(shell tput op)
notice = $(ccyellow) $(0) $(ccend)

_path := $(shell pwd)
_user := hdp_usr
	
.DEFAULT_GOAL := help
.SILENT: #don't echo commands as we run them.

all: clean clean_img download_untar build run


base:
	rm -rf $(shell pwd)/config/docker/proxy
	mkdir -pv $(shell pwd)/config/docker/proxy
	chmod 777 $(shell pwd)/config/docker/proxy
	rm -rf $(shell pwd)/config/docker/certs
	mkdir -pv $(shell pwd)/config/docker/certs
	chmod 777 $(shell pwd)/config/docker/certs

read_variables:
	# include $(config.env)
	export $(shell sed 's/=.*//' config.env)
			
clean: base ## Remove and create result's folders

	rm -rf dfs-$(shell hostname)
# DEPENDENCIES
helm_install:
	curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
	chmod 700 get_helm.sh
	./get_helm.sh
	helm repo add rucio https://rucio.github.io/helm-charts
	
helm_update: ## Download dependencies for helm rucio 
	helm repo update rucio	
	
download_untar: read_variables ## Download dependencies for rucio services
	@echo
	@echo "$(ccyellow)> Download dependencies for rucio services at $(shell pwd)$(ccend)"
	# Create folder with containing hadoop dependencies
	
	# Get by URLS & Untar all tar services  
	helm pull rucio/rucio-daemons --version $(DAEMON_HELM_VERSION) --untar --untardir $(shell pwd)/dependencies/
	
	cp -f $(shell pwd)/dependencies/rucio-daemons/templates/reaper.yaml $(shell pwd)/dependencies/rucio-daemons/templates/reaper2.yaml 
	
	sed -i 's/reaper/reaper2/g' $(shell pwd)/dependencies/rucio-daemons/templates/reaper2.yaml 
	
	helm pull rucio/rucio-server --version $(SERVER_HELM_VERSION) --untar --untardir $(shell pwd)/dependencies/
	
	cp -f $(shell pwd)/dependencies/ingress-templates/ingress.yaml.server $(shell pwd)/dependencies/rucio-server/templates/ingress.yaml	
	cp -f $(shell pwd)/dependencies/ingress-templates/auth_ingress.yaml.server $(shell pwd)/dependencies/rucio-server/templates/auth_ingress.yaml	

	sed -i 's/v1beta1/v1/g' $(shell pwd)/dependencies/rucio-server/templates/renew-fts-cronjob.yaml 	
	sed -i 's/v1beta1/v1/g' $(shell pwd)/dependencies/rucio-server/templates/automatic-restart-cronjob.yaml
		
	helm pull rucio/rucio-ui --version $(UI_HELM_VERSION) --untar --untardir $(shell pwd)/dependencies/
	cp -f $(shell pwd)/dependencies/ingress-templates/ingress.yaml.ui $(shell pwd)/dependencies/rucio-ui/templates/ingress.yaml
		
rucio_client:
	# ensure you have install glib-2.0 
	
	pip install virtualenv
	virtualenv rucio

	envsubst < $(shell pwd)/config/rucio-cfg/rucio.cfg.client > $(shell pwd)/rucio/etc/rucio.cfg
	. rucio/bin/activate; pip install -U pip cmake 
	. rucio/bin/activate; pip install -Iv rucio-clients==$(CLIENT_VERSION)
	. rucio/bin/activate; pip install -Iv gfal2-python
	
	export RUCIO_HOME=`pwd`/rucio/
		
# DOCKER TASKS
# Build the container
build: read_variables ## Build the Certs and Proxy container 
	export $(shell sed 's/=.*//' config.env)
	echo 'y' | docker system prune; 
	echo 'y' | docker image prune -a; 
	
	rm -rf $(shell pwd)/config/docker/certs 
	rm -rf $(shell pwd)/config/docker/proxy
	
	if [ ! -d $(shell pwd)/config/docker/certs ]; then \
	  mkdir -p $(shell pwd)/config/docker/certs; \
	fi
	
	if [ ! -d $(shell pwd)/config/docker/proxy ]; then \
	  mkdir -p $(shell pwd)/config/docker/proxy; \
	fi
	
	
	docker build --no-cache -f $(shell pwd)/config/docker/Dockerfile -t proxy-renew:1.0.0 $(shell pwd)/config/docker

	@echo
	@echo "$(ccyellow)> Setup PIC certs and proxy docker image $(ccend)"
	@echo

	docker run --net=host \
		--privileged=true \
		-h $(shell hostname) \
		--name proxy-renew \
		-v $(shell pwd)/$(DIR_CERTS)/hostcert.pem:/tmp/robotcert.pem \
		-v $(shell pwd)/$(DIR_CERTS)/hostkey.pem:/tmp/robotkey.pem \
		-v $(shell pwd)/config/docker/certs:/tmp/certs \
		-v $(shell pwd)/config/docker/proxy:/tmp/proxy \
		proxy-renew:1.0.0
	
	sleep 5 
	@echo finished 	
	
run_setup: read_variables ## Run container with the variables placed at `config.env`, and generate configured files based on the files provided
	export $(shell sed 's/=.*//' config.env)
	$(shell pwd)/config/rucio-scripts/create_secret.sh 
	envsubst < $(shell pwd)/config/rucio-yamls/rucio-client.yaml | kubectl create -f - &
	envsubst < $(shell pwd)/config/rucio-db/rucio-db.yaml | kubectl create -f - &
	envsubst < $(shell pwd)/config/rucio-db/rucio-init.yaml | kubectl create -f - &
	envsubst < $(shell pwd)/config/rucio-yamls/rucio-cronjobs.yaml | kubectl create -f - &
	envsubst < $(shell pwd)/config/rucio-yamls/rucio-fts.yaml | kubectl create -f - &
		
run_start: read_variables ## Run container with the variables placed at `config.env`, and generate configured files based on the files provided
	export $(shell sed 's/=.*//' config.env)
	
	envsubst < $(shell pwd)/config/rucio-yamls/rucio-server.yaml | helm upgrade --install $(RELEASE_NAME)-server $(shell pwd)/dependencies/rucio-server -f -
	envsubst < $(shell pwd)/config/rucio-yamls/rucio-daemons.yaml | helm upgrade --install $(RELEASE_NAME)-daemons $(shell pwd)/dependencies/rucio-daemons -f -
	envsubst < $(shell pwd)/config/rucio-yamls/rucio-ui.yaml | helm upgrade --install $(RELEASE_NAME)-ui $(shell pwd)/dependencies/rucio-ui -f -
	
	envsubst < $(shell pwd)/config/rucio-yamls/rucio-ui-nodeport.yaml | kubectl create -f -
	kubectl create -f $(shell pwd)/config/rucio-yamls/rucio-client.yaml
	
run_update: read_variables ## Run container with the variables placed at `config.env`, and generate configured files based on the files provided
	export $(shell sed 's/=.*//' config.env)
	$(shell pwd)/config/rucio-scripts/delete_secret.sh
	$(shell pwd)/config/rucio-scripts/create_secret.sh 
	envsubst < $(shell pwd)/config/rucio-yamls/rucio-server.yaml | helm upgrade --install $(RELEASE_NAME)-server $(shell pwd)/dependencies/rucio-server -f - &
	envsubst < $(shell pwd)/config/rucio-yamls/rucio-daemons.yaml | helm upgrade --install $(RELEASE_NAME)-daemons $(shell pwd)/dependencies/rucio-daemons -f - &
	envsubst < $(shell pwd)/config/rucio-yamls/rucio-ui.yaml | helm upgrade --install $(RELEASE_NAME)-ui $(shell pwd)/dependencies/rucio-ui -f - &

run_clean: read_variables ## Run container with the variables placed at `config.env`, and generate configured files based on the files provided
	export $(shell sed 's/=.*//' config.env)	
	helm delete $(RELEASE_NAME)-server 	
	helm delete $(RELEASE_NAME)-daemons
	helm delete $(RELEASE_NAME)-ui
	kubectl delete -f $(shell pwd)/config/rucio-yamls/rucio-ui-nodeport.yaml 
	
		
uninstall: 
	export $(shell sed 's/=.*//' config.env)
	# Delete dependencies
	rm -rf $(shell pwd)/dependencies/rucio-daemons &
	rm -rf $(shell pwd)/dependencies/rucio-server &
	rm -rf $(shell pwd)/dependencies/rucio-ui &
	$(shell pwd)/config/rucio-scripts/delete_secret.sh &
	rm -rf $(shell pwd)/config/docker/certs &
	rm -rf $(shell pwd)/config/docker/proxy & 
	
	# Delete rucio server, demons, and ui
	helm delete $(RELEASE_NAME)-server &	
	helm delete $(RELEASE_NAME)-daemons &
	helm delete $(RELEASE_NAME)-ui &
	kubectl delete -f $(shell pwd)/config/rucio-yamls/rucio-ui-nodeport.yaml &
	
	# Delete DB deployment
	envsubst < $(shell pwd)/config/rucio-db/rucio-db.yaml | kubectl delete -f -	&
	envsubst < $(shell pwd)/config/rucio-db/rucio-init.yaml | kubectl delete -f - &
	kubectl delete -f $(shell pwd)/config/rucio-yamls/rucio-client.yaml &
	envsubst < $(shell pwd)/config/rucio-yamls/rucio-cronjobs.yaml | kubectl delete -f - &
	envsubst < $(shell pwd)/config/rucio-yamls/rucio-fts.yaml | kubectl delete -f - &	
	
test: # test
	envsubst < $(shell pwd)/config/rucio-yamls/rucio-cronjobs.yaml | kubectl create -f - &
