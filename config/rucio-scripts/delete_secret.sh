#!/bin/bash

source /$(pwd)/config.env

export DAEMON_NAME=$RELEASE_NAME-daemons
export SERVER_NAME=$RELEASE_NAME-server
export UI_NAME=$RELEASE_NAME-ui
export DIR_CERTS=certs-k8s


echo "Removing existing secrets"

kubectl delete secret rucio-server.tls-secret

kubectl delete secret ${SERVER_NAME}-server-hostcert
kubectl delete secret ${SERVER_NAME}-server-hostkey
kubectl delete secret ${SERVER_NAME}-cafile
kubectl delete secret ${SERVER_NAME}-hostcert
kubectl delete secret ${SERVER_NAME}-hostkey
kubectl delete secret ${SERVER_NAME}-auth-hostcert
kubectl delete secret ${SERVER_NAME}-auth-hostkey
kubectl delete secret ${SERVER_NAME}-auth-cafile
kubectl delete secret ${SERVER_NAME}-rucio-x509up
kubectl delete secret ${SERVER_NAME}-certs
kubectl delete secret ${SERVER_NAME}-rucio-cfg
kubectl delete secret ${SERVER_NAME}-rucio-ca-bundle-reaper 
kubectl delete secret ${SERVER_NAME}-rucio-ca-bundle 
kubectl delete secret ${SERVER_NAME}-permission  
kubectl delete secret ${SERVER_NAME}-schema  
kubectl delete secret ${SERVER_NAME}-mail-templates  


kubectl delete secret ${DAEMON_NAME}-fts-cert
kubectl delete secret ${DAEMON_NAME}-fts-key
kubectl delete secret ${DAEMON_NAME}-fts-x509up
kubectl delete secret ${DAEMON_NAME}-hermes-cert
kubectl delete secret ${DAEMON_NAME}-hermes-key
kubectl delete secret ${DAEMON_NAME}-hermes-x509up
kubectl delete secret ${DAEMON_NAME}-rucio-ca-bundle 
kubectl delete secret ${DAEMON_NAME}-hermes2-script
kubectl delete secret ${DAEMON_NAME}-rucio-x509up 
kubectl delete secret ${DAEMON_NAME}-rucio-x509up-reaper
kubectl delete secret ruciod-release-rucio-x509up 
kubectl delete secret ${DAEMON_NAME}-rucio-cfg 
kubectl delete secret ${DAEMON_NAME}-hermes2-script 
kubectl delete secret ${DAEMON_NAME}-rucio-ca-bundle-reaper 
kubectl delete secret ${DAEMON_NAME}-rucio-ca-bundle-reaper2

kubectl delete secret ${UI_NAME}-certs 
kubectl delete secret ${UI_NAME}-test-certs
kubectl delete secret ${UI_NAME}-hostcert 
kubectl delete secret ${UI_NAME}-hostkey  
kubectl delete secret ${UI_NAME}-cafile  
kubectl delete secret ${UI_NAME}-permission  
kubectl delete secret ${UI_NAME}-schema  
kubectl delete secret ${UI_NAME}-base 
kubectl delete secret ${UI_NAME}-rucio  
kubectl delete secret ${UI_NAME}-web-ui 

