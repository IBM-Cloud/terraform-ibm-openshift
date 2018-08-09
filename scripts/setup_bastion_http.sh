#!/bin/sh
# Install all the rpms and images required by openshoft cluster.

yum clean all
yum -y update
yum -y install yum-utils createrepo docker git


yum install httpd -y
mkdir -p /var/www/html/repos


for repo in \
rhel-7-fast-datapath-rpms \
rhel-7-server-ansible-2.4-rpms \
rhel-7-server-ose-3.9-rpms
do
 reposync --gpgcheck -lm --repoid=${repo} --download_path=/var/www/html/repos/
 if [ ${repo} == "rhel-7-server-ose-3.9-rpms" ]
 then
  wget ftp://mirror.switch.ch/pool/4/mirror/centos/7.5.1804/cloud/x86_64/openstack-ocata/openvswitch-2.6.1-10.1.git20161206.el7.x86_64.rpm -P /var/www/html/repos/${repo}/Packages
 fi
 createrepo -v /var/www/html/repos/${repo} -o /var/www/html/repos/${repo}
done

# Install all the images required for openshift

systemctl start docker

#Pull all of the required OpenShift Enterprise containerized components:

docker pull registry.access.redhat.com/openshift3/ose-ansible:v3.9.33
docker pull registry.access.redhat.com/openshift3/ose-cluster-capacity:v3.9.33
docker pull registry.access.redhat.com/openshift3/ose-deployer:v3.9.33
docker pull registry.access.redhat.com/openshift3/ose-docker-builder:v3.9.33
docker pull registry.access.redhat.com/openshift3/ose-docker-registry:v3.9.33
docker pull registry.access.redhat.com/openshift3/ose-egress-http-proxy:v3.9.33
docker pull registry.access.redhat.com/openshift3/ose-egress-router:v3.9.33
docker pull registry.access.redhat.com/openshift3/ose-f5-router:v3.9.33
docker pull registry.access.redhat.com/openshift3/ose-haproxy-router:v3.9.33
docker pull registry.access.redhat.com/openshift3/ose-keepalived-ipfailover:v3.9.33
docker pull registry.access.redhat.com/openshift3/ose-pod:v3.9.33
docker pull registry.access.redhat.com/openshift3/ose-sti-builder:v3.9.33
docker pull registry.access.redhat.com/openshift3/ose-template-service-broker:v3.9.33
docker pull registry.access.redhat.com/openshift3/ose-web-console:v3.9.33
docker pull registry.access.redhat.com/openshift3/ose:v3.9.33
docker pull registry.access.redhat.com/openshift3/container-engine:v3.9.33
docker pull registry.access.redhat.com/openshift3/node:v3.9.33
docker pull registry.access.redhat.com/openshift3/openvswitch:v3.9.33
docker pull registry.access.redhat.com/rhel7/etcd

#Pull all of the required OpenShift Enterprise containerized components for the additional centralized log aggregation and metrics aggregation components:

docker pull registry.access.redhat.com/openshift3/logging-auth-proxy:v3.9.33
docker pull registry.access.redhat.com/openshift3/logging-curator:v3.9.33
docker pull registry.access.redhat.com/openshift3/logging-elasticsearch:v3.9.33
docker pull registry.access.redhat.com/openshift3/logging-fluentd:v3.9.33
docker pull registry.access.redhat.com/openshift3/logging-kibana:v3.9.33
docker pull registry.access.redhat.com/openshift3/oauth-proxy:v3.9.33
docker pull registry.access.redhat.com/openshift3/metrics-cassandra:v3.9.33
docker pull registry.access.redhat.com/openshift3/metrics-hawkular-metrics:v3.9.33
docker pull registry.access.redhat.com/openshift3/metrics-hawkular-openshift-agent:v3.9.33
docker pull registry.access.redhat.com/openshift3/metrics-heapster:v3.9.33
docker pull registry.access.redhat.com/openshift3/prometheus:v3.9.33
docker pull registry.access.redhat.com/openshift3/prometheus-alert-buffer:v3.9.33
docker pull registry.access.redhat.com/openshift3/prometheus-alertmanager:v3.9.33
docker pull registry.access.redhat.com/openshift3/prometheus-node-exporter:v3.9.33
docker pull registry.access.redhat.com/cloudforms46/cfme-openshift-postgresql
docker pull registry.access.redhat.com/cloudforms46/cfme-openshift-memcached
docker pull registry.access.redhat.com/cloudforms46/cfme-openshift-app-utils
docker pull registry.access.redhat.com/cloudforms46/cfme-openshift-app
docker pull registry.access.redhat.com/cloudforms46/cfme-openshift-embedded-ansible
docker pull registry.access.redhat.com/cloudforms46/cfme-openshift-httpd
docker pull registry.access.redhat.com/cloudforms46/cfme-httpd-configmap-generator
docker pull registry.access.redhat.com/cloudforms46/cfme-openshift-app-ui
docker pull registry.access.redhat.com/rhgs3/rhgs-server-rhel7
docker pull registry.access.redhat.com/rhgs3/rhgs-volmanager-rhel7
docker pull registry.access.redhat.com/rhgs3/rhgs-gluster-block-prov-rhel7
docker pull registry.access.redhat.com/rhgs3/rhgs-s3-server-rhel7

