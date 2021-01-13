#! /bin/sh

# This script expects that you have installed your own helm executable. No installation of helm into kubernetes is required
helm repo update

kubectl create namespace prod-rucio-test
kubectl config set-context --current --namespace=prod-rucio-test

kubectl create secret docker-registry regcred --docker-server=my-container-registry-url --docker-username=bruzzese --docker-password=br4912862 --docker-email=bruzzese@pic.es

# Install docker-registry Helm Chart

# Install a helm chart with proper values for proxy cache configuration.

helm repo add twuni https://helm.twun.io

helm install docker-registry twuni/docker-registry --version 1.9.6\
  --values registry-values.yaml

read -p "Do you want to delete your current server display? " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
    helm delete pic01
    helm delete daemons 
    helm delete web

fi

./create_secret.sh

helm install postgres bitnami/postgresql -f postgres_values.yaml
PSQL_POD=$(kubectl get pods postgres-postgresql-0 -n prod-rucio-test | grep "Running" | awk '{print $3}')

while [[ $PSQL_POD != "Running" ]]; do
  echo 'Wait until the postgres db pod iniciates...' && PSQL_POD=$(kubectl get pods postgres-postgresql-0 -n prod-rucio-test | grep "Running" | awk '{print $3}') && CR_STATE=$(kubectl get pods postgres-postgresql-0 -n prod-rucio-test | awk '{print $3}') && echo "Current state is $CR_STATE" && sleep 1;
done


helm install pic01 rucio/rucio-server -f server-v2.yaml
helm install daemons rucio/rucio-daemons -f daemons.yaml
helm install web rucio/rucio-ui -f web-ui.yaml 

kubectl create job renew-manual-1 --from=cronjob/daemons-renew-fts-proxy

# Run other post-deployment tasks, now that all new Pods are present, and old ones are gone.
kubectl apply -f init-pod.yaml
INIT_POD=$(kubectl get pods test-init -n prod-rucio-test | grep "Completed" | awk '{print $3}')

while [[ $INIT_POD != "Completed" ]]; do 
  echo 'Iniciating rucio db with basic user...' && INIT_POD=$(kubectl get pods test-init -n prod-rucio-test | grep "Completed" | awk '{print $3}')  && CR_STATE=$(kubectl get pods test-init -n prod-rucio-test | awk '{print $3}') && echo "Current state is $CR_STATE" && sleep 1;
done

SERVER_POD=$(kubectl get deployment pic01-rucio-server | tail -n +2 | awk '{print $4}')
AUTH_POD=$(kubectl get deployment pic01-rucio-server-auth | tail -n +2 | awk '{print $4}')

while [[ $SERVER_POD == "0" && $AUTH_POD != "1" ]]; do
  echo 'Iniciating rucio server and auth service...' && SERVER_POD=$(kubectl get deployment pic01-rucio-server | tail -n +2 | awk '{print $4}') && AUTH_POD=$(kubectl get deployment pic01-rucio-server-auth | awk '{print $2}') && CR_STATE_S=$(kubectl get deployment pic01-rucio-server | awk '{print $2}') && CR_STATE_A=$(kubectl get deployment pic01-rucio-server-auth | awk '{print $2}') && echo 'Current state is for server and auth are ' $CR_STATE_S $CR_STATE_A ' respecively' && sleep 1;
done

# git clone https://github.com/pic-es/cronjobs.git
kubectl create -f cronjobs/fts-renew/kubernetes/deployment.yaml
kubectl create -f cronjobs/rucio-pic-admin/kubernetes/deployment.yaml
kubectl create -f cronjobs/rucio-sync-rses/kubernetes/deployment.yaml 
kubectl create -f cronjobs/rucio-sync-clients/kubernetes/deployment.yaml

kubectl create configmap prometheus-example-cm --from-file prometheus.yml
