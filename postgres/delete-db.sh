#! /bin/bash

kubectl delete -f cronjob.yaml
kubectl delete -f rucio-db-mirror-v1.yaml
# kubectl delete -f storage.yaml
kubectl delete -f init-pod.yaml
