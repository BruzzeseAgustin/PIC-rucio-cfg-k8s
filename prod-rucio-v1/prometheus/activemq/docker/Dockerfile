FROM centos:7
COPY installer.sh tmp/installer.sh
RUN /bin/bash tmp/installer.sh
EXPOSE 61613/tcp
EXPOSE 61613/udp
LABEL version="0.1"
LABEL description="This Docker image from the Enrico Fermi Institute contains resources for ActiveMQ as a Kubernetes Service."
