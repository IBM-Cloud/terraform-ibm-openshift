provider "ibm" {}

# Create a vm for bastion

resource "ibm_compute_vm_instance" "bastion" {
  os_reference_code         = "${var.vm-os-reference-code}"
  hostname                  = "${var.vm-hostname}-${var.random_id}"
  domain                    = "${var.vm-domain}"
  datacenter                = "${var.datacenter}"
  private_network_only      = "false"
  network_speed             = 10
  cores                     = 2
  memory                    = 4096
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

variable "vm-domain" {}

variable "vm-cores" {
  default = 1
}

variable "vm-memory" {
  default = 4096
}

variable "vm-os-reference-code" {
  default = "REDHAT_7_64"
}

variable "private_vlan_id" {}

variable "public_vlan_id" {}

output "bastion_ip_address" {
  value = "${ibm_compute_vm_instance.bastion.ipv4_address}"
}

