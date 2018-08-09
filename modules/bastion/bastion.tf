# Create a vm for bastion

resource "ibm_compute_vm_instance" "bastion" {
  os_reference_code         = "${var.vm-os-reference-code}"
  hostname                  = "${var.vm-hostname}-${var.random_id}"
  domain                    = "${var.vm_domain}"
  datacenter                = "${var.datacenter}"
  private_network_only      = "false"
  flavor_key_name =  "${var.bastion_flavor}"
  local_disk                = true
  disks						          = [100,50]
  ssh_key_ids               = ["${var.ssh_key_id}"]
  local_disk                = false
  private_vlan_id           = "${var.private_vlan_id}"
  public_vlan_id            = "${var.public_vlan_id}"
  public_security_group_ids = ["${var.openshift-sg-bastion}"]
}


//Variables

variable "random_id" {}

variable "openshift-sg-bastion"{}

variable "ssh_key_id" {}

variable "datacenter" {}

variable "vm-hostname" {
  default = "bastion-ose"
}

variable "vm_domain" {}

variable "bastion_flavor" {}


variable "vm-os-reference-code" {
  default = "REDHAT_7_64"
}

variable "private_vlan_id" {}

variable "public_vlan_id" {}

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
