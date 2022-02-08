#! /bin/bash 

kubectl create -f prometheus-deployment.yaml
kubectl create -f prometheus-config.yaml
kubectl create -f prometheus-roles.yaml
# kubectl create -f node-exporter-daemonset.yaml
