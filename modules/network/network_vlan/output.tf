
##################################################
# outputs
##################################################

output "openshift_private_vlan_id" {
  value = "${ibm_network_vlan.openshift_vlan_private.*.id}"
}

output "openshift_public_vlan_id" {
  value = "${ibm_network_vlan.openshift_vlan_public.*.id}"
}
