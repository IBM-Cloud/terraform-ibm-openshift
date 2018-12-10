## Abstract
This article provide guidelines and considerations to provision the IBM Cloud Infrastructure to deploy a reference implementation of Red Hat® OpenShift Container Platform 3.

Refer to https://github.com/IBMTerraform/terraform-ibm-openshift/blob/master/docs/02-Deploy-OpenShift.md to Deploy & Manage the Red Hat® OpenShift Container Platform on IBM Cloud.

## Summary
Red Hat® OpenShift Container Platform 3 is built around a core of application containers, with orchestration and management provided by Kubernetes, on a foundation of Atomic Host and Red Hat® Enterprise Linux. OpenShift Origin is the upstream community project that brings it all together along with extensions, to accelerate application development and deployment.
This reference environment provides an example of how OpenShift Container Platform 3 can be set up to take advantage of the native high availability capabilities of Kubernetes and IBM Cloud in order to create a highly available OpenShift Container Platform 3 environment. The configuration consists of 
* one OpenShift Container Platform *masters*, 
* three OpenShift Container Platform *infrastructure nodes*, 
* two OpenShift Container Platform *application nodes*, and
* native IBM Cloud Infrastructure services. 

## Deployment Approach

Deployment of 'OpenShift Container Platform on IBM Cloud' is divided into separate phases.

