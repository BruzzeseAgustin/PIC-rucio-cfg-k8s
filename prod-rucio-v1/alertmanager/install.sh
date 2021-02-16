#! /bin/bash 

kubectl create -f alertmanager-config.yaml

kubectl create -f alertmanager-deployment.yaml 

kubectl create -f alertmanager-service.yaml

kubectl create -f alertmanager-template.yaml
