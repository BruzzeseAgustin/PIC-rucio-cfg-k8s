#!/usr/bin/env bash

export DAEMON_NAME=daemons
export SERVER_NAME=pic01
export UI_NAME=web

echo "Removing existing secrets"

kubectl delete secret rucio-server.tls-secret
kubectl delete secret rucio-web.tls-secret
kubectl delete secret ${DAEMON_NAME}-fts-cert ${DAEMON_NAME}-fts-key ${DAEMON_NAME}-hermes-cert ${DAEMON_NAME}-hermes-key 
kubectl delete secret ${DAEMON_NAME}-rucio-ca-bundle ${DAEMON_NAME}-rucio-ca-bundle-reaper
kubectl delete secret ${SERVER_NAME}-hostcert ${SERVER_NAME}-hostkey ${SERVER_NAME}-cafile  
kubectl delete secret ${SERVER_NAME}-auth-hostcert ${SERVER_NAME}-auth-hostkey ${SERVER_NAME}-auth-cafile  
kubectl delete secret ${UI_NAME}-hostcert ${UI_NAME}-hostkey ${UI_NAME}-cafile

echo "Creating new secrets"
yes | cp -rf /etc/pki/tls/certs/ca-bundle.trust.crt

kubectl create secret tls rucio-server.tls-secret --key=/$(pwd)/host-cert-k8s-v3/hostkey.pem --cert=/$(pwd)/host-cert-k8s-v3/hostcert.pem
kubectl create secret tls rucio-web.tls-secret --key=/$(pwd)/host-cert-k8s-v3/hostkey.pem --cert=/$(pwd)/host-cert-k8s-v3/hostcert.pem

kubectl create secret generic ${SERVER_NAME}-server-hostcert --from-file=hostcert.pem=/$(pwd)/host-cert-k8s-v3/hostcert.pem
kubectl create secret generic ${SERVER_NAME}-server-hostkey --from-file=hostkey.pem=/$(pwd)/host-cert-k8s-v3/hostkey.pem
# kubectl create secret generic ${SERVER_NAME}-cafile --from-file=ca.pem=/$(pwd)/host-cert-k8s-v3/pic01-rucio-server_pic_es_interm.cer 
kubectl create secret generic ${SERVER_NAME}-cafile --from-file=ca.pem=/$(pwd)/ca.pem

kubectl create secret generic ${SERVER_NAME}-hostcert --from-file=hostcert.pem=/$(pwd)/host-cert-k8s-v3/hostcert.pem
kubectl create secret generic ${SERVER_NAME}-hostkey --from-file=hostkey.pem=/$(pwd)/host-cert-k8s-v3/hostkey.pem
# kubectl create secret generic ${SERVER_NAME}-cafile --from-file=ca.pem=/$(pwd)/host-cert-k8s-v3/pic01-rucio-server_pic_es_interm.cer 

kubectl create secret generic ${SERVER_NAME}-auth-hostcert --from-file=hostcert.pem=/$(pwd)/host-cert-k8s-v3/hostcert.pem
kubectl create secret generic ${SERVER_NAME}-auth-hostkey --from-file=hostkey.pem=/$(pwd)/host-cert-k8s-v3/hostkey.pem
# kubectl create secret generic ${SERVER_NAME}-auth-cafile --from-file=ca.pem=/$(pwd)/host-cert-k8s-v3/pic01-rucio-server_pic_es_interm.cer 
kubectl create secret generic ${SERVER_NAME}-auth-cafile --from-file=ca.pem=/$(pwd)/ca.pem

kubectl create secret generic ${SERVER_NAME}-trace-hostcert --from-file=hostcert.pem=/$(pwd)/host-cert-k8s-v3/hostcert.pem
kubectl create secret generic ${SERVER_NAME}-trace-hostkey --from-file=hostkey.pem=/$(pwd)/host-cert-k8s-v3/hostkey.pem
# kubectl create secret generic ${SERVER_NAME}-trace-cafile --from-file=ca.pem=/$(pwd)/host-cert-k8s-v3/pic01-rucio-server_pic_es_interm.cer 
kubectl create secret generic ${SERVER_NAME}-trace-cafile --from-file=ca.pem=/$(pwd)/ca.pem

kubectl create secret generic clients-user-cert --from-file=usercert=/home/bruzzese/user-cert/usercert.pem
kubectl create secret generic clients-user-key --from-file=userkey=/home/bruzzese/user-cert/userkey.pem
# kubectl create secret generic clients-rucio-ca-bundle-test --from-file=ca.pem=/$(pwd)/host-cert-k8s-v3/pic01-rucio-server_pic_es_interm.cer 
kubectl create secret generic clients-rucio-ca-bundle-test --from-file=ca.pem=/$(pwd)/ca.pem

kubectl create secret generic clients-admin-cert --from-file=usercert.pem=/$(pwd)/host-cert-k8s-v3/hostcert.pem
kubectl create secret generic clients-admin-key --from-file=userkey.pem=/$(pwd)/host-cert-k8s-v3/hostkey.pem

kubectl create secret generic server-server-hostcert --from-file=hostcert.pem=/$(pwd)/host-cert-k8s-v3/hostcert.pem
kubectl create secret generic server-server-hostkey --from-file=hostkey.pem=/$(pwd)/host-cert-k8s-v3/hostkey.pem
# kubectl create secret generic server-server-cafile --from-file=ca.pem=/$(pwd)/host-cert-k8s-v3/rucio03_pic_es_interm.cer
# kubectl create secret generic server-auth-cafile --from-file=ca.pem=/$(pwd)/host-cert-k8s-v3/pic01-rucio-server_pic_es_interm.cer
kubectl create secret generic server-server-cafile --from-file=ca.pem=/$(pwd)/ca.pem
kubectl create secret generic server-auth-cafile --from-file=ca.pem=/$(pwd)/ca.pem

