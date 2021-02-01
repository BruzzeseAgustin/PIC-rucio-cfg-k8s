#!/bin/bash/env

cd ~
yum -y install java-1.8.0-openjdk
export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.212.b04-0.el7_6.x86_64/jre/
export PATH=$PATH:$JAVA_HOME/bin

ls -l /usr/lib/jvm/

#curl -o apache-activemq-5.15.9-bin.tar.gz -l "https://www.apache.org/dist/activemq/5.15.9/apache-activemq-5.15.9-bin.tar.gz"
#curl -o apache-activemq-5.15.9-bin.tar.gz -l "https://downloads.apache.org/activemq/5.15.9/apache-activemq-5.15.9-bin.tar.gz"

curl -o apache-activemq-5.15.9-bin.tar.gz -l "https://downloads.apache.org/activemq/5.16.1/apache-activemq-5.16.1-bin.tar.gz"

tar -zxvf apache-activemq-5.15.9-bin.tar.gz
