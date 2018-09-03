#!/bin/sh
ips_master=$(echo $1 | tr "," "\n")
for i in $ips_master
do
  ssh root@$i 'bash -s' < /tmp/scripts/post_install_master.sh
done

ips_nodes=$(echo $2 | tr "," "\n")
for i in $ips_nodes
do
  ssh root@$i 'bash -s' < /tmp/scripts/post_install_node.sh
done
