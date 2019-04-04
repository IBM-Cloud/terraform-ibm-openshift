#################################################
# VM Instance Setup for Storage node
#################################################
resource "ibm_compute_vm_instance" "storagenode" {
  count                     = "${var.storage_node_count}"
  os_reference_code         = "${var.storage_os_ref_code}"
  hostname                  = "${var.storage_hostname_prefix}-${var.random_id}-${var.storage_hostname}-${count.index}"
  domain                    = "${var.domain}"
  datacenter                = "${var.datacenter}"
  private_network_only      = "false"
  network_speed             = 1000
  local_disk                = "false"
  flavor_key_name           = "${var.storage_flavor}"
  ssh_key_ids               =["${var.storage_ssh_key_ids}"]
  private_vlan_id           = "${var.private_vlan_id}"
  public_vlan_id           = "${var.public_vlan_id}"
  public_security_group_ids = ["${var.storage_node_pub_sg}"]
  private_security_group_ids = ["${var.storage_node_prv_sg}"]
  hourly_billing             = "${var.hourly_billing}"
}
