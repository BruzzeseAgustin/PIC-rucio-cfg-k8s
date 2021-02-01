#! /bin/bash 

kubectl delete -f prometheus/prometheus-roles.yaml
kubectl delete -f prometheus/prometheus-config.yaml

kubectl delete -f prometheus/prometheus-config2.yaml


kubectl delete -f prometheus/prometheus-deployment.yaml
kubectl delete -f prometheus/prometheus-nodeservice.yaml
kubectl delete -f prometheus/node-exporter-daemonset.yaml
kubectl delete -f prometheus/prometheus-config.yaml
kubectl delete -f prometheus/prometheus-roles.yaml
kubectl delete -f prometheus/grafana-config.yaml
kubectl delete -f prometheus/grafana-deployment.yaml
kubectl delete -f prometheus/grafana-service.yaml

