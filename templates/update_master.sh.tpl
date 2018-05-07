#!/bin/sh

wget http://${bastion_public_ip}/repos/images/ose3-logging-metrics-images.tar
docker load -i ose3-logging-metrics-images.tar
echo "done"
