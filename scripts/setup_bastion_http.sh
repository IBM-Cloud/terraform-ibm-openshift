#!/bin/sh
# Install all the rpms and images required by openshoft cluster.

yum clean all
yum -y update
yum -y install yum-utils createrepo docker git


yum install httpd -y
mkdir -p /var/www/html/repos


for repo in rhel-7-server-ose-3.6-rpms
do
 reposync --gpgcheck -lm --repoid=${repo} --download_path=/var/www/html/repos/
 if [ ${repo} == "rhel-7-server-ose-3.6-rpms" ]
 then
  wget ftp://mirror.switch.ch/pool/4/mirror/centos/7.5.1804/cloud/x86_64/openstack-ocata/openvswitch-2.6.1-10.1.git20161206.el7.x86_64.rpm -P /var/www/html/repos/${repo}/Packages
 fi
 createrepo -v /var/www/html/repos/${repo} -o /var/www/html/repos/${repo}
done

# Install all the images required for openshift

systemctl start docker


 
#Pull all of the required OpenShift Enterprise containerized components:

docker pull registry.access.redhat.com/openshift3/ose-haproxy-router:v3.6.173.0.112
docker pull registry.access.redhat.com/openshift3/ose-deployer:v3.6.173.0.112
docker pull registry.access.redhat.com/openshift3/ose-sti-builder:v3.6.173.0.112
docker pull registry.access.redhat.com/openshift3/ose-docker-builder:v3.6.173.0.112
docker pull registry.access.redhat.com/openshift3/ose-pod:v3.6.173.0.112
docker pull registry.access.redhat.com/openshift3/ose-docker-registry:v3.6.173.0.112

#Pull all of the required OpenShift Enterprise containerized components for the additional centralized log aggregation and metrics aggregation components:

docker pull registry.access.redhat.com/openshift3/logging-deployment
docker pull registry.access.redhat.com/openshift3/logging-elasticsearch
docker pull registry.access.redhat.com/openshift3/logging-kibana
docker pull registry.access.redhat.com/openshift3/logging-fluentd
docker pull registry.access.redhat.com/openshift3/logging-auth-proxy
docker pull registry.access.redhat.com/openshift3/metrics-deployer
docker pull registry.access.redhat.com/openshift3/metrics-hawkular-metrics
docker pull registry.access.redhat.com/openshift3/metrics-cassandra
docker pull registry.access.redhat.com/openshift3/metrics-heapster

#Preparing images to export

mkdir -p /var/www/html/repos/images

cd /var/www/html/repos/images

docker save -o ose3.6-images.tar \
    registry.access.redhat.com/openshift3/ose-haproxy-router \
    registry.access.redhat.com/openshift3/ose-deployer \
    registry.access.redhat.com/openshift3/ose-sti-builder \
    registry.access.redhat.com/openshift3/ose-docker-builder \
    registry.access.redhat.com/openshift3/ose-pod \
    registry.access.redhat.com/openshift3/ose-docker-registry

docker save -o ose3-logging-metrics-images.tar \
    registry.access.redhat.com/openshift3/logging-deployment \
    registry.access.redhat.com/openshift3/logging-elasticsearch \
    registry.access.redhat.com/openshift3/logging-kibana \
    registry.access.redhat.com/openshift3/logging-fluentd \
    registry.access.redhat.com/openshift3/logging-auth-proxy \
    registry.access.redhat.com/openshift3/metrics-deployer \
    registry.access.redhat.com/openshift3/metrics-hawkular-metrics \
    registry.access.redhat.com/openshift3/metrics-cassandra \
    registry.access.redhat.com/openshift3/metrics-heapster

#Configure httpd server

chmod -R +r /var/www/html/repos
restorecon -vR /var/www/html
systemctl enable firewalld
systemctl start firewalld
firewall-cmd --permanent --add-service=http
firewall-cmd --reload
systemctl enable httpd
systemctl start httpd
