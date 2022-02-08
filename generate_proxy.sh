#!/bin/bash
#
# cred_proxy
#
# Create an x509 proxy from the host's igtf grid certificate and delegate
# against the osg fts server at https://fts01.pic.es:8446.  Run this script (as
# root) as a cronjob to maintain an FTS-delegated proxy for rucio operations.
#
## Configuration
export PASSPHRASE=

proxytool=/usr/bin/voms-proxy-init
hostcert=$(pwd)/rucio_certs/hostcert.pem
hostkey=$(pwd)/rucio_certs/hostkey.pem
x509proxy=$(pwd)/rucio_certs/x509up_u1000

## Logging info
dtstamp="`date +%F-%A-%H.%M.%S `"
echo -e "\n################ ${dtstamp} ################" 


## Create robot proxy
# echo $PASSPHRASE
echo -e "${dtstamp}: ${proxytool} -cert ${hostcert} -key ${hostkey} -out ${x509proxy}"

echo $PASSPHRASE | ${proxytool} --cert ${hostcert} --key ${hostkey} --out ${x509proxy} --valid 3000:00
  
voms-proxy-info -all
  
