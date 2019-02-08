# openshift MAIN.tf
# This file runs each of the modules

# Create a new ssh key 
resource "ibm_compute_ssh_key" "ssh_key_openshift" {
  label      = "${var.ssh-label}"
  notes      = "for openshift"
  public_key = "${file(var.ssh_public_key)}"
}

resource "random_id" "ose_name" {
  byte_length = 5
}

module "network" {
  source     = "modules/network"
  vlan_count = "${var.vlan_count}"
  datacenter = "${var.datacenter}"
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
  source              = "modules/masternode"
  private_vlan_id     = "${var.vlan_count == "1" ? "${join("", module.network.openshift_private_vlan_id)}" : var.private_vlanid}"
  public_vlan_id      = "${var.vlan_count == "1" ? "${join("", module.network.openshift_public_vlan_id)}" : var.public_vlanid}"
  datacenter          = "${var.datacenter}"
  openshift-sg-master = "${module.sg.openshift_master_id}"
  ssh_key_id          = "${ibm_compute_ssh_key.ssh_key_openshift.id}"
  vm_domain           = "${var.vm_domain}"
  random_id           = "${random_id.ose_name.hex}"
  master_count        = "1"
  master_flavor       = "${var.master_flavor}"
}

#####################################################
# Create vm cluster for infra node
#####################################################
module "infranode" {
  source             = "modules/infranode"
  private_vlan_id    = "${var.vlan_count == "1" ? "${join("", module.network.openshift_private_vlan_id)}" : var.private_vlanid}"
  public_vlan_id     = "${var.vlan_count == "1" ? "${join("", module.network.openshift_public_vlan_id)}" : var.public_vlanid}"
  datacenter         = "${var.datacenter}"
  node_count         = "${var.infra_count}"
  openshift-sg-infra = "${module.sg.openshift_node_id}"
  ssh_key_id         = "${ibm_compute_ssh_key.ssh_key_openshift.id}"
  vm_domain          = "${var.vm_domain}"
  random_id          = "${random_id.ose_name.hex}"
  infra_flavor       = "${var.infra_flavor}"
}

#####################################################
# Create vm cluster for app
#####################################################
module "appnode" {
  source            = "modules/appnode"
  private_vlan_id   = "${var.vlan_count == "1" ? "${join("", module.network.openshift_private_vlan_id)}" : var.private_vlanid}"
  public_vlan_id    = "${var.vlan_count == "1" ? "${join("", module.network.openshift_public_vlan_id)}" : var.public_vlanid}"
  datacenter        = "${var.datacenter}"
  node_count        = "${var.app_count}"
  openshift-sg-node = "${module.sg.openshift_node_id}"
  ssh_key_id        = "${ibm_compute_ssh_key.ssh_key_openshift.id}"
  vm_domain         = "${var.vm_domain}"
  random_id         = "${random_id.ose_name.hex}"
  app_flavor        = "${var.app_flavor}"
}

#####################################################
# Create vm cluster for bastion
#####################################################
module "bastion" {
  source               = "modules/bastion"
  private_vlan_id      = "${var.vlan_count == "1" ? "${join("", module.network.openshift_private_vlan_id)}" : var.private_vlanid}"
  public_vlan_id       = "${var.vlan_count == "1" ? "${join("", module.network.openshift_public_vlan_id)}" : var.public_vlanid}"
  datacenter           = "${var.datacenter}"
  openshift-sg-bastion = "${module.sg.openshift_bastion_id}"
  ssh_key_id           = "${ibm_compute_ssh_key.ssh_key_openshift.id}"
  vm_domain            = "${var.vm_domain}"
  random_id            = "${random_id.ose_name.hex}"
  bastion_flavor       = "${var.bastion_flavor}"
}

# Use load balancer & gateway, for a scalable architecture

#####################################################
# Create infra lbaas
#####################################################
module "lbaas_infra" {
  source           = "modules/lbaas_infranode"
  infra_lbass_name = "${var.infra_lbass_name}"
  node_count       = "${var.infra_count}"
  infra_private_ip = "${module.infranode.infra_private_ip}"
  subnet_id        = "${module.infranode.infra_subnet_id}"
  random_id        = "${random_id.ose_name.hex}"
}

#####################################################
# Create app lbaas
#####################################################
module "lbaas_app" {
  source         = "modules/lbaas_appnode"
  app_lbass_name = "${var.app_lbass_name}"
  node_count     = "${var.app_count}"
  app_private_ip = "${module.appnode.app_private_ip}"
  subnet_id      = "${module.appnode.app_subnet_id}"
  random_id      = "${random_id.ose_name.hex}"
}

/*#####################################################
# Create gateway
#####################################################
module "gateway" {
  gw_count        = "${var.gw_count}"
  source          = "modules/gateway"
  datacenter      = "${var.datacenter}"
  ssh_key_id      = "${ibm_compute_ssh_key.ssh_key_openshift.id}"
  vm_domain       = "${var.vm_domain}"
  private_vlan_id = "${var.vlan_count == "1" ? "${join("", module.network.openshift_private_vlan_id)}" : var.private_vlanid}"
  public_vlan_id  = "${var.vlan_count == "1" ? "${join("", module.network.openshift_public_vlan_id)}" : var.public_vlanid}"
  random_id       = "${random_id.ose_name.hex}"
}*/

module "templates" {
  source             = "modules/templates"
  bastion_private_ip = "${module.bastion.bastion_private_ip}"
  master_private_ip  = "${module.masternode.master_private_ip}"
  master_public_ip   = "${module.masternode.master_public_ip}"
  infra_private_ip   = "${module.infranode.infra_private_ip}"
  app_private_ip     = "${module.appnode.app_private_ip}"
  master_host        = "${module.masternode.master_host}"
  infra_host         = "${module.infranode.infra_host}"
  app_host           = "${module.appnode.app_host}"
  vm_domain          = "${var.vm_domain}"
  master_count       = "1"
  infra_count        = "${var.infra_count}"
  app_count          = "${var.app_count}"
}

module "setup_bastion" {
  source             = "modules/setup_bastion"
  bastion_ip_address = "${module.bastion.bastion_ip_address}"
  private_ssh_key    = "${var.private_ssh_key}"
  rhn_username       = "${var.rhn_username}"
  rhn_password       = "${var.rhn_password}"
  pool_id            = "${var.pool_id}"
}

module "pre_install" {
  source             = "modules/pre_install"
  bastion_ip_address = "${module.bastion.bastion_ip_address}"
  private_ssh_key    = "${var.private_ssh_key}"
  master_private_ip  = "${module.masternode.master_private_ip}"
  infra_private_ip   = "${module.infranode.infra_private_ip}"
  app_private_ip     = "${module.appnode.app_private_ip}"
}

module "post_install" {
  source             = "modules/post_install"
  bastion_ip_address = "${module.bastion.bastion_ip_address}"
  private_ssh_key    = "${var.private_ssh_key}"
  master_private_ip  = "${module.masternode.master_private_ip}"
  infra_private_ip   = "${module.infranode.infra_private_ip}"
  app_private_ip     = "${module.appnode.app_private_ip}"
}
