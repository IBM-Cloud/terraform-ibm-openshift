module "storage_appnode" {
  source     = "../storage_appnode"
  datacenter = "${var.datacenter}"
}

# Create a vm for appnode

resource "ibm_compute_vm_instance" "appnode" {
  count                     = "${var.node_count}"
  os_reference_code         = "${var.vm-os-reference-code}"
  hostname                  = "${var.vm-hostname}-${var.random_id}${count.index}"
  domain                    = "${var.vm_domain}"
  datacenter                = "${var.datacenter}" 
  block_storage_ids         = ["${module.storage_appnode.appnodeblockid}"]
  private_network_only      = "true"
  network_speed             = 100
  local_disk                = false
  flavor_key_name           = "${var.flavor_key_name}"
  disks                     = [50, 25, 25]
  ssh_key_ids               = ["${var.ssh_key_id}"]
  local_disk                = false
  private_vlan_id           = "${var.private_vlan_id}"
 // public_vlan_id           = "${var.public_vlan_id}"
  //public_security_group_ids = ["${var.openshift-sg-node}"]
  private_security_group_ids = ["${var.openshift-sg-node}"]
}



//Variables

variable "random_id" {}


variable "ssh_key_id" {}

variable "openshift-sg-node"{}
variable "node_count" {}

variable "datacenter" {}

variable "vm-hostname" {
  default = "app-ose"
}

variable "vm_domain" {}

variable "flavor_key_name" {
  default = "B1_4X8X100"
}

variable "vm-os-reference-code" {
  default = "REDHAT_7_64"
}

variable "private_vlan_id" {}

variable "public_vlan_id" {}


output "app_public_ip" {
  value = "${ibm_compute_vm_instance.appnode.*.ipv4_address}"

}

output "app_private_ip" {
  value = "${ibm_compute_vm_instance.appnode.*.ipv4_address_private}"

}

output "app_host" {
  value = "${ibm_compute_vm_instance.appnode.*.hostname}"
}


output "app_subnet_id" {
  value = "${ibm_compute_vm_instance.appnode.0.private_subnet_id}"
}