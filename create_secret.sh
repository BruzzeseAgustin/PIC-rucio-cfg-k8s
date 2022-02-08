#!/usr/bin/env bash

export DAEMON_NAME=daemons
export SERVER_NAME=pic01
export UI_NAME=web

echo "Removing existing secrets"

kubectl delete secret rucio-server.tls-secret

kubectl delete secret ${DAEMON_NAME}-fts-cert ${DAEMON_NAME}-fts-key ${DAEMON_NAME}-hermes-cert ${DAEMON_NAME}-hermes-key 
kubectl delete secret ${DAEMON_NAME}-rucio-ca-bundle ${DAEMON_NAME}-rucio-ca-bundle-reaper ${DAEMON_NAME}-fts-x509up ${DAEMON_NAME}-daemons-hermes-x509up
kubectl delete secret ${SERVER_NAME}-hostcert ${SERVER_NAME}-hostkey ${SERVER_NAME}-cafile  
kubectl delete secret ${SERVER_NAME}-auth-hostcert ${SERVER_NAME}-auth-hostkey ${SERVER_NAME}-auth-cafile  
kubectl delete secret ${UI_NAME}-hostcert ${UI_NAME}-hostkey ${UI_NAME}-cafile
kubectl delete secret ${DAEMON_NAME}-rucio-cfg

echo "Creating new secrets"
yes | cp -rf /etc/pki/tls/certs/ca-bundle.trust.crt ca.pem

kubectl create secret tls rucio-server.tls-secret --key=/$(pwd)/rucio_certs/hostkey.pem --cert=/$(pwd)/rucio_certs/hostcert.pem

kubectl create secret generic ${SERVER_NAME}-server-hostcert --from-file=hostcert.pem=/$(pwd)/rucio_certs/hostcert.pem
kubectl create secret generic ${SERVER_NAME}-server-hostkey --from-file=hostkey.pem=/$(pwd)/rucio_certs/hostkey.pem
kubectl create secret generic ${SERVER_NAME}-cafile --from-file=ca.pem=/$(pwd)/ca.pem

kubectl create secret generic ${SERVER_NAME}-hostcert --from-file=hostcert.pem=/$(pwd)/rucio_certs/hostcert.pem
kubectl create secret generic ${SERVER_NAME}-hostkey --from-file=hostkey.pem=/$(pwd)/rucio_certs/hostkey.pem

kubectl create secret generic ${SERVER_NAME}-auth-hostcert --from-file=hostcert.pem=/$(pwd)/rucio_certs/hostcert.pem
kubectl create secret generic ${SERVER_NAME}-auth-hostkey --from-file=hostkey.pem=/$(pwd)/rucio_certs/hostkey.pem
kubectl create secret generic ${SERVER_NAME}-auth-cafile --from-file=ca.pem=/$(pwd)/ca.pem

kubectl create secret generic ${SERVER_NAME}-trace-hostcert --from-file=hostcert.pem=/$(pwd)/rucio_certs/hostcert.pem
kubectl create secret generic ${SERVER_NAME}-trace-hostkey --from-file=hostkey.pem=/$(pwd)/rucio_certs/hostkey.pem
kubectl create secret generic ${SERVER_NAME}-trace-cafile --from-file=ca.pem=/$(pwd)/ca.pem

kubectl create secret generic ${SERVER_NAME}-rucio-x509up --from-file=x509up=/tmp/x509up_u1000
kubectl create secret generic ${SERVER_NAME}-certs --from-file=ca.pem

kubectl create secret generic clients-user-cert --from-file=usercert=/home/bruzzese/user-cert-v2/usercert.pem
kubectl create secret generic clients-user-key --from-file=userkey=/home/bruzzese/user-cert-v2/userkey.pem
kubectl create secret generic clients-rucio-ca-bundle-test --from-file=ca.pem=/$(pwd)/ca.pem

kubectl create secret generic clients-admin-cert --from-file=usercert.pem=/$(pwd)/rucio_certs/hostcert.pem
kubectl create secret generic clients-admin-key --from-file=userkey.pem=/$(pwd)/rucio_certs/hostkey.pem

kubectl create secret generic server-server-hostcert --from-file=hostcert.pem=/$(pwd)/rucio_certs/hostcert.pem
kubectl create secret generic server-server-hostkey --from-file=hostkey.pem=/$(pwd)/rucio_certs/hostkey.pem
kubectl create secret generic server-server-cafile --from-file=ca.pem=/$(pwd)/ca.pem
kubectl create secret generic server-auth-cafile --from-file=ca.pem=/$(pwd)/ca.pem

kubectl create secret generic server-auth-hostcert --from-file=hostcert.pem=/$(pwd)/rucio_certs/hostcert.pem
kubectl create secret generic server-auth-hostkey --from-file=hostkey.pem=/$(pwd)/rucio_certs/hostkey.pem
kubectl create secret generic server-auth-cafile --from-file=ca.pem=/$(pwd)/ca.pem

