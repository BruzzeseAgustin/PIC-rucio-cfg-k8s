#! /bin/sh

# This script expects that you have installed your own helm executable. No installation of helm into $

kubectl create namespace prod-rucio-test
kubectl config set-context --current --namespace=prod-rucio-test

export ENTITY=pic
export INSTANCE=v1

export SERVER_NAME=pic-rucio-${INSTANCE}
export DAEMON_NAME=pic-daemon-${INSTANCE}
export UI_NAME=pic-webui-${INSTANCE}


helm delete $SERVER_NAME 
helm delete $DAEMON_NAME 
helm delete $UI_NAME 
