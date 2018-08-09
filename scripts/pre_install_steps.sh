#!/bin/sh
ips=$(echo $1 | tr "," "\n")
for i in $ips
do
  ssh-keyscan -t rsa $i  >> ~/.ssh/known_hosts 
  scp /etc/hosts root@$i:/etc/hosts 
  scp /tmp/scripts/ose.repo root@$i:/etc/yum.repos.d/ose.repo
  ssh root@$i 'bash -s' < /tmp/scripts/update_nodes.sh
done
