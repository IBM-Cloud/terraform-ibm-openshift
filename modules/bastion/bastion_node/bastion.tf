#################################################
# Create Private Keys for Bastion
#################################################
resource "null_resource" "create_bastion_private_key" {
  provisioner "local-exec" {
    command = "if [ ! -f '${var.bastion_ssh_key_file}' ]; then ssh-keygen  -f ${var.bastion_ssh_key_file} -N ''; fi"
  }
}

locals {
  bastion_ssh_publickey_file = "${var.bastion_ssh_key_file}.pub"
}

resource "ibm_compute_ssh_key" "bastion_public_ssh_key" {
  label      = "${var.bastion_ssh_label}"
  notes      = "SSH key for Bastion node"
  public_key = "${file(local.bastion_ssh_publickey_file)}"
  depends_on = ["null_resource.create_bastion_private_key"]
}

resource "null_resource" "copy_bastion_private_key" {
  connection {
    type     = "ssh"
    user     = "root"
    host     = "${ibm_compute_vm_instance.bastion.ipv4_address}"
    private_key = "${file(var.bastion_private_ssh_key)}"
  }

  provisioner "file" {
    source      = "${var.bastion_ssh_key_file}"
    destination = "/root/.ssh/id_rsa"
  }
  depends_on    = ["null_resource.create_bastion_private_key"]
}

#################################################
# VM Instance Setup
#################################################

resource "ibm_compute_vm_instance" "bastion" {
  os_reference_code         = "${var.bastion_os_ref_code}"
  hostname                  = "${var.bastion_hostname_prefix}-${var.random_id}-${var.bastion_hostname}"
  domain                    = "${var.domain}"
  datacenter                = "${var.datacenter}"
  private_network_only      = "false"
  flavor_key_name           = "${var.bastion_flavor}"
  network_speed             = 1000
  local_disk                = "false"
  ssh_key_ids               = ["${var.bastion_ssh_key_id}"]
  private_vlan_id           = "${var.private_vlan_id}"
  public_vlan_id            = "${var.public_vlan_id}"
  public_security_group_ids = ["${ibm_security_group.openshift-bastion.id}"]
  private_security_group_ids = ["${ibm_security_group.openshift-bastion.id}"]
  hourly_billing            = "${var.hourly_billing}"
}

