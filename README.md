# Changes

This version introduces uses for functional hadoop components as well as CID script for the cluster startup

## Dependencies
The following are required to deploy the hadoop image.
For the installation of the hadoop server, root permissions are required.
First follow the following lines to install docker 

 sudo yum install -y yum-utils

 sudo yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo

 sudo yum install -y docker-ce docker-ce-cli containerd.io

At the same time, it is necessary to install wget and git lfs

sudo yum install -y wget git-lfs

# Hadoop Server 

## Supported Hadoop Versions
See repository branches for supported hadoop versions and additional components

## Installation as service

Clone this repository to a suitable location.

```
git clone -b rucio-v1 https://gitlab.pic.es/bruzzese/PIC-rucio-server-k8s.git
```

If desired, you can change the version's for the configuration files in the `variables.env` files.

An accompanied Makefile in this repository will assist you in setting up as a service (only works on GNU/Linux). Change "localhost" in the command below to whatever the hostname for your server should be.


## Quick Start

To deploy an example HDFS cluster, run:

```
  cd PIC-rucio-server-k8s
```

get magic: read_variables # Download magic's configuracion file
	wget -O config.env https://gitlab.pic.es/bruzzese/pic-rucio-cfg-k8s/-/raw/main/config.env
	
get_icfo: read_variables # Download icfo's configuracion file
	wget -O config.env https://gitlab.pic.es/bruzzese/pic-rucio-cfg-k8s-icfo/-/raw/icfo-v1.0.0/config.env
	
get_cta: read_variables # Download cta's configuracion file
	wget -O config.env https://gitlab.pic.es/bruzzese/pic-rucio-cfg-k8s-cta/-/raw/cta-v1.0.0/config.env
	
```
  make download_untar 
  make build 
  make run_setup 
  make run_start
```

