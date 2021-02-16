#! /bin/bash

helm upgrade pic01 rucio/rucio-server -f server.yaml
helm upgrade daemons rucio/rucio-daemons -f daemons.yaml
helm upgrade web rucio/rucio-ui -f web-ui.yaml
