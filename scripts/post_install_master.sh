#!/bin/sh

# Create an htpasswd file, we'll use htpasswd auth for OpenShift.
htpasswd -cb /etc/origin/master/htpasswd admin test123

#Update the docker config to allow OpenShift's local insecure registry. 
sed -i '/OPTIONS=.*/c\OPTIONS="--selinux-enabled --insecure-registry 172.30.0.0/16 --log-driver=json-file --log-opt max-size=1M --log-opt max-file=3"' /etc/sysconfig/docker
systemctl restart docker
