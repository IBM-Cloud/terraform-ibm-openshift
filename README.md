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

2. Provision the infrastructure using the following command
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

## 2. Setup REDHAT Repositories and images for the disconnected installation

Install the repos and images by running :

  ``` console
    $ make rhn_username=<rhn_username> rhn_password=<rhn_password> bastion
  ```
Where, the rhn_username and rhn_password are the username & password of the Red Hat® Network subscription.

This step includes the following: 
 * Register the Bastion node to the Red Hat® Network, 
 * Prepare the Bastion node as the local repository (with rpms & container images), to install OpenShift in the rest of the nodes

## 3. Deploy OpenShift Container Platform on IBM Cloud Infrastrcture

To install OpenShift on the cluster, just run:
   ``` console
   $ make openshift
   ```

This step includes the following: 
* Prepare the Master, Infra & App nodes before installing OpenShift
* Finally, install OpenShift Container Platform v3.6 using the disconnected & quick installation procedure described [here]( https://docs.openshift.com/container-platform/3.6/install_config/install/disconnected_install.html). 


Once the setup is complete, just run:

   ``` console
   $ open https://$(terraform output master_private_ip):8443/console
   ```

To open a browser to admin console, use the following credentials to login:
   ``` console
   Username: admin
   Password: test123
   ```

## Work with OpenShift

* Login to the master node

  ``` console
   $ ssh -t -A root@$(terraform output bastion_public_ip) ssh root@$(terraform output master_private_ip)
  ```
Default project is in use and the core infrastructure components (router etc) are available.

* Login to openshift client by running

  ``` console
    $ oc login https://$(terraform output master_private_ip):8443
  ```
Provide username as admin and password as test123 to login to the opeshift client.

* Create new project

  ``` console
   $ oc new-project test

  ```

* Deploy the app 

  ``` console
   $ oc new-app --name=nginx --docker-image=bitnami/nginx

  ```
* Expose the service 

  ``` console
   $ oc expose svc/nginx

  ```
* Edit the service to use nodePort by changing type as NodePort

  ``` console
   $ oc edit svc/nginx

  ```
Access the deployed application at http${nodeIP}:${nodePort}


## Destroy the OpenShift cluster

Bring down the openshift cluster by running following

  ``` console
   $ terraform destroy

  ```
  
## Troubleshooting

\[Work in Progress\]

# References

* https://github.com/dwmkerr/terraform-aws-openshift - Inspiration for this project
  
* https://github.com/ibm-cloud/terraform-provider-ibm - Terraform Provider for IBM Cloud  
  
* [Deploying OpenShift Container Platform 3.6](https://docs.openshift.com/container-platform/3.6/install_config/install/quick_install.html)

* [To create more users and provide admin priviledge](https://docs.openshift.com/container-platform/3.6/install_config/configuring_authentication.html#install-config-configuring-authentication)

* [Accessing openshift registry](https://docs.openshift.com/container-platform/3.6/install_config/configuring_authentication.html#install-config-configuring-authentication)

* [Refer Openshift Router](https://docs.openshift.com/container-platform/3.6/install_config/router/index.html#install-config-router-overview)

