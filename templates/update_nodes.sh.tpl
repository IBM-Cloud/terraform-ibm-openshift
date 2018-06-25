#!/bin/sh
echo "Execute the pre-install steps"
subscription-manager repos --enable="rhel-7-server-extras-rpms"
rm -fr /var/cache/yum/*
yum clean all
yum -y update
yum install -y wget vim-enhanced net-tools bind-utils tmux git iptables-services bridge-utils docker etcd
systemctl start docker
wget http://${bastion_public_ip}/repos/images/ose3.6-images.tar
docker load -i ose3.6-images.tar
sed -i 's/=permissive/=enforcing/g' /etc/selinux/config
systemctl enable NetworkManager
systemctl start NetworkManager