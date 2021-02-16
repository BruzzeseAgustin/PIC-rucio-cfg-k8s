#! /bin/bash

kubectl delete -f cronjob.yaml
kubectl delete -f configmap.yaml
kubectl delete -f deployment.yaml
kubectl delete -f service.yaml
kubectl delete -f storage.yaml
kubectl delete -f init-pod.yaml
