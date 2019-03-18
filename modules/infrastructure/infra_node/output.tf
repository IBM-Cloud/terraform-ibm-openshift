
#################################################
# Output
#################################################
output "infra_ip_address_id" {
  value = "${ibm_compute_vm_instance.infranode.*.ip_address_id_private}"
}

output "infra_public_ip" {
  value = "${ibm_compute_vm_instance.infranode.*.ipv4_address}"

}

output "infra_private_ip" {
  value = "${ibm_compute_vm_instance.infranode.*.ipv4_address_private}"

}

output "infra_host" {
  value = "${ibm_compute_vm_instance.infranode.*.hostname}"
}

output "infra_subnet_id" {
  value = "${ibm_compute_vm_instance.infranode.0.private_subnet_id}"
}
