## Abstract
This article provide guidelines and considerations to provision the IBM Cloud Infrastructure to deploy the Red Hat OpenShift Container Platform.

Refer to https://github.com/IBMTerraform/terraform-ibm-openshift/blob/master/docs/02-Deploy-OpenShift.md to Deploy & Manage the Red Hat OpenShift Container Platform on IBM Cloud.

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
The following figure illustrates the deployment architecture for the 'OpenShift Container Platform on IBM Cloud'.
![Infrastructure topology](https://github.com/IBMTerraform/terraform-ibm-openshift/blob/master/docs/infra-diagram-2.png)

Use the variables.tf file to configure the following: 

* datacenter : dal05  (as an example)
* domain : cloudapps.example.com
* ssh_key & ssh_label
* infra_count: number of infrastructure nodes
* app_count: number of app nodes

The infrastructure is provisioned using the terraform modules with the following configuration:
**Compute node configurations**

|   |   |  |
|---|---|--|
|Master Node | <ul><li>flavor: B1_4X8X100 </li><li> san disks: 100GB </li><ul><li> disk1 : 50 </li><li> disk2 : 25 </li><li>disk3 : 25 </li><ul><ul> | 1 |
| Infra Nodes | <ul><li>flavor: B1_2X4X100 </li><li> san disks: 100GB </li><ul><li> disk1 : 50 </li><li> disk2 : 25 </li><li>disk3 : 25 </li><ul><ul> | infra_count | 
| App Nodes | <ul><li>flavor: B1_2X4X100 </li><li> san disks: 100GB </li><ul><li> disk1 : 50 </li><li> disk2 : 25 </li><li>disk3 : 25 </li><ul><ul> | app_count |
| Bastion Nodes | <ul><li>flavor: B1_2X2X100 </li><ul><li> core : 2 </li><li> memory : 4096 </li><li>disk : 100GB </li><li>disk : 50GB </li><ul><ul> | 1 |

**Load balancers**

|ALB|DNS name  (Openshift DNS)|Assigned Instances|Port|
|---|--------|------|-----|
|master_llb|\<resourcegroupname\>.cloudapp.eg.com|master|8443|
|node_llb|\<wildcardzone\>.cloudapp.eg.com|infra-nodes <br> 1-3|80 and 443|

* The *master_llb* utilizes the OpenShift Container Platform master API port for communication 
* The *node_llb* uses the public subnets and maps to infrastructure nodes. 
* The infrastructure nodes run the router pod (ingress controller) which then directs traffic directly from the outside world into pods when external routes are defined.
* To avoid reconfiguring DNS every time a new route is created, an external wildcard DNSentry record must be configured pointing to the Router load balancer IP.
    * For example, create a wildcard DNS entry for cloudapp.example.com that has a low time-to-live value (TTL) and points to the public IP address of the Router load balancer

**Security Group**

|Group |    |   |From|To|
|:----|:---|:---|:----:|:---:|
|ose_bastion_sg|Inbound| 22 / TCP|Internet Gateway|-|
|ose_bastion_sg|Outbound|All|-|All|
|      |      |      |     |
|ose_master_sg | Inbound | 443 / TCP|Internet Gateway| - |
|ose_master_sg | Inbound | 22 / TCP | ose_bastion_sg | - |
|ose_master_sg | Inbound | 443 / TCP | All <br> (ose_master_sg & ose_node_sg) | - |
|ose_master_sg | Inbound | 8053 / TCP | All <br> (ose_node_sg) | - |
|ose_master_sg | Inbound | 8053 / UDP | All <br> (ose_node_sg) | - |
|ose_master_sg | Outbound |  All | - | All |
|ose_master_sg <br> (for etcd) | Inbound | 2379 / TCP | All <br> (ose-master-sg) | - |
|ose_master_sg <br> (for etcd) | Inbound | 2380 / TCP | All <br> (ose-master-sg) | - |
|      |      |      |     |
| ose_node_sg | Inbound | 443 / TCP | All <br> (ose_bastion_sg) | - |
| ose_node_sg | Inbound | 22 / TCP | All <br> (ose_bastion_sg) | - |
| ose_node_sg | Inbound | 10250 / TCP | All <br> (ose_master_sg & ose_node_sg) | - |
| ose_node_sg | Inbound | 4789 / UDP | All <br> (ose_node_sg) | - |
| ose_node_sg | Outbound |  All |  - | All |
|      |      |      |     |

**Bastion node:**

* The Bastion server provides a secure way to limit SSH access to the environment. 
* The master and node security groups only allow for SSH connectivity between nodes inside of the Security Group while the Bastion allows SSH access from everywhere. 
* The Bastion host is the only ingress point for SSH in the cluster from external entities. When connecting to the OpenShift Container Platform infrastructure, the bastion forwards the request to the appropriate server. Connecting through the Bastion server requires specific SSH configuration. 

**DNS Configuration**

OpenShift Compute Platform requires a fully functional DNS server, and is properly configured wildcard DNS zone that resolves to the IP address of the OpenShift router. By default, *dnsmasq* is automatically configured on all masters and nodes to listen on port 53. The pods use the nodes as their DNS, and the nodes forward the requests.

**Software Version Details**

***RHEL OSEv3 Details***

|Software|Version|
|-------|--------|
|Red Hat Enterprise Linux 7.4 x86_64| kernel-3.10.0.x|
|Atomic-OpenShift <br>{master/clients/node/sdn-ovs/utils} | 3.6.x.x |
|Docker|1.12.x|
|Ansible|2.3.2.x|

***Required Channels***

A subscription to the following channels is required in order to deploy this reference environment’s configuration.

|Channel|Repository Name|
|-------|---------------|
|Red Hat Enterprise Linux 7 Server (RPMs)|rhel-7-server-rpms|
|Red Hat OpenShift Enterprise 3.6 (RPMs)|rhel-7-server-ose-3.6-rpms|
|Red Hat Enterprise Linux 7 Server - Extras (RPMs)|rhel-7-server-extras-rpms|
|Red Hat Enterprise Linux 7 Server - Fast Datapath (RPMs) |rhel-7-fast-datapath-rpms|

**Nodes**

Nodes are VM_instances that serve a specific purpose for OpenShift

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

**Registry**

* OpenShift provides an internal, integrated Docker registry 
* The registry stores Docker images and metadata. 
* Use persistent storage for the registry & images

**Router**

* Pods inside of an OpenShift cluster are only reachable via their IP addresses on the cluster network. 
* An edge load balancer can be used to accept traffic from outside networks and proxy the traffic to pods inside the OpenShift cluster.
* OpenShift routers provide external hostname mapping and load balancing to services over protocols that pass distinguishing information directly to the router; the hostname must be present in the protocol in order for the router to determine where to send it. 
* The router utilizes the wildcard zone specified during the installation and configuration of OpenShift. This wildcard zone is used by the router to create routes for a service running within the OpenShift environment to a publically accessible URL. 

----

# Phase 2: Deploy OpenShift

Refer to details here: https://github.com/IBMTerraform/terraform-ibm-openshift/blob/master/docs/02-Deploy-OpenShift.md

----