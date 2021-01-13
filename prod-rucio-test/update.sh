#! /bin/bash

./create_secret.sh
helm upgrade server rucio/rucio-server -f server-v2.yaml
helm upgrade client rucio/rucio-clients -f client.yaml
