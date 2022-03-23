FROM centos:7

# Required repos
RUN yum install -y wget
ADD "http://dmc-repo.web.cern.ch/dmc-repo/dmc-ci-el7.repo" "/etc/yum.repos.d/"
ADD "http://repository.egi.eu/sw/production/cas/1/current/repo-files/EGI-trustanchors.repo" "/etc/yum.repos.d/"
RUN yum -y install https://repo.opensciencegrid.org/osg/3.5/osg-3.5-el7-release-latest.rpm

RUN yum --setopt=tsflags=nodocs -y install epel-release yum-plugin-ovl \
   && yum --setopt=tsflags=nodocs -y install fetch-crl wn sysstat ca-policy-egi-core ca-policy-lcg \
           voms-clients-cpp voms \
   && yum clean all

RUN yum install -y epel-release.noarch
RUN yum upgrade -y

# Add voms dependencies 
RUN yum install -y globus-proxy-utils voms-clients-cpp voms-clients-java

ENV WDIR=/data
ENV USER=_proxy

# add new user
RUN useradd ${USER} && install -o ${USER} -d ${WDIR}
# add user to sudoers file
RUN echo "%$USER ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# run the service
ADD ./config/proxy.sh /proxy.sh
ADD ./config/bashrc /root/.bashrc
RUN chmod 777 /proxy.sh

USER $USER
WORKDIR $WDIR
CMD ["/proxy.sh"]

