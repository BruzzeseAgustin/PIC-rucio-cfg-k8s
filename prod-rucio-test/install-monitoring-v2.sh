#! /bin/bash

# Please read https://www.metricfire.com/blog/how-to-deploy-prometheus-on-kubernetes/?GAID=1189927494.1610920465

# kubectl apply -f prometheus/monitoring-namespace.yaml

kubectl create -f prometheus/namespace.yaml
kubectl create -f prometheus/prometheus-role.yaml
kubectl create -f prometheus/prometheus-config.yaml
kubectl create -f prometheus/prometheus-deployment.yaml
kubectl create -f prometheus/grafana-config.yaml
kubectl create -f prometheus/grafana-deployment.yaml
kubectl create -f prometheus/grafana-service.yaml


# There’s one thing left to do before we can start looking at our metrics in Prometheus.
# At the moment we don’t have access to Prometheus, since it’s running in a cluster. 
# We can set up a service called a NodePort which will allow access to prometheus
# via the node IP address. 

kubectl apply -f prometheus/node-exporter-daemonset.yaml


