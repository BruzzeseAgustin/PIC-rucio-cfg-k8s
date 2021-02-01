#! /bin/bash

# kubectl create secret generic creds --from-file=rucio-realm.properties -n monitoring
kubectl create secret generic creds --from-file=jetty-realm.properties -n monitoring
kubectl apply -f deployment.yaml
