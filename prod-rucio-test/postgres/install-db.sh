#! /bin/bash 


kubectl	apply -k ./
kubectl apply -f storage.yaml
# kubectl apply -f init-pod.yaml
