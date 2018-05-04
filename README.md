# terraform-ibm-openshift

Use this project to set up Red Hat® OpenShift Container Platform 3 on IBM Cloud, using Terraform.

## Overview
Deployment of 'OpenShift Container Platform on IBM Cloud' is divided into separate phases.
	
* Phase 1: Provision the infrastructure on IBM Cloud	Use Terraform to provision the compute, storage, network & IAM resources on IBM Cloud Infrastructure
* Phase 2: Deploy OpenShift Container Platform on IBM Cloud	Install OpenShift Container Platform which is done via Ansible playbooks - available in the https://github.com/openshift/openshift-ansible project. 
  During this phase the router and registry are deployed.
* Phase 3: Post deployment activities	Validate the deployment

The following figure illustrates the deployment architecture for the 'OpenShift Container Platform on IBM Cloud'.
[TODO: Attach figure]

## Prerequisite

* Docker image for the [Terraform & IBM Cloud Provider](https://github.com/ibm-cloud/terraform-provider-ibm#docker-image-for-the-provider) 
* IBM Cloud account (used to provision resources on IBM Cloud Infrastructure or SoftLayer)


## Provison the IBM Cloud Infrastrcture for Red Hat OpenShift

1. Review and update the variables.tf file 
1. Provision the infrastructure using the following command
   ``` console
   # Create the infrastructure.
   $ make infrastructure
   ```
Refer to the documentation [here](), for details about the infrastructure elements being provisioned for OpenShift.

* On successful completion, you will see the following message
   ``` console
   ...

   Apply complete! Resources: 20 added, 0 changed, 0 destroyed.
   ```

## Installing Red Hat OpenShift on IBM Cloud Infrastrcture
The Red Hat OpenShift will be deployed using the disconnected installation procedure described [here]( https://docs.openshift.com/container-platform/3.6/install_config/install/disconnected_install.html), since the Master & App nodes do not have Internet connectivity. 

The Bastion node has access to the Internet, and it is used to manually download the software rpms and container images. The Master, Infra & App nodes are configured to use the Bastion node a local-repository to install the respective components.

### Prepare to install Red Hat OpenShift

1. SSH into the Bastion node
  
   ``` console
   $ make ssh-bastion
   bastion$ 
   ```
1. You have to setup the RHEL subscription, for disconnected install of OpenShift from Bastion node - using the following procedure:
   
   ``` console
   bastion$ subscription-manager unregister
   bastion$ rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-release
   bastion$ subscription-manager register --serverurl subscription.rhsm.redhat.com:443/subscription --baseurl cdn.redhat.com -u <username> -p <password>
   bastion$ subscription-manager attach --pool=8a85f98c604ec2e20160514b45352fb0
   bastion$ subscription-manager repos --disable="*"
   bastion$ subscription-manager repos --enable="rhel-7-server-rpms" --enable="rhel-7-server-extras-rpms" --enable="rhel-7-server-optional-rpms" --enable="rhel-7-server-ose-3.6-rpms"
   ```
1. Setup Bastion as the local-repo for installing OpenShift, by running the following
   
   ``` console
   # Setup local-repo in bastion node
   bastion$ setup-bastion-repo.sh
   ```


### Install Red Hat OpenShift

To install OpenShift on the cluster, just run:
   ``` console
   $ make openshift
   ```

Once the setup is complete, just run:

   ``` console
   $ make browse-openshift
   ```

To open a browser to admin console, use the following credentials to login:
   ``` console
   Username: admin
   Password: 123
   ```

## Post-install configuration of Red Hat 

\[Work in Progress\]

## Work with OpenShift

\[Work in Progress\]

## Destroy the OpenShift cluster

\[Work in Progress\]

## Troubleshooting

\[Work in Progress\]

# References

\[Work in Progress\]
