
#################################################
# Output
#################################################
output "storage_ip_address_id" {
  value = "${ibm_compute_vm_instance.storagenode.*.ip_address_id_private}"
}

output "storage_public_ip" {
  value = "${ibm_compute_vm_instance.storagenode.*.ipv4_address}"

}

output "storage_private_ip" {
  value = "${ibm_compute_vm_instance.storagenode.*.ipv4_address_private}"

}

output "storage_host" {
  value = "${ibm_compute_vm_instance.storagenode.*.hostname}"
}



