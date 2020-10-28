#!/usr/bin/env bash

# This script will create the various secrets needed by our installation. Before running set the following env variables

kubectl create namespace prod-rucio-test
kubectl config set-context --current --namespace=prod-rucio-test

# INSTANCE  - The instance name (dev/testbed/int/prod)
export INSTANCE=v1
export HOSTP12=/home/bruzzese/host-cert/host.p12 

export DAEMON_NAME=pic-rucio-daemon-${INSTANCE}
export SERVER_NAME=pic-rucio-server-${INSTANCE}
export UI_NAME=pic-rucio-webui-${INSTANCE}

echo

# Setup files so that secrets are unavailable the least amount of time

# Secrets for the auth server

echo "Removing existing secrets"

kubectl delete secret rucio-server.tls-secret
kubectl delete secret ${DAEMON_NAME}-fts-cert ${DAEMON_NAME}-fts-key ${DAEMON_NAME}-hermes-cert ${DAEMON_NAME}-hermes-key 
kubectl delete secret ${DAEMON_NAME}-rucio-ca-bundle ${DAEMON_NAME}-rucio-ca-bundle-reaper
kubectl delete secret ${SERVER_NAME}-hostcert ${SERVER_NAME}-hostkey ${SERVER_NAME}-cafile  
kubectl delete secret ${SERVER_NAME}-auth-hostcert ${SERVER_NAME}-auth-hostkey ${SERVER_NAME}-auth-cafile  
kubectl delete secret ${UI_NAME}-hostcert ${UI_NAME}-hostkey ${UI_NAME}-cafile 

# cms-ruciod-prod-rucio-x509up is created by the FTS key generator

echo "Creating new secrets"
kubectl create secret tls rucio-server.tls-secret --key=tls.key --cert=tls.crt

kubectl create secret generic ${SERVER_NAME}-hostcert --from-file=/home/bruzzese/host-cert/hostcert.pem
kubectl create secret generic ${SERVER_NAME}-hostkey --from-file=/home/bruzzese/host-cert/hostkey.key
kubectl create secret generic ${SERVER_NAME}-cafile  --from-file=/home/bruzzese/host-cert/rucio03_pic_es_interm.cer

kubectl create secret generic ${SERVER_NAME}-auth-hostcert --from-file=/home/bruzzese/host-cert/hostcert.pem
kubectl create secret generic ${SERVER_NAME}-auth-hostkey --from-file=/home/bruzzese/host-cert/hostkey.key
kubectl create secret generic ${SERVER_NAME}-auth-cafile  --from-file=/home/bruzzese/host-cert/rucio03_pic_es_interm.cer

# Make secrets for WEBUI
# We don't make the CA file here, but lower because it is different than the regular server

export UI_NAME=pic-webui-${INSTANCE}
kubectl create secret generic ${UI_NAME}-hostcert --from-file=/home/bruzzese/host-cert/hostcert.pem
kubectl create secret generic ${UI_NAME}-hostkey --from-file=/home/bruzzese/host-cert/hostkey.pem

# Secrets for FTS, hermes

kubectl create secret generic ${DAEMON_NAME}-fts-cert --from-file=/home/bruzzese/host-cert/hostcert.pem
kubectl create secret generic ${DAEMON_NAME}-fts-key --from-file=/home/bruzzese/host-cert/hostkey.key
kubectl create secret generic ${DAEMON_NAME}-hermes-cert --from-file=/home/bruzzese/host-cert/hostcert.pem
kubectl create secret generic ${DAEMON_NAME}-hermes-key --from-file=/home/bruzzese/host-cert/hostkey.key
kubectl create secret generic ${DAEMON_NAME}-rucio-ca-bundle --from-file=/home/bruzzese/host-cert/rucio03_pic_es_interm.cer

# WebUI needs whole bundle as ca.pem. Keep this at end since we just over-wrote ca.pem

cp /home/bruzzese/host-cert/rucio03_pic_es_interm.cer
kubectl create secret generic ${UI_NAME}-cafile  --from-file=/home/bruzzese/host-cert/rucio03_pic_es_interm.cer

# Clean up
#rm tls.key tls.crt hostkey.pem hostcert.pem ca.pem
#rm usercert.pem new_userkey.pem

# Reapers needs the whole directory of certificates
mkdir /tmp/reaper-certs
cp /etc/grid-security/certificates/*.0 /tmp/reaper-certs/
cp /etc/grid-security/certificates/*.signing_policy /tmp/reaper-certs/
kubectl create secret generic ${DAEMON_NAME}-rucio-ca-bundle-reaper --from-file=/tmp/reaper-certs/
rm -rf /tmp/reaper-certs

kubectl get secrets

