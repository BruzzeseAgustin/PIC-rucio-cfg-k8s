#! /bin/bash

kubectl delete -f alertmanager-config.yaml 
kubectl delete -f alertmanager-deployment.yaml 
kubectl delete -f alertmanager-service.yaml 
kubectl delete -f alertmanager-template.yaml 
