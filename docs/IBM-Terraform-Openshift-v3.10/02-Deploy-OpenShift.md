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
| Phase 1: Provision the infrastructure on IBM Cloud |  Use Terraform to provision the compute, storage & network resources on IBM Cloud Infrastructure|
| Phase 2: Deploy OpenShift Container Platform on IBM Cloud | Install OpenShift Container Platform which is done via Ansible playbooks - available in the https://github.com/openshift/openshift-ansible project. <br> During this phase the router and registry are deployed. |
| Phase 3: Post deployment activities |  Validate the deployment |

----

# Phase 1: Provision Infrastructure 

Refer to details here: https://github.com/IBMTerraform/terraform-ibm-openshift/blob/master/docs/01-Provision-Infra.md

----

# Phase 2: Deploy OpenShift on IBM Cloud

## 2.1 Prerequisites for OpenShift Install 
(ref: https://docs.openshift.com/container-platform/3.10/install_config/install/prerequisites.html)  All these steps must be performed manually.

2.1.1 Node sizing
Refer to minimum hardware requirements from here: https://docs.openshift.com/container-platform/3.10/install_config/install/prerequisites.html#hardware

2.1.2 Docker version
      OpenShift Container Platform 3.10 requires Docker 1.13.

2.1.3 Verify that hosts can be resolved by the DNS server:
Follow the steps described here (https://docs.openshift.com/container-platform/3.10/install_config/install/prerequisites.html#wildcard-dns-prereq)

2.1.4 Verify the DNS wildcard is configured:
Follow the steps described here (https://docs.openshift.com/container-platform/3.10/install_config/install/prerequisites.html#wildcard-dns-prereq)

## 2.2. Deploy OpenShift
The Infra & App nodes are deployed in the Private VLAN, hence do not have access to the Internet.  The OpenShift Container Platform will be deployed using the procedure described [here](https://docs.openshift.com/container-platform/3.10/install/index.html#single-master-multi-node).  


2.2.1 Steps to find pool ID from Bastion node

Once the make infrastructure is successful we can find the Redhat Openshift Subscription pool ID from Bastion node.
   ```
   ssh root@$(terraform output bastion_public_ip)
   # Answer "yes" to security questions that are presented on first login
   
   subscription-manager unregister
   
   rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-release
   
   # Substitute your RH username and password for the two variables in the following line:
   
   subscription-manager register --serverurl subscription.rhsm.redhat.com:443/subscription --baseurl cdn.redhat.com --username $uid --password $pswd
   
   subscription-manager list --available --matches '*OpenShift Container Platform'
   # A 'Pool ID' should be listed in the output. Record that value.
   # Sample output:
   +-------------------------------------------+
    Available Subscriptions
+-------------------------------------------+
Subscription Name:   Red Hat OpenShift, Standard Support (10 Cores, NFR, Partner
                     Only)
Provides:            Red Hat Ansible Engine
                     Red Hat Software Collections (for RHEL Server for IBM Power
                     LE)
                     Red Hat OpenShift Enterprise Infrastructure
                     Red Hat JBoss Core Services
                     Red Hat Enterprise Linux Fast Datapath
                     Red Hat OpenShift Container Platform for Power
                     JBoss Enterprise Application Platform
                     Red Hat CloudForms
                     Red Hat Software Collections Beta (for RHEL Server for IBM
                     Power LE)
                     Red Hat OpenShift Container Platform Client Tools for Power
                     Red Hat Enterprise Linux Fast Datapath (for RHEL Server for
                     IBM Power LE)
                     Red Hat OpenShift Enterprise JBoss EAP add-on
                     Red Hat OpenShift Container Platform
                     Red Hat Enterprise Linux for Power, little endian Beta
                     Red Hat OpenShift Enterprise Client Tools
                     Red Hat CloudForms Beta
                     Oracle Java (for RHEL Server)
                     Red Hat Enterprise Linux for Power, little endian -
                     Extended Update Support
                     Red Hat Enterprise Linux Fast Datapath Beta for Power,
                     little endian
                     Red Hat Software Collections (for RHEL Server)
                     Red Hat Enterprise Linux for Power, little endian
                     Red Hat OpenShift Enterprise Application Node
                     Red Hat Enterprise Linux for Power 9
                     Oracle Java (for RHEL Server) - Extended Update Support
                     Red Hat Enterprise Linux Atomic Host
                     Red Hat JBoss AMQ Clients
                     Red Hat Enterprise Linux Fast Datapath Beta for x86_64
                     Red Hat Software Collections Beta (for RHEL Server)
                     Red Hat Enterprise Linux Server
                     JBoss Enterprise Web Server
                     Red Hat OpenShift Service Mesh
                     Red Hat Container Native Virtualization
SKU:                 SER0423
Contract:            11820681
Pool ID:             8a85f99967a2c0880167af1b2ded5d33
Provides Management: Yes
Available:           729
Suggested:           1
Service Level:       Standard
Service Type:        L1-L3
Subscription Type:   Stackable
Starts:              08/05/2018
Ends:                08/05/2019
System Type:         Physical
 ```

2.2.2  Prepare the nodes

Setup the RHEL subscription on all nodes

   ```console
   # Register the nodes
   $ make rhn_username=<rhn_username> rhn_password=<rhn_password> pool_id=<pool_id> rhnregister
   ```

2.2.3  Install openshift

Prepare the Master, Infra & App nodes, before installing OpenShift. Install OpenShift

   ```console
   # Install OpenShift
   $ make openshift
   ```


# Phase 3: Post Deployment activities

2.3.1 Add authentication

At the end of the above OpenShift deployment

1. Authentication is configured as htpasswd auth, by default; follow the procedure outlined [here](https://docs.openshift.com/container-platform/3.10/install_config/configuring_authentication.html) to create users and provide Administrator access.  
1. Docker register is automatically deployed; follow the procedure [here](https://docs.openshift.com/container-platform/3.10/install_config/registry/index.html#install-config-registry-overview) to configure the Registry. 
1. Router is automatically deployed; follow the procedure [here](https://docs.openshift.com/container-platform/3.10/install_config/router/index.html#install-config-router-overview) to configure the Router.
