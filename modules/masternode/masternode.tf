# Provision the master node

module "storage_masternode" {
  source     = "../storage_masternode"
  datacenter = "${var.datacenter}"
}

resource "ibm_compute_vm_instance" "masternode" {
  os_reference_code         = "${var.vm-os-reference-code}"
  hostname                  = "${var.vm-hostname}-${var.random_id}"
  domain                    = "${var.vm-domain}"
  datacenter                = "${var.datacenter}"
  block_storage_ids         = ["${module.storage_masternode.masterblockid}"]
  private_network_only      = "true"
  network_speed             = 100
  local_disk                = false
  flavor_key_name           = "${var.flavor_key_name}"
  disks                     = [50, 25, 25]
  ssh_key_ids               = ["${var.ssh_key_id}"]
  private_vlan_id           = "${var.private_vlan_id}"
  //public_vlan_id           = "${var.public_vlan_id}"
 // public_security_group_ids = ["${var.openshift-sg-master}"]
  private_security_group_ids = ["${var.openshift-sg-master}"]
}



//Variables

variable "random_id" {}

variable "ssh_key_id" {}

variable "openshift-sg-master"{}

variable "datacenter" {}

variable "vm-hostname" {
  default = "master-ose"
}

variable "vm-domain" {}

variable "flavor_key_name" {
  default = "B1_4X8X100"
}

variable "vm-os-reference-code" {
  default = "REDHAT_7_64"
}

variable "public_vlan_id" {}

variable "private_vlan_id" {}

output "master_ip_address_id" {
  value = "${ibm_compute_vm_instance.masternode.ip_address_id_private}"
}

output "master_public_ip" {
  value = "${ibm_compute_vm_instance.masternode.ipv4_address}"

}

output "master_private_ip" {
  value = "${ibm_compute_vm_instance.masternode.ipv4_address_private}"

}

output "master_hostname" {
  value = "${ibm_compute_vm_instance.masternode.hostname}.${ibm_compute_vm_instance.masternode.domain}"
}

output "master_host" {
  value = "${ibm_compute_vm_instance.masternode.hostname}"
}