| Phase |  |
|----|-----|
| Phase 1: Provision the infrastructure on IBM Cloud |  Use Terraform to provision the compute, storage, network, loadbalancers & IAM resources on IBM Cloud Infrastructure|
| Phase 2: Deploy OpenShift Container Platform on IBM Cloud | Install OpenShift Container Platform which is done via Ansible playbooks - available in the [openshift-ansible](https://github.com/openshift/openshift-ansible) project. <br> During this phase the router and registry are deployed. |
| Phase 3: Post deployment activities |  Validate the deployment |

----

# Phase 1: Provision Infrastructure 
The following figure illustrates the deployment architecture for the 'OpenShift Container Platform on IBM Cloud'.
![Infrastructure topology](./infra-diagram.png)

Use the variables.tf file to configure the following: 

## Variables

|Variable Name|Description|Default Value|
|-------------|-----------|-------------|
|ibm_sl_username|User Name to login to IBM Cloud Infra (Softlayer)|-|
|ibm_sl_api_key|API Key (or password) to access IBM Cloud Infra (Softlayer). You can run `bluemix cs locations` to see a list of all data centers in your region.|-|
|rhn_username|Red Hat Network username with OpenShift subscription.|-|
|rhn_password|Red Hat Network password with OpenShift subscription.|-|
|datacenter|Data Center Location to deploy the OpenShift cluster.|dal05|
|vlan_count       |Create a private & public VLAN, in your account, for deploying Red Hat OpenShift. Default '1'. Set to '0' if use existing vlans id and '1' to deploy new vlan|1|
|private_vlanid|Existing private vlan ID.|-|
|public_vlanid|Existing public vlan ID.|-|
|infra_count|Number of Infra nodes for the cluster.|1|
|app_count|Number of app nodes for the cluster. |1|
|ssh_private_key|Path to SSH private key.|~/.ssh/id_rsa|
|ssh_label|An identifying label to assign to the SSH key.|ssh_key_openshift|
|ssh_public_key|Path to SSH public key.|~/.ssh/id_rsa.pub|
|vm_domain|Domain Name for the network interface used by VMs in the cluster.|ibm.com|
|bastion_flavor|Flavor used to create Bastion VM|B1_4X8X100|
|master_flavor|Flavor used to create Master node|B1_4X8X100|
|infra_flavor|Flavor used to create Infra nodes|B1_4X8X100|
|app_flavor|Flavor used to create app nodes|B1_4X8X100|
|app_lbass_name|Name of the local load balancer for app nodes|openshift-app|
|infra_lbass_name|Name of the local load balancer for infra nodes|openshift-infra|


The infrastructure is provisioned using the terraform modules with the following configuration:

## Nodes

Nodes are VM_instances that serve a specific purpose for OpenShift Container Platform

***Master nodes***

* Contains the API server, controller manager server and etcd.
* Maintains the clusters configuration, manages nodes in its OpenShift cluster
* Assigns pods to nodes and synchronizes pod information with service configuration
* Used to define routes, services, and volume claims for pods deployed within the OpenShift environment.

***Infrastructure nodes***

* Used for the router and registry pods
* Optionally, used for Kibana / Hawkular metrics
* Recommends S3 storage for the Docker registry, which allows for multiple pods to use the same storage

***Application nodes***

* Runs non-infrastructure based containers
* Use block storage to persist application data; assigned to the pod using a Persistent Volume Claim. 
* Nodes with the label app are nodes used for end user Application pods.
* Set a configuration parameter 'defaultNodeSelector: "role=app" on the master /etc/origin/master/master-config.yaml to ensures that OpenShift Container Platform user containers, will be placed on the application nodes by default.

**Bastion node:**

* The Bastion server provides a secure way to limit SSH access to the environment. 
* The master and node security groups only allow for SSH connectivity between nodes inside of the Security Group while the Bastion allows SSH access from everywhere. 
* The Bastion host is the only ingress point for SSH in the cluster from external entities. When connecting to the OpenShift Container Platform infrastructure, the bastion forwards the request to the appropriate server. Connecting through the Bastion server requires specific SSH configuration. 

**Compute node configurations**

|nodes | flavor | details | count |
|------|--------|---------|-------|
|Master Node | B1_4X8X100 | san disks: 100GB <ul><li> disk1 : 50 </li><li> disk2 : 25 </li><li>disk3 : 25 </li><ul> | master_count |
| Infra Nodes | B1_4X8X100 | san disks: 100GB <ul><li> disk1 : 50 </li><li> disk2 : 25 </li><li>disk3 : 25 </li><ul> | infra_count | 
| App Nodes | B1_4X8X100 | san disks: 100GB <ul><li> disk1 : 50 </li><li> disk2 : 25 </li><li>disk3 : 25 </li><ul> | app_count |
| Bastion Nodes | B1_4X8X100 | <ul><li>disk : 100GB </li><li>disk : 50GB </li><ul> | 1 |

## Load balancer configurations

|ALB|DNS name  (Openshift DNS)|Assigned Instances|Port|
|---|--------|------|-----|
|infra_llb|openshift-app-XXXXX-XXXXX-dal05.lb.bluemix.net|infra-nodes <br> 1-3|-|
|app_llb|openshift-app-XXXXX-XXXXX-dal05.lb.bluemix.net|app-nodes <br> 1-3|-|

A publicly-accessible, fully qualified domain name is assigned to your load balancer service instance. You must use this domain name to access your applications hosted behind the load balancer service.

## Security Group configurations
The following security group configuration assumes:
* All public traffic flow through the Internet Gateway
* The Bastion server provides a secure way to limit SSH access to the environment. 
* The Bastion server has connectivity with both the Public VLAN & Private VLAN.
* All the OpenShift nodes (Master, Infra & App nodes) are connected only to the Private VLAN.

|Group         |VLAN    |        |             |From     |To        |
|:-------------|:------:|:-------|:------------|:-------:|:--------:|
|ose_bastion_sg|Public  |Inbound | 22 / TCP    |Internet Gateway| - |
|ose_bastion_sg|Private |Outbound| All         | -       |All       |
|              |        |        |             |         |          |
|ose_master_sg |Private |Inbound | 443 / TCP   |Internet Gateway| - |
|ose_master_sg |Private |Inbound | 80 / TCP    |Internet Gateway| - |
|ose_master_sg |Private |Inbound | 22 / TCP    |ose_bastion_sg | - |
|ose_master_sg |Private |Inbound | 443 / TCP   |All <br> (ose_master_sg & ose_node_sg) | - |
|ose_master_sg |Private |Inbound | 8053 / TCP  |All <br> (ose_node_sg) | - |
|ose_master_sg |Private |Inbound | 8053 / UDP  |All <br> (ose_node_sg) | - |
|ose_master_sg |Private |Outbound|  All        | -       | All      |
|ose_master_sg <br> (for etcd) |Private |Inbound | 2379 / TCP | All <br> (ose-master-sg) | - |
|ose_master_sg <br> (for etcd) |Private |Inbound | 2380 / TCP | All <br> (ose-master-sg) | - |
|              |        |        |             |         |          |
| ose_node_sg  |Private |Inbound | 443 / TCP   |All <br> (ose_bastion_sg) | - |
| ose_node_sg  |Private |Inbound | 22 / TCP    |All <br> (ose_bastion_sg) | - |
| ose_node_sg  |Private |Inbound | 10250 / TCP |All <br> (ose_master_sg & ose_node_sg) | - |
| ose_node_sg  |Private |Inbound | 4789 / UDP  |All <br> (ose_node_sg) | - |
| ose_node_sg  |Private |Outbound| All         | -       |      All |
|              |        |        |             |         |          |

## DNS Configuration

OpenShift Compute Platform requires a fully functional DNS server, and is properly configured wildcard DNS zone that resolves to the IP address of the OpenShift router. By default, *dnsmasq* is automatically configured on all masters and nodes to listen on port 53. The pods use the nodes as their DNS, and the nodes forward the requests.

## Software Version Details

***RHEL OSEv3 Details***

|Software|Version|
|-------|--------|
|Red Hat® Enterprise Linux 7.4 x86_64| kernel-3.10.0.x|
|Atomic-OpenShift <br>{master/clients/node/sdn-ovs/utils} | 3.6.x.x |
|Docker|1.12.x|
|Ansible|2.3.2.x|

***Required Channels***

A subscription to the following channels is required in order to deploy this reference environment’s configuration.

|Channel|Repository Name|
|-------|---------------|
|Red Hat® Enterprise Linux 7 Server (RPMs)|rhel-7-server-rpms|
|Red Hat® OpenShift Enterprise 3.6 (RPMs)|rhel-7-server-ose-3.6-rpms|
|Red Hat® Enterprise Linux 7 Server - Extras (RPMs)|rhel-7-server-extras-rpms|
|Red Hat® Enterprise Linux 7 Server - Fast Datapath (RPMs) |rhel-7-fast-datapath-rpms|

----

# Phase 2: Deploy OpenShift

Refer to details here: https://github.com/IBMTerraform/terraform-ibm-openshift/blob/master/docs/02-Deploy-OpenShift.md

----
