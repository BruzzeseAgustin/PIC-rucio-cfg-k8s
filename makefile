# Usage:
# make        # compile all binary

# You can change the default config with `make cnf="config_special.env" build`
ver ?= version.env
include $(ver)
export $(shell sed 's/=.*//' $(ver))

cnf ?= config.env
include $(cnf)
export $(shell sed 's/=.*//' $(cnf))

DOCKER_TRACK_BUILD := | while read line ; do echo "$(shell date)| $$line" | tee -a $(shell pwd)/docker/docker-build.txt ; done;
DOCKER_ARG_BUILD := $(shell cat version.env | while read line; do echo "--build-arg $$line"; done;) 

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
	
download_untar: ## Download dependencies for rucio services
	@echo
	@echo "$(ccyellow)> Download dependencies for rucio services at $(shell pwd)$(ccend)"
	# Create folder with containing hadoop dependencies
	mkdir -p dependencies
		
	# Get by URLS & Untar all tar services  
	helm pull rucio/rucio-daemons --version $(DAEMON_HELM_VERSION)

	# This are exclusive tar services when you clone this project
	tar -xvzf rucio-daemons-$(DAEMON_VERSION).tgz -C $(shell pwd)/dependencies/
	rm -rf rucio-daemons-$(DAEMON_VERSION).tgz

rucio_client:
	pip install virtualenv
	virtualenv rucio

	. rucio/bin/activate; pip install -Iv rucio-clients==$(CLIENT_VERSION)

	cp $(shell pwd)/config/rucio-cfg/rucio.cfg.client $(shell pwd)/rucio/etc/rucio.cfg

	export RUCIO_HOME=`pwd`/rucio/
		
versions: ## Show current versions that will be used in the Hadoop image
	cat version.env | while read line; do echo "--build-arg $$line"; done;  

# DOCKER TASKS
# Build the container
build: ## Build the Certs and Proxy container 


	# echo 'y' | docker system prune; 
	# echo 'y' | docker image prune -a; 
	
	docker build --no-cache -f $(shell pwd)/config/docker/Dockerfile -t proxy-renew:1.0.0 $(shell pwd)/config/docker

	@echo
	@echo "$(ccyellow)> Setup PIC certs and proxy docker image $(ccend)"
	@echo

	if [ ! -d $(shell pwd)/certs ]; then \
	  mkdir -p $(shell pwd)/certs; \
	fi
	
	if [ ! -d $(shell pwd)/proxy ]; then \
	  mkdir -p $(shell pwd)/proxy; \
	fi
	
	docker run --rm --net=host \
		--privileged=true \
		-h $(shell hostname) \
		--name proxy-renew \
		-v $(shell pwd)/certs-k8s/hostcert.pem:/tmp/robotcert.pem \
		-v $(shell pwd)/certs-k8s/hostkey.pem:/tmp/robotkey.pem \
		-v $(shell pwd)/config/docker/certs:/tmp/certs \
		-v $(shell pwd)/config/docker/proxy:/tmp/proxy \
		proxy-renew:1.0.0 

run_setup: ## Run container with the variables placed at `config.env`, and generate configured files based on the files provided

	$(shell pwd)/config/rucio-scripts/create_secret.sh

run_start: ## Run container with the variables placed at `config.env`, and generate configured files based on the files provided

	envsubst < $(shell pwd)/config/rucio-yamls/rucio-server.yaml | helm install $(RELEASE_NAME)-server rucio/rucio-server -f -
	envsubst < $(shell pwd)/config/rucio-yamls/rucio-daemons.yaml | helm install $(RELEASE_NAME)-daemons $(shell pwd)/dependencies/rucio-daemons -f -
	envsubst < $(shell pwd)/config/rucio-yamls/rucio-ui.yaml | helm install $(RELEASE_NAME)-ui rucio/rucio-ui -f -
	
	kubectl create -f $(shell pwd)/config/rucio-yamls/rucio-ui-nodeport.yaml
	kubectl create -f $(shell pwd)/config/rucio-yamls/rucio-client.yaml
	
run_clean: ## Run container with the variables placed at `config.env`, and generate configured files based on the files provided
	
	helm delete $(RELEASE_NAME)-server 	
	helm delete $(RELEASE_NAME)-daemons
	helm delete $(RELEASE_NAME)-ui
	kubectl delete -f $(shell pwd)/config/rucio-yamls/rucio-ui-nodeport.yaml 
	
run_update: ## Run container with the variables placed at `config.env`, and generate configured files based on the files provided
	envsubst < $(shell pwd)/config/rucio-yamls/rucio-server.yaml | helm upgrade --install $(RELEASE_NAME)-server rucio/rucio-server -f -
	envsubst < $(shell pwd)/config/rucio-yamls/rucio-daemons.yaml | helm upgrade --install $(RELEASE_NAME)-daemons rucio/rucio-daemons -f -
	envsubst < $(shell pwd)/config/rucio-yamls/rucio-ui.yaml | helm upgrade --install $(RELEASE_NAME)-ui rucio/rucio-ui -f -
