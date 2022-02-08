#! /bin/bash

kubectl delete -f postgres/cronjob.yaml
kubectl delete -f postgres/rucio-db.yaml
kubectl delete -f postgres/storage.yaml
kubectl delete -f postgres/init-pod.yaml
kubectl delete -f cronjobs/rucio-sync-rses/kubernetes/deployment.yaml 
kubectl delete -f cronjobs/rucio-sync-clients/kubernetes/deployment.yaml
