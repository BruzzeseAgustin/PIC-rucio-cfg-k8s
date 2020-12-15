#!/usr/bin/env bash


kubectl create secret tls rucio-server.tls-secret --key=host-cert-k8s-v3/hostkey.pem --cert=host-cert-k8s-v3/hostcert.pem
kubectl create secret tls rucio-web.tls-secret --key=host-cert-web-v1/hostkey.pem --cert=host-cert-web-v1/hostcert.pem

kubectl create secret generic pic01-server-hostcert --from-file=hostcert.pem=/$(pwd)/host-cert-k8s-v3/hostcert.pem
kubectl create secret generic pic01-server-hostkey --from-file=hostkey.pem=/$(pwd)/host-cert-k8s-v3/hostkey.pem
kubectl create secret generic pic01-cafile --from-file=ca.pem=/$(pwd)/host-cert-k8s-v3/GEANTeScienceSSLCA4.pem

kubectl create secret generic pic01-hostcert --from-file=hostcert.pem=/$(pwd)/host-cert-k8s-v3/hostcert.pem
kubectl create secret generic pic01-hostkey --from-file=hostkey.pem=/$(pwd)/host-cert-k8s-v3/hostkey.pem
kubectl create secret generic pic01-cafile --from-file=ca.pem=/$(pwd)/host-cert-k8s-v3/GEANTeScienceSSLCA4.pem

kubectl create secret generic pic01-auth-hostcert --from-file=hostcert.pem=/$(pwd)/host-cert-k8s-v3/hostcert.pem
kubectl create secret generic pic01-auth-hostkey --from-file=hostkey.pem=/$(pwd)/host-cert-k8s-v3/hostkey.pem
kubectl create secret generic pic01-auth-cafile --from-file=ca.pem=/$(pwd)/host-cert-k8s-v3/GEANTeScienceSSLCA4.pem

kubectl create secret generic pic01-trace-hostcert --from-file=hostcert.pem=/$(pwd)/host-cert-k8s-v3/hostcert.pem
kubectl create secret generic pic01-trace-hostkey --from-file=hostkey.pem=/$(pwd)/host-cert-k8s-v3/hostkey.pem
kubectl create secret generic pic01-trace-cafile --from-file=ca.pem=/$(pwd)/host-cert-k8s-v3/GEANTeScienceSSLCA4.pem

kubectl create secret generic clients-user-cert --from-file=usercert=/home/bruzzese/user-cert/usercert.pem
kubectl create secret generic clients-user-key --from-file=userkey=/home/bruzzese/user-cert/userkey.pem
kubectl create secret generic clients-rucio-ca-bundle-test --from-file=ca.pem=/$(pwd)/host-cert-k8s-v3/GEANTeScienceSSLCA4.pem

kubectl create secret generic clients-admin-cert --from-file=usercert.pem=/$(pwd)/host-cert-k8s-v3/hostcert.pem
kubectl create secret generic clients-admin-key --from-file=userkey.pem=/$(pwd)/host-cert-k8s-v3/hostkey.pem

kubectl create secret generic server-server-hostcert --from-file=hostcert.pem=/$(pwd)/host-cert-k8s-v3/hostcert.pem
kubectl create secret generic server-server-hostkey --from-file=hostkey.pem=/$(pwd)/host-cert-k8s-v3/hostkey.pem
# kubectl create secret generic server-server-cafile --from-file=ca.pem=/$(pwd)/host-cert-k8s-v3/rucio03_pic_es_interm.cer
kubectl create secret generic server-auth-cafile --from-file=ca.pem=/etc/grid-security/certificates/GEANTeScienceSSLCA4.pem

kubectl create secret generic server-auth-hostcert --from-file=hostcert.pem=/$(pwd)/host-cert-k8s-v3/hostcert.pem
kubectl create secret generic server-auth-hostkey --from-file=hostkey.pem=/$(pwd)/host-cert-k8s-v3/hostkey.pem
# kubectl create secret generic server-auth-cafile --from-file=ca.pem=/$(pwd)/host-cert-k8s-v3/rucio03_pic_es_interm.cer
kubectl create secret generic server-auth-cafile --from-file=ca.pem=/etc/grid-security/certificates/GEANTeScienceSSLCA4.pem


export DAEMON_NAME=daemons
kubectl create secret generic ${DAEMON_NAME}-fts-cert --from-file=usercert=/$(pwd)/host-cert-k8s-v3/hostcert.pem
kubectl create secret generic ${DAEMON_NAME}-fts-key --from-file=userkey=/$(pwd)/host-cert-k8s-v3/hostkey.pem
kubectl create secret generic ${DAEMON_NAME}-hermes-cert --from-file=usercert=/$(pwd)/host-cert-k8s-v3/hostcert.pem
kubectl create secret generic ${DAEMON_NAME}-hermes-key --from-file=userkey=/$(pwd)/host-cert-k8s-v3/hostkey.pem
kubectl create secret generic ${DAEMON_NAME}-rucio-ca-bundle --from-file=ca-volume=/etc/grid-security/certificates/GEANTeScienceSSLCA4.pem
kubectl create secret generic ${DAEMON_NAME}-rucio-x509up --from-file=proxy-volume=/tmp/x509up_u0

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
kubectl create secret generic clients-rucio-ca-bundle --from-file=/tmp/user-certs/
kubectl create secret generic web-certs --from-file=/tmp/user-certs/
rm -rf /tmp/user-certs

export UI_NAME=web
kubectl create secret generic ${UI_NAME}-hostcert --from-file=hostcert.pem=/$(pwd)/host-cert-web-v1/hostcert.pem
kubectl create secret generic ${UI_NAME}-hostkey --from-file=hostkey.pem=/$(pwd)/host-cert-web-v1/hostkey.pem
kubectl create secret generic ${UI_NAME}-cafile --from-file=ca.pem=/etc/grid-security/certificates/GEANTeScienceSSLCA4.pem

kubectl create secret generic pic01-permission --from-file=pic.py=/$(pwd)/permission/pic.py
kubectl create secret generic pic01-schema --from-file=pic.py=/$(pwd)/schema/pic.py

kubectl create secret generic pic01-usercert-with-key --from-file=usercert_with_key.pem=/$(pwd)/host-cert-web-v1/usercert_with_key.pem
kubectl create secret generic web-usercert-with-key --from-file=usercert_with_key.pem=/$(pwd)/host-cert-web-v1/usercert_with_key.pem