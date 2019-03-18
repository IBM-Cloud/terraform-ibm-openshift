#################################################
# VM Instance for App Node on Private VLAN
#################################################
resource "ibm_compute_vm_instance" "appnode" {
  count                     = "${var.app_node_count}"
  os_reference_code         = "${var.app_os_ref_code}"
  hostname                  = "${var.app_hostname_prefix}-${var.random_id}-${var.app_hostname}-${count.index}"
  domain                    = "${var.domain}"
  datacenter                = "${var.datacenter}"
  private_network_only      = "false"
  network_speed             = 1000
  local_disk                = "false"
  flavor_key_name           = "${var.app_flavor}"
  ssh_key_ids               = ["${var.app_ssh_key_ids}"]
  private_vlan_id           = "${var.private_vlan_id}"
  public_vlan_id           = "${var.public_vlan_id}"
  public_security_group_ids = ["${var.app_node_pub_sg}"]
  private_security_group_ids = ["${var.app_node_prv_sg}"]
  hourly_billing             = "${var.hourly_billing}"
}

