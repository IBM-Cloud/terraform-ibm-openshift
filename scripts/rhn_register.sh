#!/bin/bash
# Script to register with redhat and enable the packages required to install openshift on bastion machine.


# Unregister with softlayer subscription
subscription-manager unregister

rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-release

username=$1
password=$2
#orgid=$1
#key=$2
poolID=$3

subscription-manager register --serverurl subscription.rhsm.redhat.com:443/subscription --baseurl cdn.redhat.com --username $username --password $password
#subscription-manager register --serverurl subscription.rhsm.redhat.com:443/subscription --baseurl cdn.redhat.com --org 7869572 --activationkey Test


subscription-manager refresh

sed -i 's/%(ca_cert_dir)skatello-server-ca.pem/%(ca_cert_dir)sredhat-uep.pem/g' /etc/rhsm/rhsm.conf

subscription-manager attach --pool=$poolID

subscription-manager repos --disable="*"

#yum-config-manager --disable \*


subscription-manager repos --enable="rhel-7-server-rpms"  --enable="rhel-7-server-extras-rpms"  --enable="rhel-7-server-ose-3.11-rpms" --enable="rhel-7-server-ansible-2.6-rpms" --enable="rhel-7-server-optional-rpms"


### The following has been moved to bastion_install_ansible.sh
#
########## Install OCP and its prerequisits
#
#yum clean all
#
#yum install -y wget git net-tools bind-utils yum-utils iptables-services bridge-utils bash-completion kexec-tools sos psacct
#
#yum install -y vim 
#
#yum install -y tmux
#
#yum update -y 
#
#yum install -y  openshift-ansible
#
####### Define the bastian as Gateway for all other nodes (disabled by Red Hat):
#
##sysctl net.ipv4.ip_forward=1
#

