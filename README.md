# terraform-ibm-openshift

Use this project to set up Red Hat® OpenShift Container Platform 3 on IBM Cloud, using Terraform.

## Overview
Deployment of 'OpenShift Container Platform on IBM Cloud' is divided into separate steps.
	
* Step 1: Provision the infrastructure on IBM Cloud <br>
  Use Terraform to provision the compute, storage, network & IAM resources on IBM Cloud Infrastructure
  
* Step 2: Deploy OpenShift Container Platform on IBM Cloud <br>
  Install OpenShift Container Platform which is done using the Ansible playbooks - available in the https://github.com/openshift/openshift-ansible project. 
  During this phase the router and registry are deployed.
  
* Step 3: Post deployment activities <br>
  Validate the deployment

The following figure illustrates the deployment architecture for the 'OpenShift Container Platform on IBM Cloud'.

![Infrastructure Diagram](https://github.com/IBMTerraform/terraform-ibm-openshift/blob/master/docs/infra-diagram.png)

`Note:` This version illustrates the deployment of a very basic architecture of Red Hat® OpenShift Container Platform on IBM Cloud.  The [article](https://github.com/IBMTerraform/terraform-ibm-openshift/blob/master/docs/01-Provision-Infra.md) describes reference implementation of Red Hat® OpenShift Container Platform on IBM Cloud Infrastructure.

## Prerequisite

* Docker image for the [Terraform & IBM Cloud Provider](https://github.com/ibm-cloud/terraform-provider-ibm#docker-image-for-the-provider) 



* IBM Cloud account (used to provision resources on IBM Cloud Infrastructure or SoftLayer)

## Steps to execute the project inside a docker image

* Get the latest ibmcloud terraform provider image using the following command:
    
    ``` console
    # Pull the docker image
    $ docker pull ibmterraform/terraform-provider-ibm-docker
    ```
* Bring up the container using the docker image

    ``` console
    # Run the container
    $ docker run -it ibmterraform/terraform-provider-ibm-docker:latest
    ```

* Clone the repo [IBM Terraform Openshift](https://github.com/IBMTerraform/terraform-ibm-openshift) 

    ``` console
    # Clone the repo
    $ git clone https://github.com/IBMTerraform/terraform-ibm-openshift.git
    $ cd terraform-ibm-openshift/
    ```

* Private key is required to do ssh to the machines.(Put the private key inside ~/.ssh/id_rsa)


## 1. Provison the IBM Cloud Infrastrcture for Red Hat® OpenShift

1. Review and update the variables.tf file 
1. Provision the infrastructure using the following command
   ``` console
   # Create the infrastructure.
   $ make infrastructure
   ```
Please provide softlayer username , password and ssh public key to proceed.

In this version, the following infrastructure elements are provisioned for OpenShift (as illustrated in the picture)
* Bastion node 
* Master node 
* Infra node
* App node
* Security groups for these nodes

On successful completion, you will see the following message
   ```
   ...

   Apply complete! Resources: 40 added, 0 changed, 0 destroyed.
   ```

## 2. Deploy OpenShift Container Platform on IBM Cloud Infrastrcture

To install OpenShift on the cluster, just run:
   ``` console
   $ make rhn_username=<rhn_username> rhn_password=<rhn_password> openshift
   ```

Where, the rhn_username and rhn_password are the username & password of the Red Hat® Network subscription.

This step includes the following: 
* Register the Bastion node to the Red Hat® Network, 
* Prepare the Bastion node as the local repository (with rpms & container images), to install OpenShift in the rest of the nodes
* Prepare the Master, Infra & App nodes before installing OpenShift
* Finally, install OpenShift Container Platform v3.6 using the disconnected & quick installation procedure described [here]( https://docs.openshift.com/container-platform/3.6/install_config/install/disconnected_install.html). 


Once the setup is complete, just run:

   ``` console
   $ make browse-openshift
   ```

To open a browser to admin console, use the following credentials to login:
   ``` console
   Username: admin
   Password: 123
   ```

## 3: Post deployment activities

At the end of the above disconnected & quick OpenShift deployment

1. Authentication is set to `Deny All`, by default; follow the procedure outlined [here](https://docs.openshift.com/container-platform/3.6/install_config/configuring_authentication.html#install-config-configuring-authentication) to create users and provide Administrator access.  
1. Docker register is automatically deployed; follow the procedure [here](https://docs.openshift.com/container-platform/3.6/install_config/registry/index.html#install-config-registry-overview) to configure the Registry. 
1. Router is automatically deployed; follow the procedure [here](https://docs.openshift.com/container-platform/3.6/install_config/router/index.html#install-config-router-overview) to configure the Router.


### Work with OpenShift

\[Work in Progress\]

## Destroy the OpenShift cluster

\[Work in Progress\]

## Troubleshooting

\[Work in Progress\]

# References

* https://github.com/dwmkerr/terraform-aws-openshift - Inspiration for this project
  
* https://github.com/ibm-cloud/terraform-provider-ibm - Terraform Provider for IBM Cloud  
  
* [Deploying OpenShift Container Platform 3.6](https://docs.openshift.com/container-platform/3.6/install_config/install/quick_install.html)

\[Work in Progress\]

