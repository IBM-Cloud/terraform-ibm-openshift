
#################################################
# Output
#################################################
output "bastion_ip_address" {
  value = "${ibm_compute_vm_instance.bastion.ipv4_address}"
}

output "bastion_private_ip" {
  value = "${ibm_compute_vm_instance.bastion.ipv4_address_private}"
}

output "bastion_domain" {
  value = "${ibm_compute_vm_instance.bastion.domain}"
}

output "bastion_hostname" {
  value = "${ibm_compute_vm_instance.bastion.hostname}"
}

output "bastion_public_ssh_key" {
 value = "${ibm_compute_ssh_key.bastion_public_ssh_key.id}"
}

output "openshift_bastion_id" {
  value = "${ibm_security_group.openshift-bastion.id}"
}