# openshift MAIN.tf
# This file runs each of the modules

# Create a new ssh key 
resource "ibm_compute_ssh_key" "ssh_key_openshift" {
  label      = "${var.ssh-label}"
  notes      = "for openshift"
  public_key = "${var.ssh_public_key}"
}

resource "random_id" "ose_name" {
  byte_length = 5
}

module "network" {
  source     = "modules/network"
  datacenter = "${var.datacenter}"
  public_router = "${var.public_router}"
  private_router = "${var.private_router}"
}

module "sg" {
  source = "modules/security_grp"
  //openshift_gateway_public_address = "${module.gateway.public_ip_address}"
  random_id = "${random_id.ose_name.hex}"
}

#####################################################
# Create vm cluster for master
#####################################################
module "masternode" {
  source                   = "modules/masternode"
  private_vlan_id          = "${module.network.openshift_private_vlan_id}"
  public_vlan_id          = "${module.network.openshift_public_vlan_id}"
  datacenter               = "${var.datacenter}"
  openshift-sg-master      = "${module.sg.openshift_master_id}"
  ssh_key_id               = "${ibm_compute_ssh_key.ssh_key_openshift.id}"
  vm-domain                = "${var.vm-domain}"
  random_id = "${random_id.ose_name.hex}"
}

#####################################################
# Create vm cluster for infra node
#####################################################
module "infranode" {
  source                   = "modules/infranode"
  private_vlan_id          = "${module.network.openshift_private_vlan_id}"
  public_vlan_id          = "${module.network.openshift_public_vlan_id}"
  datacenter               = "${var.datacenter}"
  node_count               = "${var.infra_count}"
  openshift-sg-infra       = "${module.sg.openshift_node_id}"
  ssh_key_id               = "${ibm_compute_ssh_key.ssh_key_openshift.id}"
  vm-domain                = "${var.vm-domain}"
  random_id = "${random_id.ose_name.hex}"
}

#####################################################
# Create vm cluster for app
#####################################################
module "appnode" {
  source                   = "modules/appnode"
  private_vlan_id          = "${module.network.openshift_private_vlan_id}"
  public_vlan_id          = "${module.network.openshift_public_vlan_id}"
  datacenter               = "${var.datacenter}"
  node_count               = "${var.app_count}"
  openshift-sg-node        = "${module.sg.openshift_node_id}"
  ssh_key_id               = "${ibm_compute_ssh_key.ssh_key_openshift.id}"
  vm-domain                = "${var.vm-domain}"
  random_id = "${random_id.ose_name.hex}"
}

#####################################################
# Create vm cluster for bastion
#####################################################
module "bastion" {
  source                  = "modules/bastion"
  private_vlan_id         = "${module.network.openshift_private_vlan_id}"
  public_vlan_id          = "${module.network.openshift_public_vlan_id}"
  datacenter              = "${var.datacenter}"
  openshift-sg-bastion    = "${module.sg.openshift_bastion_id}"
  ssh_key_id              = "${ibm_compute_ssh_key.ssh_key_openshift.id}"
  vm-domain               = "${var.vm-domain}"
  random_id = "${random_id.ose_name.hex}"
}

# Use load balancer & gateway, for a scalable architecture
/*
#####################################################
# Create infra lbaas
#####################################################
module "lbaas_infra" {
  source        = "modules/lbaas_infranode"
  datacenter    = "${var.datacenter}"
  node_count    = "${var.infra_count}"
  ip_address_id = "${module.infranode.infra_ip_address_id}"
}

#####################################################
# Create master lbaas
#####################################################
module "lbaas_master" {
  source        = "modules/lbaas_masternode"
  datacenter    = "${var.datacenter}"
  ip_address_id = "${module.masternode.master_ip_address_id}"
}

#####################################################
# Create gateway
#####################################################
module "gateway" {
  source = "modules/gateway"
  datacenter = "${var.datacenter}"
  ssh_key_id = "${ibm_compute_ssh_key.ssh_key_openshift.id}"
  vm-domain  = "${var.vm-domain}"
  private_vlan_id = "${module.network.openshift_private_vlan_id}"
  public_vlan_id  = "${module.network.openshift_public_vlan_id}"
  random_id = "${random_id.ose_name.hex}"
}

*/

