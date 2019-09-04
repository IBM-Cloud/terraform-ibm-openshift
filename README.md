# terraform-ibm-openshift

Use this project to set up Red Hat® OpenShift Container Platform 3.11 on IBM Cloud, using Terraform.

## Overview
Deployment of 'OpenShift Container Platform on IBM Cloud' is divided into separate steps.
	
* Step 1: Provision the infrastructure on IBM Cloud <br>
  Use Terraform to provision the compute, storage, network, load balancers & IAM resources on IBM Cloud Infrastructure
  
* Step 2: Deploy OpenShift Container Platform on IBM Cloud <br>
  Install OpenShift Container Platform which is done using the Ansible playbooks - available in the https://github.com/openshift/openshift-ansible project. 
  During this phase the router and registry are deployed.
  
* Step 3: Post deployment activities <br>
  Validate the deployment

The following figure illustrates the deployment architecture for the 'OpenShift Container Platform on IBM Cloud'.

![Infrastructure Diagram](./docs/infra-diagram.png)

## Prerequisite

* Docker image for the [Terraform & IBM Cloud Provider](https://github.com/ibm-cloud/terraform-provider-ibm#docker-image-for-the-provider) 



* IBM Cloud account (used to provision resources on IBM Cloud Infrastructure or SoftLayer)

* RedHat Account with openshift subscription.

## Steps to bringup the docker container with IBMCloud Terraform Provider

* Get the latest ibmcloud terraform provider image using the following command:
    
    ``` console
    # Pull the docker image
    $ docker pull ibmterraform/terraform-provider-ibm-docker
    ```
* Bring up the container using the docker image using the following command:

    ``` console
    # Run the container
    $ docker run -it ibmterraform/terraform-provider-ibm-docker:latest
    ```
    
## Steps to execute inside the docker container

### 1. Setup the IBM Terraform Openshift Project

* Install ssh package

  ``` console
    # Install ssh package
    $ apk add --no-cache openssh
  ```

* Clone the repo [IBM Terraform Openshift](https://github.com/IBM-Cloud/terraform-ibm-openshift) 

    ``` console
    # Clone the repo
    $ git clone https://github.com/IBM-Cloud/terraform-ibm-openshift.git
    $ cd terraform-ibm-openshift/
    ```

* Generate the private and public key pair which is required to provision the   virtual machines in softlayer.(Put the private key inside ~/.ssh/id_rsa).Follow the instruction [here](https://help.github.com/articles/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent/) to generate ssh key pair


### 2. Provision the IBM Cloud Infrastructure for Red Hat® OpenShift

* Update variables.tf file 

* Provision the infrastructure using the following command

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
* Storage node (if enabled for glusterfs configuration)
* Security groups for these nodes


On successful completion, you will see the following message
   ```
   ...

   Apply complete! Resources: 63 added, 0 changed, 0 destroyed.
   
   ```

### 3. Setup Red Hat® Repositories and images

* Install the repos and images by running :

  ``` console
    $ make rhn_username=<rhn_username> rhn_password=<rhn_password> pool_id=<pool_id> rhnregister
  ```

This step includes the following: 
 * Register the nodes to the Red Hat® Network, 
 
### 4. Deploy OpenShift Container Platform on IBM Cloud Infrastructure

To install OpenShift on the cluster, just run:
   ``` console
   $ make openshift
   ```

This step includes the following: 
* Prepare the Master, Infra and App nodes before installing OpenShift
* Finally, install OpenShift Container Platform v3.

using installation procedure described [here]( https://docs.openshift.com/container-platform/3.11/install/running_install.html). 


Once the setup is complete, just run:

   ``` console
   $ open https://$(terraform output master_public_ip):8443/console
   ```
Note: Add IP and Host Entry in /etc/hosts
 
This figure illustrates the 'Red Hat Openshift Console'

![Openshift Console](https://github.com/IBM-Cloud/terraform-ibm-openshift/blob/master/docs/ose-console-3.9.png)

To open a browser to admin console, use the following credentials to login:
   ``` console
   Username: admin
   Password: test123
   ```

## Work with OpenShift

* Login to the master node

  ``` console
   $ ssh -t -A root@$(terraform output master_public_ip)
  ```
  Default project is in use and the core infrastructure components (router etc) are available.

* Login to openshift client by running

  ``` console
    $ oc login https://$(terraform output master_public_ip):8443
  ```

  Provide username as admin and password as test123 to login to the openshift client.

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

  Access the deployed application at 

  ``` console
   $ oc get routes

  ```

  ```
  {HOST/PORT} get the value from above command
  Access the deployed application at http${HOST/PORT}

  ```

## Optional Commands

Run `make nodeprivate` to block all incoming traffic on public interface, to the infra nodes and app nodes

Run `make nodepublic` to allow all incoming traffic on public interface, to the infra nodes and app nodes

## Destroy the OpenShift cluster

Bring down the openshift cluster by running following

  ``` console
   $ make destroy

  ```
  
## Troubleshooting

\[Work in Progress\]

# References

* https://github.com/dwmkerr/terraform-aws-openshift - Inspiration for this project
  
* https://github.com/ibm-cloud/terraform-provider-ibm - Terraform Provider for IBM Cloud  
  
* [Deploying OpenShift Container Platform 3.11](https://docs.openshift.com/container-platform/3.11/install/index.html)

* [To create more users and provide admin privilege](https://docs.openshift.com/container-platform/3.11/install_config/configuring_authentication.html)

* [Accessing openshift registry](https://docs.openshift.com/container-platform/3.11/install_config/registry/index.html)

* [Refer Openshift Router](https://docs.openshift.com/container-platform/3.11/install_config/router/index.html)

