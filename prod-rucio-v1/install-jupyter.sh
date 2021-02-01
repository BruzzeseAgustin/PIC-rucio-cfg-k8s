#! /bin/bash

# yaml of reference https://github.com/jupyterhub/zero-to-jupyterhub-k8s/blob/master/jupyterhub/schema.yaml

# Please read https://zero-to-jupyterhub.readthedocs.io/en/latest/jupyterhub/installation.html

# helm repo add stable https://kubernetes-charts.storage.googleapis.com/
# helm repo update 

# Suggested values: advanced users of Kubernetes and Helm should feel
# free to use different values.
RELEASE=jhub
NAMESPACE=jhub

kubectl create -f jupyter-rucio/postgres-configmap.yaml 

kubectl create -f jupyter-rucio/postgres-storage.yaml

kubectl create -f jupyter-rucio/postgres-deployment.yaml 

kubectl create -f jupyter-rucio/postgres-service.yaml

helm upgrade --cleanup-on-fail \
  --install $RELEASE jupyterhub/jupyterhub \
  --namespace $NAMESPACE \
  --create-namespace \
  --version=0.10.6 \
  --values jupyter-rucio/config.yaml

# kubectl get pod --namespace jupyther

# kubectl config set-context $(kubectl config current-context) --namespace ${NAMESPACE:-jupyther}

# kubectl get service --namespace jupyther

# kubectl describe service proxy-public --namespace jupyther

# helm repo add bitnami https://charts.bitnami.com/bitnami
# helm repo update
# helm upgrade --install pgdatabase --namespace $RELEASE bitnami/postgresql \
# --set postgresqlDatabase=jhubdb \
# --set postgresqlPassword=postgres