kubectl create secret generic server-auth-hostcert --from-file=hostcert.pem=/$(pwd)/host-cert-k8s-v3/hostcert.pem
kubectl create secret generic server-auth-hostkey --from-file=hostkey.pem=/$(pwd)/host-cert-k8s-v3/hostkey.pem
# kubectl create secret generic server-auth-cafile --from-file=ca.pem=/$(pwd)/host-cert-k8s-v3/rucio03_pic_es_interm.cer
# kubectl create secret generic server-auth-cafile --from-file=ca.pem=/$(pwd)/host-cert-k8s-v3/pic01-rucio-server_pic_es_interm.cer
kubectl create secret generic server-auth-cafile --from-file=ca.pem=/$(pwd)/ca.pem

export DAEMON_NAME=daemons
kubectl create secret generic ${DAEMON_NAME}-fts-cert --from-file=usercert=/$(pwd)/host-cert-k8s-v3/hostcert.pem
kubectl create secret generic ${DAEMON_NAME}-fts-key --from-file=userkey=/$(pwd)/host-cert-k8s-v3/hostkey.pem
kubectl create secret generic ${DAEMON_NAME}-hermes-cert --from-file=usercert=/$(pwd)/host-cert-k8s-v3/hostcert.pem
kubectl create secret generic ${DAEMON_NAME}-hermes-key --from-file=userkey=/$(pwd)/host-cert-k8s-v3/hostkey.pem
# kubectl create secret generic ${DAEMON_NAME}-rucio-ca-bundle --from-file=ca-volume=/$(pwd)/host-cert-k8s-v3/pic01-rucio-server_pic_es_interm.cer
kubectl create secret generic ${DAEMON_NAME}-rucio-ca-bundle --from-file=ca-volume=/$(pwd)/ca.pem

# kubectl create secret generic ${DAEMON_NAME}-rucio-x509up --from-file=proxy-volume=/tmp/x509up_u0
kubectl create secret generic ${DAEMON_NAME}-rucio-x509up --from-file=x509up=/tmp/x509up_u0
kubectl create secret generic ${DAEMON_NAME}-rucio-x509up-reaper --from-file=x509up=/tmp/x509up_u0
kubectl create secret generic ruciod-release-rucio-x509up --from-file=proxy-volume=/tmp/x509up_u0

# Reapers needs the whole directory of certificates
mkdir /tmp/reaper-certs
cp /etc/grid-security/certificates/*.0 /tmp/reaper-certs/
cp /etc/grid-security/certificates/*.signing_policy /tmp/reaper-certs/
kubectl create secret generic ${DAEMON_NAME}-rucio-ca-bundle-reaper --from-file=/tmp/reaper-certs/
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

export UI_NAME=web
kubectl create secret generic ${UI_NAME}-hostcert --from-file=hostcert.pem=/$(pwd)/host-cert-k8s-v3/hostcert.pem
kubectl create secret generic ${UI_NAME}-hostkey --from-file=hostkey.pem=/$(pwd)/host-cert-k8s-v3/hostkey.pem
# kubectl create secret generic ${UI_NAME}-cafile --from-file=ca.pem=/$(pwd)/host-cert-k8s-v3/pic01-rucio-server-web_pic_es_interm.cer

# WebUI needs whole bundle as ca.pem. Keep this at end since we just over-wrote ca.pem

# yes | cp -rf /etc/pki/tls/certs/ca-bundle.crt ca.pem  
yes | cp -rf /etc/pki/tls/certs/ca-bundle.trust.crt
kubectl create secret generic ${UI_NAME}-cafile  --from-file=ca.pem

kubectl create secret generic pic01-permission --from-file=pic.py=/$(pwd)/permission/pic.py
kubectl create secret generic pic01-schema --from-file=pic.py=/$(pwd)/schema/pic.py

kubectl create secret generic web-permission --from-file=pic.py=/$(pwd)/permission/pic.py
kubectl create secret generic web-schema --from-file=pic.py=/$(pwd)/schema/pic.py

kubectl create secret generic web-test-permission --from-file=pic.py=/$(pwd)/permission/pic.py
kubectl create secret generic web-test-schema --from-file=pic.py=/$(pwd)/schema/pic.py

#kubectl create secret generic pic01-usercert-with-key --from-file=usercert_with_key.pem=/$(pwd)/host-cert-k8s-v3/usercert_with_key.pem
#kubectl create secret generic web-usercert-with-key --from-file=usercert_with_key.pem=/$(pwd)/host-cert-k8s-v3/usercert_with_key.pem
#kubectl create secret generic web-test-usercert-with-key --from-file=usercert_with_key.pem=/$(pwd)/host-cert-k8s-v3/usercert_with_key.pem

kubectl create secret generic pic01-usercert-with-key --from-file=usercert_with_key.pem=/$(pwd)/host-cert-k8s-v3/usercert_with_key.pem
kubectl create secret generic web-usercert-with-key --from-file=usercert_with_key.pem=/$(pwd)/host-cert-k8s-v3/usercert_with_key.pem
kubectl create secret generic web-test-usercert-with-key --from-file=usercert_with_key.pem=/$(pwd)/host-cert-k8s-v3/usercert_with_key.pem

