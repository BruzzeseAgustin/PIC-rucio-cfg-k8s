#! /bin/bash

kubectl delete -f postgres/cronjob.yaml
kubectl delete -f postgres/deployment.yaml
kubectl delete -f postgres/service.yaml
kubectl delete -f postgres/storage.yaml
kubectl delete -f postgres/init-pod.yaml
