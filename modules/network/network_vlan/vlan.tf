#  MODULE 1 - Networks
# This is the network module used when you must provision the networks in your architecture
#this is the "vlan module" and all outputs are defined as ${module.vlan."reosurceid"."outputproperty"}


resource "ibm_network_vlan" "openshift_vlan_private" {
  count = "${var.vlan_count}"
  name            = "openshift-prv-vlan"
  datacenter      = "${var.datacenter}"
  type            = "PRIVATE"
}

resource "ibm_network_vlan" "openshift_vlan_public" {
  count = "${var.vlan_count}"
  name            = "openshift-pub-vlan"
  datacenter      = "${var.datacenter}"
  type            = "PUBLIC"
}