export DAEMON_NAME=daemons
# Generate proxy
# /$(pwd)/generate_proxy.sh
kubectl create secret generic ${DAEMON_NAME}-fts-cert --from-file=usercert=/$(pwd)/rucio_certs/hostcert.pem
kubectl create secret generic ${DAEMON_NAME}-fts-key --from-file=userkey=/$(pwd)/rucio_certs/hostkey.pem
kubectl create secret generic ${DAEMON_NAME}-fts-x509up --from-file=x509up=/tmp/x509up_u1000
kubectl create secret generic ${DAEMON_NAME}-hermes-cert --from-file=usercert=/$(pwd)/rucio_certs/hostcert.pem
kubectl create secret generic ${DAEMON_NAME}-hermes-key --from-file=userkey=/$(pwd)/rucio_certs/hostkey.pem
kubectl create secret generic ${DAEMON_NAME}-hermes-x509up --from-file=x509up=/tmp/x509up_u1000
kubectl create secret generic ${DAEMON_NAME}-rucio-ca-bundle --from-file=ca-volume=/$(pwd)/ca.pem
kubectl create secret generic ${DAEMON_NAME}-hermes2-script --from-file=/$(pwd)/hermes/

kubectl create secret generic ${DAEMON_NAME}-rucio-x509up --from-file=x509up=/tmp/x509up_u1000
kubectl create secret generic ${DAEMON_NAME}-rucio-x509up-reaper --from-file=x509up=/tmp/x509up_u1000
kubectl create secret generic ruciod-release-rucio-x509up --from-file=proxy-volume=/tmp/x509up_u1000
kubectl create secret generic ${DAEMON_NAME}-automatix --from-file=automatix.json=/$(pwd)/automatix.json

# this is a way to move around the issue with hermes2
kubectl create secret generic ${DAEMON_NAME}-rucio-cfg --from-file=rucio.cfg=/$(pwd)/rucio.cfg
kubectl create secret generic ${SERVER_NAME}-rucio-cfg --from-file=rucio.cfg=/$(pwd)/rucio.cfg.server
# Script to rotate logs in hermes2
kubectl create secret generic ${DAEMON_NAME}-hermes2-script --from-file=hermes2.py=/$(pwd)/hermes2.py

# Reapers needs the whole directory of certificates
mkdir /tmp/reaper-certs
cp /etc/grid-security/certificates/*.0 /tmp/reaper-certs/
cp /etc/grid-security/certificates/*.signing_policy /tmp/reaper-certs/
kubectl create secret generic ${DAEMON_NAME}-rucio-ca-bundle-reaper --from-file=/tmp/reaper-certs/
kubectl create secret generic ${SERVER_NAME}-rucio-ca-bundle-reaper --from-file=/tmp/reaper-certs/
kubectl create secret generic ${DAEMON_NAME}-rucio-ca-bundle-reaper2 --from-file=/tmp/reaper-certs/
rm -rf /tmp/reaper-certs

# Client needs these scripts in order to initiate RSEs, some users, and performe some basic test

mkdir /tmp/scripts
cp /$(pwd)/scripts/* /tmp/scripts/
kubectl create secret generic clients-admin-scripts --from-file=/tmp/scripts 
rm -rf /tmp/scripts

mkdir /tmp/user-certs
cp /etc/grid-security/certificates/*.0 /tmp/user-certs/
cp /etc/grid-security/certificates/*.signing_policy /tmp/user-certs/

kubectl create secret generic clients-user-ca --from-file=/tmp/user-certs/
kubectl create secret generic clients-admin-ca --from-file=/tmp/user-certs/
kubectl create secret generic clients-admin-x509up --from-file=x509up_u0=/tmp/x509up_u0
kubectl create secret generic clients-rucio-ca-bundle --from-file=/tmp/user-certs/
kubectl create secret generic web-certs --from-file=/tmp/user-certs/
kubectl create secret generic web-test-certs --from-file=/tmp/user-certs/
rm -rf /tmp/user-certs

kubectl create secret generic ${UI_NAME}-hostcert --from-file=hostcert.pem=/$(pwd)/rucio_certs/hostcert.pem
kubectl create secret generic ${UI_NAME}-hostkey --from-file=hostkey.pem=/$(pwd)/rucio_certs/hostkey.pem

# WebUI needs whole bundle as ca.pem. Keep this at end since we just over-wrote ca.pem

yes | cp -rf /etc/pki/tls/certs/ca-bundle.crt ca.pem  
kubectl create secret generic ${UI_NAME}-cafile  --from-file=ca.pem
kubectl create secret generic pic01-rucio-ca-bundle --from-file=ca.pem

rm -r ca.pem

kubectl create secret generic ${SERVER_NAME}-permission --from-file=pic.py=/$(pwd)/permission/pic.py
kubectl create secret generic ${SERVER_NAME}-schema --from-file=pic.py=/$(pwd)/schema/pic.py
kubectl create secret generic ${SERVER_NAME}-mail-templates --from-file=/$(pwd)/mail_templates

kubectl create secret generic ${UI_NAME}-permission --from-file=pic.py=/$(pwd)/permission/pic.py
kubectl create secret generic ${UI_NAME}-schema --from-file=pic.py=/$(pwd)/schema/pic.py
kubectl create secret generic ${UI_NAME}-base --from-file=base.js=/$(pwd)/config/base.js
kubectl create secret generic ${UI_NAME}-rucio --from-file=rucio.js=/$(pwd)/config/rucio.js
kubectl create secret generic ${UI_NAME}-web-ui --from-file=/$(pwd)/config

kubectl create secret generic ${SERVER_NAME}-usercert-with-key --from-file=usercert_with_key.pem=/$(pwd)/rucio_certs/usercert_with_key.pem
kubectl create secret generic ${UI_NAME}-usercert-with-key --from-file=usercert_with_key.pem=/$(pwd)/rucio_certs/usercert_with_key.pem

