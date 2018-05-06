#!/bin/bash
# Script to register with redhat and enable the packages required to install openshift on bastion machine.


# Unregister with softlayer subscription
subscription-manager unregister

rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-release

username=$1
password=$2

subscription-manager register --serverurl subscription.rhsm.redhat.com:443/subscription --baseurl cdn.redhat.com --username $username --password $password

sed -i 's/%(ca_cert_dir)skatello-server-ca.pem/%(ca_cert_dir)sredhat-uep.pem/g' /etc/rhsm/rhsm.conf

subscription-manager attach --pool=8a85f98c604ec2e20160514b45352fb0

subscription-manager repos --disable="*"

subscription-manager repos --enable="rhel-7-server-rpms"  --enable="rhel-7-server-extras-rpms"   --enable="rhel-7-server-optional-rpms" --enable="rhel-7-server-ose-3.6-rpms"
