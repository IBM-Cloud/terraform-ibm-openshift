#################################################
# Output
#################################################
output "app_ip_address_id" {
  value = "${ibm_compute_vm_instance.appnode.*.ip_address_id_private}"
}

output "app_public_ip" {
  value = "${ibm_compute_vm_instance.appnode.*.ipv4_address}"

}

output "app_private_ip" {
  value = "${ibm_compute_vm_instance.appnode.*.ipv4_address_private}"

}

output "app_host" {
  value = "${ibm_compute_vm_instance.appnode.*.hostname}"
}

