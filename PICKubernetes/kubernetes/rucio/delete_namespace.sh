#! /bin/sh

# This script expects that you have installed your own helm executable. No installation of helm into kubernetes is required

export NAMESPACE=prod-rucio-test

kubectl delete namespaces $NAMESPACE

kubectl get -A namespaces
