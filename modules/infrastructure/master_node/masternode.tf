#################################################
# VM Instance Setup for Master node
#################################################
resource "ibm_compute_vm_instance" "masternode" {
  count                     = "${var.master_node_count}"
  os_reference_code         = "${var.master_os_ref_code}"
  hostname                  = "${var.master_hostname_prefix}-${var.random_id}-${var.master_hostname}-${count.index}"
  domain                    = "${var.domain}"
  datacenter                = "${var.datacenter}"
  private_network_only      = "false"
  network_speed             = 1000
  local_disk                = "false"
  flavor_key_name           = "${var.master_flavor}"
  ssh_key_ids               = ["${var.master_ssh_key_ids}"]
  private_vlan_id           = "${var.private_vlan_id}"
  public_vlan_id           = "${var.public_vlan_id}"
  public_security_group_ids = ["${ibm_security_group.openshift-master.id}"]
  private_security_group_ids = ["${ibm_security_group.openshift-master.id}"]
  hourly_billing             = "${var.hourly_billing}"
}





