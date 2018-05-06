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
| Phase 1: Provision the infrastructure on IBM Cloud |  Use Terraform to provision the compute, storage, network & IAM resources on IBM Cloud Infrastructure|
| Phase 2: Deploy OpenShift Container Platform on IBM Cloud | Install OpenShift Container Platform which is done via Ansible playbooks - available in the https://github.com/openshift/openshift-ansible project. <br> During this phase the router and registry are deployed. |
| Phase 3: Post deployment activities |  Validate the deployment |

----

# Phase 1: Provision Infrastructure 
The following figure illustrates the deployment architecture for the 'OpenShift Container Platform on IBM Cloud'.
![Infrastructure topology](https://github.com/IBMTerraform/terraform-ibm-openshift/blob/master/docs/infra-diagram-2.png)

Use the variables.tf file to configure the following: 

* datacenter : dal05  (as an example)
* domain : cloudapps.example.com
* ssh_key & ssh_label
* infra_count: number of infrastructure nodes
* app_count: number of app nodes

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
|Master Node | B1_4X8X100 | san disks: 100GB <ul><li> disk1 : 50 </li><li> disk2 : 25 </li><li>disk3 : 25 </li><ul> | 1 |
| Infra Nodes | B1_2X4X100 | san disks: 100GB <ul><li> disk1 : 50 </li><li> disk2 : 25 </li><li>disk3 : 25 </li><ul> | infra_count | 
| App Nodes | B1_2X4X100 | san disks: 100GB <ul><li> disk1 : 50 </li><li> disk2 : 25 </li><li>disk3 : 25 </li><ul> | app_count |
| Bastion Nodes | B1_2X2X100 | <ul><li>disk : 100GB </li><li>disk : 50GB </li><ul> | 1 |

## Load balancer configurations

|ALB|DNS name  (Openshift DNS)|Assigned Instances|Port|
|---|--------|------|-----|
|master_llb|\<resourcegroupname\>.cloudapp.eg.com|master|8443|
|node_llb|\<wildcardzone\>.cloudapp.eg.com|infra-nodes <br> 1-3|80 and 443|

* The *master_llb* utilizes the OpenShift Container Platform master API port for communication 
* The *node_llb* uses the public subnets and maps to infrastructure nodes. 
* The infrastructure nodes run the router pod (ingress controller) which then directs traffic directly from the outside world into pods when external routes are defined.
* To avoid reconfiguring DNS every time a new route is created, an external wildcard DNSentry record must be configured pointing to the Router load balancer IP.
    * For example, create a wildcard DNS entry for cloudapp.example.com that has a low time-to-live value (TTL) and points to the public IP address of the Router load balancer

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
