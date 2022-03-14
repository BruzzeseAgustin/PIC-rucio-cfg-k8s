#!/bin/bash

source /$(pwd)/config.env

export DAEMON_NAME=$RELEASE_NAME-daemons
export SERVER_NAME=$RELEASE_NAME-server
export UI_NAME=$RELEASE_NAME-ui
export DIR_CERTS=certs-k8s


echo "Removing existing secrets"

kubectl delete secret rucio-server.tls-secret

kubectl delete secret ${DAEMON_NAME}-fts-cert ${DAEMON_NAME}-fts-key ${DAEMON_NAME}-hermes-cert ${DAEMON_NAME}-hermes-key 
kubectl delete secret ${DAEMON_NAME}-rucio-ca-bundle ${DAEMON_NAME}-rucio-ca-bundle-reaper ${DAEMON_NAME}-fts-x509up ${DAEMON_NAME}-daemons-hermes-x509up
kubectl delete secret ${SERVER_NAME}-hostcert ${SERVER_NAME}-hostkey ${SERVER_NAME}-cafile  
kubectl delete secret ${SERVER_NAME}-auth-hostcert ${SERVER_NAME}-auth-hostkey ${SERVER_NAME}-auth-cafile  
kubectl delete secret ${UI_NAME}-hostcert ${UI_NAME}-hostkey ${UI_NAME}-cafile
kubectl delete secret ${DAEMON_NAME}-rucio-cfg

echo "Creating new secrets"
if [ ! -f /$(pwd)/certs/robotcert.pem ] && [ -f /$(pwd)/certs/robotcert.pem ]; then
   yes | cp -rf /etc/pki/tls/certs/ca-bundle.trust.crt /$(pwd)/config/docker/certs/ca.pem
fi
 
	
kubectl create secret tls rucio-server.tls-secret --key=/$(pwd)/${DIR_CERTS}/hostkey.pem --cert=/$(pwd)/${DIR_CERTS}/hostcert.pem

kubectl create secret generic ${SERVER_NAME}-server-hostcert --from-file=hostcert.pem=/$(pwd)/${DIR_CERTS}/hostcert.pem
kubectl create secret generic ${SERVER_NAME}-server-hostkey --from-file=hostkey.pem=/$(pwd)/${DIR_CERTS}/hostkey.pem
kubectl create secret generic ${SERVER_NAME}-cafile --from-file=ca.pem=/$(pwd)/config/docker/certs/ca.pem

kubectl create secret generic ${SERVER_NAME}-hostcert --from-file=hostcert.pem=/$(pwd)/${DIR_CERTS}/hostcert.pem
kubectl create secret generic ${SERVER_NAME}-hostkey --from-file=hostkey.pem=/$(pwd)/${DIR_CERTS}/hostkey.pem

kubectl create secret generic ${SERVER_NAME}-auth-hostcert --from-file=hostcert.pem=/$(pwd)/${DIR_CERTS}/hostcert.pem
kubectl create secret generic ${SERVER_NAME}-auth-hostkey --from-file=hostkey.pem=/$(pwd)/${DIR_CERTS}/hostkey.pem
kubectl create secret generic ${SERVER_NAME}-auth-cafile --from-file=ca.pem=/$(pwd)/config/docker/certs/ca.pem

kubectl create secret generic ${SERVER_NAME}-trace-hostcert --from-file=hostcert.pem=/$(pwd)/${DIR_CERTS}/hostcert.pem
kubectl create secret generic ${SERVER_NAME}-trace-hostkey --from-file=hostkey.pem=/$(pwd)/${DIR_CERTS}/hostkey.pem
kubectl create secret generic ${SERVER_NAME}-trace-cafile --from-file=ca.pem=/$(pwd)/config/docker/certs/ca.pem

kubectl create secret generic ${SERVER_NAME}-rucio-x509up --from-file=x509up=/$(pwd)/proxy/x509
kubectl create secret generic ${SERVER_NAME}-certs --from-file=/$(pwd)/config/docker/certs/ca.pem


kubectl create secret generic server-server-hostcert --from-file=hostcert.pem=/$(pwd)/${DIR_CERTS}/hostcert.pem
kubectl create secret generic server-server-hostkey --from-file=hostkey.pem=/$(pwd)/${DIR_CERTS}/hostkey.pem
kubectl create secret generic server-server-cafile --from-file=ca.pem=/$(pwd)/config/docker/certs/ca.pem
kubectl create secret generic server-auth-cafile --from-file=ca.pem=/$(pwd)/config/docker/certs/ca.pem

kubectl create secret generic server-auth-hostcert --from-file=hostcert.pem=/$(pwd)/${DIR_CERTS}/hostcert.pem
kubectl create secret generic server-auth-hostkey --from-file=hostkey.pem=/$(pwd)/${DIR_CERTS}/hostkey.pem
kubectl create secret generic server-auth-cafile --from-file=ca.pem=/$(pwd)/config/docker/certs/ca.pem


