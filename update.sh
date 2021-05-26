#! /bin/bash

helm upgrade --install pic01 rucio/rucio-server -f server.yaml
helm upgrade --install daemons rucio/rucio-daemons -f daemons.yaml
helm upgrade --install web rucio/rucio-ui -f web-ui.yaml
