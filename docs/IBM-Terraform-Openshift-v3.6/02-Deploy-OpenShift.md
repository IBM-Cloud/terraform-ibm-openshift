# Abstract

The purpose of this document is to provide guidelines and considerations to Deploy & Manage a reference implementation of Red Hat OpenShift Container Platform on IBM Cloud

Refer to https://github.com/IBMTerraform/terraform-ibm-openshift/blob/master/docs/01-Provision-Infra.md for guidelines and considerations to provision the underlying IBM Cloud Infrastructure to deploy the Red Hat OpenShift Container Platform.

## Summary
Red Hat® OpenShift Container Platform 3 is built around a core of application containers, with orchestration and management provided by Kubernetes, on a foundation of Atomic Host and Red Hat Enterprise Linux. OpenShift Origin is the upstream community project that brings it all together along with extensions, to accelerate application development and deployment.
This reference environment provides an example of how OpenShift Container Platform 3 can be set up to take advantage of the native high availability capabilities of Kubernetes and IBM Cloud in order to create a highly available OpenShift Container Platform 3 environment. The configuration consists of 
* one OpenShift Container Platform *masters*, 
* three OpenShift Container Platform *infrastructure nodes*, 
* two OpenShift Container Platform *application nodes*, and
* native IBM Cloud Infrastructure services. 

## Deployment Approach

Deployment of 'OpenShift Container Platform on IBM Cloud' is divided into separate phases.

| Phase |  |
|----|-----|
| Phase 1: Provision the infrastructure on IBM Cloud |  Use Terraform to provision the compute, storage, network & IAM resources on IBM Cloud Infrastructure|
| Phase 2: Deploy OpenShift Container Platform on IBM Cloud | Install OpenShift Container Platform which is done via Ansible playbooks - available in the https://github.com/openshift/openshift-ansible project. <br> During this phase the router and registry are deployed. |
| Phase 3: Post deployment activities |  Validate the deployment |

----

# Phase 1: Provision Infrastructure 

Refer to details here: https://github.com/IBMTerraform/terraform-ibm-openshift/blob/master/docs/01-Provision-Infra.md

----

# Phase 2: Deploy OpenShift on IBM Cloud

## 2.1 Prerequisites for OpenShift Install 
(ref: https://docs.openshift.com/container-platform/3.6/install_config/install/prerequisites.html)  All these steps must be performed manually.

2.1.1 Node sizing
Refer to minimum hardware requirements from here: https://docs.openshift.com/container-platform/3.6/install_config/install/prerequisites.html#hardware

2.1.2 Docker version
      OpenShift Container Platform 3.6 requires Docker 1.12.

2.1.3 Verify that hosts can be resolved by the DNS server:
Follow the steps described here (https://docs.openshift.com/container-platform/3.6/install_config/install/prerequisites.html#wildcard-dns-prereq)

2.1.4 Verify the DNS wildcard is configured:
Follow the steps described here (https://docs.openshift.com/container-platform/3.6/install_config/install/prerequisites.html#wildcard-dns-prereq)

## 2.2. Deploy OpenShift
The Master, Infra & App nodes are deployed in the Private VLAN, hence do not have access to the Internet.  The OpenShift Container Platform will be deployed using the disconnected & quick installation procedure described [here](https://docs.openshift.com/container-platform/3.6/install_config/install/disconnected_install.html).  

The Bastion node is deployed on the Public VLAN, and has access to the Internet.  The Bastion node also has connectivity to the Private VLAN used by the Master, Infra & App nodes.  Hence, the Bastion node is configured to download all the software images required to perform a disconnected installation of the OpenShift Container Platform on the Master, Infra & App nodes.

The Master, Infra & App nodes are configured to use the Bastion node a local-repository to install the respective components.

2.2.1  Prepare the Bastion Server

Setup the RHEL subscription, for disconnected install of OpenShift from Bastion Server.  Prepare the local-repo in the Bastion server, for installing OpenShift

   ```console
   # Prepare the bastion server
   $ make bastion
   ```

2.2.2  Install openshift

Prepare the Master, Infra & App nodes, before installing OpenShift. Install OpenShift

   ```console
   # Install OpenShift
   $ make openshift
   ```

# Phase 3: Post Deployment activities

2.3.1 Add authentication

At the end of the above disconnected & quick OpenShift deployment

1. Authentication is set to `Deny All`, by default; follow the procedure outlined [here](https://docs.openshift.com/container-platform/3.6/install_config/configuring_authentication.html#install-config-configuring-authentication) to create users and provide Administrator access.  
1. Docker register is automatically deployed; follow the procedure [here](https://docs.openshift.com/container-platform/3.6/install_config/registry/index.html#install-config-registry-overview) to configure the Registry. 
1. Router is automatically deployed; follow the procedure [here](https://docs.openshift.com/container-platform/3.6/install_config/router/index.html#install-config-router-overview) to configure the Router.
