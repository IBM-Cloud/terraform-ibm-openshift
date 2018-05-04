provider ibm {}

# Create the gateway with single member

resource "ibm_network_gateway" "openshift-gateway" {
  name        = "${var.gateway-name}-${var.random_id}"
  ssh_key_ids = ["${var.ssh_key_id}"]

  members {
    hostname          = "${var.vm-hostname}-${var.random_id}"
    domain            = "${var.vm-domain}"
    datacenter        = "${var.datacenter}"
    network_speed     = "${var.vm-network-speed}"
    ssh_key_ids       = ["${var.ssh_key_id}"]
    tcp_monitoring    = true
    private_network_only = false
    process_key_name  = "${var.vm-process-key-name}"
    os_key_name       = "${var.vm-os-key-name}"
    redundant_network = false
    disk_key_names    = ["${var.vm-disk-key-name}"]
    public_bandwidth  = 20000
    public_vlan_id    = "${var.public_vlan_id}"
    private_vlan_id   = "${var.private_vlan_id}"
    memory            = 8
    tags              = ["gateway tags 1", "terraform test tags 1"]
    notes             = "gateway notes 1"
    ipv6_enabled      = true
  }

  # Configure the gateway, create your configuration file create-vifs.vcli
  /*
connection {
   type        = "ssh"
   user        = "vyatta"
   host        = "${self.public_ipv4_address}"
   private_key = “${file(“~/.ssh/id_rsa”)}”
 }

provisioner "file" {
   source      = "create-vifs.vcli"
   destination = "/tmp/create-vifs.vcli"
 }

provisioner "remote-exec" {
   inline = [
     "chmod +x /tmp/create-vifs.vcli",
     "/tmp/create-vifs.vcli",
   ]
 }*/
}

# Variables

resource "ibm_network_gateway_vlan_association" "openshift_vlan_attachment" {
  gateway_id      = "${ibm_network_gateway.openshift-gateway.id}"
  network_vlan_id = "${var.public_vlan_id}"
}

resource "ibm_network_gateway_vlan_association" "openshift_vlan_attachment1" {
  gateway_id      = "${ibm_network_gateway.openshift-gateway.id}"
  network_vlan_id = "${var.private_vlan_id}"
}



variable "random_id" {}

variable "private_vlan_id" {}

variable "public_vlan_id" {}



variable "datacenter" {}

variable "ssh_key_id" {}

variable "gateway-name" {
  default = "gateway-openshift"
  
 }
 
 variable "vm-hostname" {
  default = "gw-ose-vm"
 }

variable "vm-domain" {}

variable "vm-network-speed" {
  default = 100
}

variable "vm-os-key-name" {
  default = "OS_VYATTA_5600_5_X_UP_TO_1GBPS_SUBSCRIPTION_EDITION_64_BIT"
}

variable "vm-process-key-name" {
  default = "INTEL_SINGLE_XEON_1270_3_50"
}

variable "vm-disk-key-name" {
  default = "HARD_DRIVE_2_00TB_SATA_II"
}

#Output

output "gateway_public_id" {
  value = "${ibm_network_gateway.openshift-gateway.public_vlan_id}"
}

output "public_ip_address" {
  value = "${ibm_network_gateway.openshift-gateway.public_ipv4_address}"
}
