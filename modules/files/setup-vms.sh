# OpenShift setup
# See: https://docs.openshift.org/latest/install_config/install/host_preparation.html

# Install packages required to setup OpenShift.
yum install -y wget git net-tools bind-utils iptables-services bridge-utils bash-completion httpd-tools
yum update -y

subscription-manager repos --enable="rhel-7-server-extras-rpms"

subscription-manager repos --enable="rhel-server-rhscl-7-rpms"

yum install -y docker

systemctl start docker

#echo Defaults:ibm-user \!requiretty >> /etc/sudoers
