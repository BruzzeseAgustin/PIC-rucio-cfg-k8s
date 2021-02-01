#! /bin/bash 


kubectl	apply -k ./postgres/
kubectl apply -f ./postgres/storage.yaml
# kubectl apply -f ./postgres/init-pod.yaml
