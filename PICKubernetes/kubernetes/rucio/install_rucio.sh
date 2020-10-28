#! /bin/sh

# This script expects that you have installed your own helm executable. No installation of helm into kubernetes is required

kubectl create namespace prod-rucio-test
kubectl config set-context --current --namespace=prod-rucio-test

export ENTITY=pic
export INSTANCE=v1

export SERVER_NAME=pic-rucio-${INSTANCE}
export DAEMON_NAME=pic-daemon-${INSTANCE}
export UI_NAME=pic-webui-${INSTANCE}

# Ingress server. With correct labels in create_cluster.sh we should not need this anymore. Commenting out
# helm install stable/nginx-ingress --namespace kube-system --name ingress-nginx --values nginx-ingress.yaml

# Rucio server, daemons, and daemons for analysis

helm install $SERVER_NAME --values pic-rucio-common.yaml,pic-rucio-server.yaml rucio/rucio-server
helm install $DAEMON_NAME --values pic-rucio-common.yaml,pic-rucio-daemons.yaml rucio/rucio-daemons
helm install $UI_NAME --values pic-rucio-common.yaml,pic-rucio-webui.yaml rucio/rucio-ui

