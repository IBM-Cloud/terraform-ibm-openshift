
#################################################
# Block Storage for Bastion node
#################################################

resource "ibm_storage_block" "bastionnode_block" {
  type           = "${var.block_storage_type}"
  datacenter     = "${var.datacenter}"
  capacity       = 2000
  iops           = 4000
  os_format_type = "Linux"
  hourly_billing = "${var.hourly_billing}"
  allowed_virtual_guest_ids  = ["${ibm_compute_vm_instance.bastion.id}"]
}

locals {
  block_allowed_hosts = "${flatten(ibm_storage_block.bastionnode_block.allowed_host_info)}"
}

#################################################
# iSCSI Setup for Bastion node
#################################################
resource "null_resource" "iscsi_bastion" {

  connection {
    type     = "ssh"
    user     = "root"
    host     = "${ibm_compute_vm_instance.bastion.ipv4_address}"
    private_key = "${file(var.bastion_private_ssh_key)}"
  }

  provisioner "remote-exec" {
  inline = [
    "timedatectl set-timezone UTC",
    "chmod 600 /root/.ssh/id_rsa",
    "yum install device-mapper-multipath iscsi-initiator-utils lvm2 -y",
    "echo 'InitiatorName=${lookup(local.block_allowed_hosts[0],"host_iqn")}' > /etc/iscsi/initiatorname.iscsi",
    "sed -i 's/.*node\\.session\\.auth\\.authmethod \\?=.*/node.session.auth.authmethod = CHAP/' /etc/iscsi/iscsid.conf",
    "sed -i 's/.*node\\.session\\.auth\\.username \\?=.*/node.session.auth.username = ${lookup(local.block_allowed_hosts[0],"username")}/' /etc/iscsi/iscsid.conf",
    "sed -i 's/.*node\\.session\\.auth\\.password \\?=.*/node.session.auth.password = ${lookup(local.block_allowed_hosts[0],"password")}/' /etc/iscsi/iscsid.conf",
    "sed -i 's/.*discovery\\.sendtargets\\.auth\\.authmethod \\?=.*/discovery.sendtargets.auth.authmethod = CHAP/' /etc/iscsi/iscsid.conf",
    "sed -i 's/.*discovery\\.sendtargets\\.auth\\.username \\?=.*/discovery.sendtargets.auth.username = ${lookup(local.block_allowed_hosts[0],"username")}/' /etc/iscsi/iscsid.conf",
    "sed -i 's/.*discovery\\.sendtargets\\.auth\\.password \\?=.*/discovery.sendtargets.auth.password = ${lookup(local.block_allowed_hosts[0],"password")}/' /etc/iscsi/iscsid.conf",
    "mpathconf --enable --with_multipathd y",
    "systemctl enable iscsi",
    "systemctl restart iscsi",
    "iscsiadm -m discovery -t sendtargets -p ${ibm_storage_block.bastionnode_block.hostname}",
    "iscsiadm -m node --login",
    "sed -i 's/^SELINUX=.*/SELINUX=enforcing/' /etc/selinux/config",
    "fixfiles restore /",
    "setenforce 1",
	   ]
  }

}