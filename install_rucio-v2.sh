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

# kubectl apply -f init-pod.yaml

helm install pic01 rucio/rucio-server -f server-v2.yaml
helm install daemons rucio/rucio-daemons -f daemons.yaml

kubectl create job renew-manual-1 --from=cronjob/daemons-renew-fts-proxy

kubectl apply -f init-pod.yaml

git clone https://github.com/pic-es/cronjobs.git
kubectl create -f cronjobs/fts-renew/kubernetes/deployment.yaml
kubectl create -f cronjobs/rucio-client/kubernetes/deployment.yaml
kubectl create -f cronjobs/rucio-sync-rses/kubernetes/deployment.yaml
kubectl create -f cronjobs/rucio-sync-clients/kubernetes/deployment.yaml

