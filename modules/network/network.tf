#  MODULE 1 - Networks
# This is the network module used when you must provision the networks in your architecture
#this is the "vlan module" and all outputs are defined as ${module.vlan."reosurceid"."outputproperty"}
provider "ibm" {}

resource "ibm_network_vlan" "openshift_vlan_private" {
  name            = "openshift-prv-vlan"
  datacenter      = "${var.datacenter}"
  type            = "PRIVATE"
  subnet_size     = 8
  router_hostname = "${var.private_router}"
}

resource "ibm_network_vlan" "openshift_vlan_public" {
  name            = "openshit-pub-vlan"
  datacenter      = "${var.datacenter}"
  type            = "PUBLIC"
  subnet_size     = 8
  router_hostname = "${var.public_router}"
}

##################################################
# variables
##################################################

variable "datacenter" {}

variable "public_router" {
  default     = "fcr01a.dal05"
  description = "the router to use for the public VLAN."
}

variable "private_router" {
  default     = "bcr01a.dal05"
  description = "the router to use for the private VLAN."
}

##################################################
# outputs
##################################################

output "openshift_private_vlan_id" {
  value = "${ibm_network_vlan.openshift_vlan_private.id}"
}

output "openshift_public_vlan_id" {
  value = "${ibm_network_vlan.openshift_vlan_public.id}"
}
