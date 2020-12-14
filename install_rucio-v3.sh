#! /bin/sh

# This script expects that you have installed your own helm executable. No installation of helm into kubernetes is required

kubectl create namespace prod-rucio-test
kubectl config set-context --current --namespace=prod-rucio-test

read -p "Do you want to delete your current server display? " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
    helm delete pic01
    helm delete daemons 
fi

./create_secret.sh

helm install postgres bitnami/postgresql -f postgres_values.yaml
PSQL_POD=$(kubectl get pods postgres-postgresql-0 -n prod-rucio-test | grep "Running" | awk '{print $3}')

while [[ $PSQL_POD != "Running" ]]; do
  echo 'Wait until the postgres db pod iniciates...' && PSQL_POD=$(kubectl get pods postgres-postgresql-0 -n prod-rucio-test | grep "Running" | awk '{print $3}') && CR_STATE=$(kubectl get pods postgres-postgresql-0 -n prod-rucio-test | awk '{print $3}') && echo "Current state is $CR_STATE" && sleep 1;
done


helm install pic01 rucio/rucio-server -f server-v2.yaml
helm install daemons rucio/rucio-daemons -f daemons.yaml
kubectl create job renew-manual-1 --from=cronjob/daemons-renew-fts-proxy

git clone https://github.com/pic-es/cronjobs.git
kubectl create -f cronjobs/fts-renew/kubernetes/deployment.yaml
kubectl create -f cronjobs/rucio-pic-admin/kubernetes/deployment.yaml


# Run other post-deployment tasks, now that all new Pods are present, and old ones are gone.
kubectl apply -f init-pod.yaml
INIT_POD=$(kubectl get pods test-init -n prod-rucio-test | grep "Completed" | awk '{print $3}')

while [[ $INIT_POD != "Completed" ]]; do 
  echo 'Iniciating rucio db with basic user...' && INIT_POD=$(kubectl get pods test-init -n prod-rucio-test | grep "Completed" | awk '{print $3}')  && CR_STATE=$(kubectl get pods test-init -n prod-rucio-test | awk '{print $3}') && echo "Current state is $CR_STATE" && sleep 1;
done

kubectl create -f cronjobs/rucio-sync-rses/kubernetes/deployment.yaml 
kubectl create -f cronjobs/rucio-sync-clients/kubernetes/deployment.yaml