# Generate proxy
kubectl create secret generic ${DAEMON_NAME}-fts-cert --from-file=usercert=/$(pwd)/${DIR_CERTS}/hostcert.pem
kubectl create secret generic ${DAEMON_NAME}-fts-key --from-file=userkey=/$(pwd)/${DIR_CERTS}/hostkey.pem
kubectl create secret generic ${DAEMON_NAME}-fts-x509up --from-file=x509up=/$(pwd)/proxy/x509
kubectl create secret generic ${DAEMON_NAME}-hermes-cert --from-file=usercert=/$(pwd)/${DIR_CERTS}/hostcert.pem
kubectl create secret generic ${DAEMON_NAME}-hermes-key --from-file=userkey=/$(pwd)/${DIR_CERTS}/hostkey.pem
kubectl create secret generic ${DAEMON_NAME}-hermes-x509up --from-file=x509up=/$(pwd)/proxy/x509
kubectl create secret generic ${DAEMON_NAME}-rucio-ca-bundle --from-file=ca-volume=/$(pwd)/config/docker/certs/ca.pem
kubectl create secret generic ${DAEMON_NAME}-hermes2-script --from-file=/$(pwd)/dependencies/hermes/

kubectl create secret generic ${DAEMON_NAME}-rucio-x509up --from-file=x509up=/$(pwd)/proxy/x509
kubectl create secret generic ${DAEMON_NAME}-rucio-x509up-reaper --from-file=x509up=/$(pwd)/proxy/x509
kubectl create secret generic ruciod-release-rucio-x509up --from-file=proxy-volume=/$(pwd)/proxy/x509

# this is a way to move around the issue with hermes2
kubectl create secret generic ${DAEMON_NAME}-rucio-cfg --from-file=rucio.cfg=/$(pwd)/config/rucio-cfg/rucio.cfg.daemons
kubectl create secret generic ${SERVER_NAME}-rucio-cfg --from-file=rucio.cfg=/$(pwd)/config/rucio-cfg/rucio.cfg.server
# Script to rotate logs in hermes2
kubectl create secret generic ${DAEMON_NAME}-hermes2-script --from-file=hermes2.py=/$(pwd)/dependencies/hermes/hermes2.py

# Reapers needs the whole directory of certificates
mkdir /tmp/reaper-certs
cp /$(pwd)/certs/grid-security/certificates/*.0 /tmp/reaper-certs/
cp /$(pwd)/certs/grid-security/certificates/*.signing_policy /tmp/reaper-certs/
kubectl create secret generic ${DAEMON_NAME}-rucio-ca-bundle-reaper --from-file=/tmp/reaper-certs/
kubectl create secret generic ${SERVER_NAME}-rucio-ca-bundle-reaper --from-file=/tmp/reaper-certs/
kubectl create secret generic ${DAEMON_NAME}-rucio-ca-bundle-reaper2 --from-file=/tmp/reaper-certs/
rm -rf /tmp/reaper-certs

mkdir -pv /tmp/user-certs/
cp /$(pwd)/certs/grid-security/certificates/*.0 /tmp/user-certs/
cp /$(pwd)/certs/grid-security/certificates/*.signing_policy /tmp/user-certs/


kubectl create secret generic ${UI_NAME}-certs --from-file=/tmp/user-certs/
kubectl create secret generic ${UI_NAME}-test-certs --from-file=/tmp/user-certs/
rm -rf /tmp/user-certs

kubectl create secret generic ${UI_NAME}-hostcert --from-file=hostcert.pem=/$(pwd)/${DIR_CERTS}/hostcert.pem
kubectl create secret generic ${UI_NAME}-hostkey --from-file=hostkey.pem=/$(pwd)/${DIR_CERTS}/hostkey.pem

# WebUI needs whole bundle as ca.pem. Keep this at end since we just over-wrote ca.pem

kubectl create secret generic ${UI_NAME}-cafile  --from-file=ca.pem=/$(pwd)/config/docker/certs/ca_full.pem
kubectl create secret generic ${SERVER_NAME}-rucio-ca-bundle --from-file=/$(pwd)/config/docker/certs/ca.pem

kubectl create secret generic ${SERVER_NAME}-permission --from-file=pic.py=/$(pwd)/dependencies/permission/pic.py
kubectl create secret generic ${SERVER_NAME}-schema --from-file=pic.py=/$(pwd)/dependencies/schema/pic.py
kubectl create secret generic ${SERVER_NAME}-mail-templates --from-file=/$(pwd)/dependencies/mail_templates

kubectl create secret generic ${UI_NAME}-permission --from-file=pic.py=/$(pwd)/dependencies/permission/pic.py
kubectl create secret generic ${UI_NAME}-schema --from-file=pic.py=/$(pwd)/dependencies/schema/pic.py
kubectl create secret generic ${UI_NAME}-base --from-file=base.js=/$(pwd)/dependencies/web/base.js
kubectl create secret generic ${UI_NAME}-rucio --from-file=rucio.js=/$(pwd)/dependencies/web/rucio.js
kubectl create secret generic ${UI_NAME}-web-ui --from-file=/$(pwd)/config



