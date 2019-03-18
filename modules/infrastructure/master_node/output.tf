#################################################
# Output
#################################################
output "master_ip_address_id" {
  value = "${ibm_compute_vm_instance.masternode.*.ip_address_id_private}"
}

output "master_public_ip" {
  value = "${ibm_compute_vm_instance.masternode.*.ipv4_address}"

}

output "master_private_ip" {
  value = "${ibm_compute_vm_instance.masternode.*.ipv4_address_private}"

}

output "master_host" {
  value = "${ibm_compute_vm_instance.masternode.*.hostname}"
}

output "openshift_master_id" {
  value = "${ibm_security_group.openshift-master.id}"
}
