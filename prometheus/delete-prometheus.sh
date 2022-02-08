#! /bin/bash 

kubectl delete -f prometheus-deployment.yaml
kubectl delete -f node-exporter-daemonset.yaml
kubectl delete -f prometheus-config.yaml
kubectl delete -f prometheus-roles.yaml


