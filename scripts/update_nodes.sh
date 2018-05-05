#!/bin/sh
echo "Execute the pre-install steps"
yum -y update
yum install -y wget vim-enhanced net-tools bind-utils tmux git iptables-services bridge-utils
systemctl start docker
wget http://<bastion_address>/images/ose3.6-images.tar
docker load -i ose3-images.tar
systemctl enable NetworkManager
systemctl start NetworkManager
echo "done"