#For the service catalog, OpenShift Ansible broker, and template service broker features

docker pull registry.access.redhat.com/openshift3/ose-service-catalog:v3.9.33
docker pull registry.access.redhat.com/openshift3/ose-ansible-service-broker:v3.9.33
docker pull registry.access.redhat.com/openshift3/mediawiki-apb:v3.9.33
docker pull registry.access.redhat.com/openshift3/postgresql-apb:v3.9.33

#Preparing images to export

mkdir -p /var/www/html/repos/images

cd /var/www/html/repos/images

docker save -o ose3-images.tar \
    registry.access.redhat.com/openshift3/ose-ansible \
    registry.access.redhat.com/openshift3/ose-ansible-service-broker \
    registry.access.redhat.com/openshift3/ose-cluster-capacity \
    registry.access.redhat.com/openshift3/ose-deployer \
    registry.access.redhat.com/openshift3/ose-docker-builder \
    registry.access.redhat.com/openshift3/ose-docker-registry \
    registry.access.redhat.com/openshift3/ose-egress-http-proxy \
    registry.access.redhat.com/openshift3/ose-egress-router \
    registry.access.redhat.com/openshift3/ose-f5-router \
    registry.access.redhat.com/openshift3/ose-haproxy-router \
    registry.access.redhat.com/openshift3/ose-keepalived-ipfailover \
    registry.access.redhat.com/openshift3/ose-pod \
    registry.access.redhat.com/openshift3/ose-sti-builder \
    registry.access.redhat.com/openshift3/ose-template-service-broker \
    registry.access.redhat.com/openshift3/ose-web-console \
    registry.access.redhat.com/openshift3/ose \
    registry.access.redhat.com/openshift3/container-engine \
    registry.access.redhat.com/openshift3/node \
    registry.access.redhat.com/openshift3/openvswitch \
    registry.access.redhat.com/openshift3/prometheus \
    registry.access.redhat.com/openshift3/prometheus-alert-buffer \
    registry.access.redhat.com/openshift3/prometheus-alertmanager \
    registry.access.redhat.com/openshift3/prometheus-node-exporter \
    registry.access.redhat.com/cloudforms46/cfme-openshift-postgresql \
    registry.access.redhat.com/cloudforms46/cfme-openshift-memcached \
    registry.access.redhat.com/cloudforms46/cfme-openshift-app-ui \
    registry.access.redhat.com/cloudforms46/cfme-openshift-app \
    registry.access.redhat.com/cloudforms46/cfme-openshift-embedded-ansible \
    registry.access.redhat.com/cloudforms46/cfme-openshift-httpd \
    registry.access.redhat.com/cloudforms46/cfme-httpd-configmap-generator \
    registry.access.redhat.com/rhgs3/rhgs-server-rhel7 \
    registry.access.redhat.com/rhgs3/rhgs-volmanager-rhel7 \
    registry.access.redhat.com/rhgs3/rhgs-gluster-block-prov-rhel7 \
    registry.access.redhat.com/rhgs3/rhgs-s3-server-rhel7 \
    registry.access.redhat.com/openshift3/ose-service-catalog \
    registry.access.redhat.com/openshift3/ose-ansible-service-broker \
    registry.access.redhat.com/openshift3/mediawiki-apb \
    registry.access.redhat.com/openshift3/postgresql-apb

echo "DONE LOADING OSE IMAGES"

docker save -o ose3-logging-metrics-images.tar \
    registry.access.redhat.com/openshift3/logging-auth-proxy \
    registry.access.redhat.com/openshift3/logging-curator \
    registry.access.redhat.com/openshift3/logging-elasticsearch \
    registry.access.redhat.com/openshift3/logging-fluentd \
    registry.access.redhat.com/openshift3/logging-kibana \
    registry.access.redhat.com/openshift3/metrics-cassandra \
    registry.access.redhat.com/openshift3/metrics-hawkular-metrics \
    registry.access.redhat.com/openshift3/metrics-hawkular-openshift-agent \
    registry.access.redhat.com/openshift3/metrics-heapster

echo "DONE LOADING LOGGING AND METRICS IMAGES"

#Configure httpd server

chmod -R +r /var/www/html/repos
restorecon -vR /var/www/html
systemctl enable firewalld
systemctl start firewalld
firewall-cmd --permanent --add-service=http
firewall-cmd --reload
systemctl enable httpd
systemctl start httpd
