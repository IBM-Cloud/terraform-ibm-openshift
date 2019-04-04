#################################################
# Block Storage for Storage node
#################################################
resource "ibm_storage_block" "storagenode_block" {
  count          = "${var.storage_node_count * 3}"
  type           = "${var.block_storage_type}"
  datacenter     = "${var.datacenter}"
  capacity       = 500
  iops           = 1000
  os_format_type = "Linux"
  hourly_billing = "${var.hourly_billing}"
  allowed_virtual_guest_ids  = ["${element(ibm_compute_vm_instance.storagenode.*.id,floor(count.index / 3))}"]
}

locals {
  block_allowed_hosts = "${flatten(ibm_storage_block.storagenode_block.*.allowed_host_info)}"
}

#################################################
# iSCSI Setup for storage node
#################################################
resource "null_resource" "iscsi_storage" {
  count      = "${var.storage_node_count}"
  connection {
    type     = "ssh"
    user     = "root"
    host     = "${element(ibm_compute_vm_instance.storagenode.*.ipv4_address,count.index)}"
    private_key = "${file(var.storage_private_ssh_key)}"
  }

  provisioner "remote-exec" {
  inline = [
    "timedatectl set-timezone UTC",
    "chmod 600 /root/.ssh/id_rsa",
    "yum install device-mapper-multipath iscsi-initiator-utils lvm2 -y",
    "echo 'InitiatorName=${lookup(local.block_allowed_hosts[count.index * 3],"host_iqn")}' > /etc/iscsi/initiatorname.iscsi",
    "sed -i 's/.*node\\.session\\.auth\\.authmethod \\?=.*/node.session.auth.authmethod = CHAP/' /etc/iscsi/iscsid.conf",
    "sed -i 's/.*node\\.session\\.auth\\.username \\?=.*/node.session.auth.username = ${lookup(local.block_allowed_hosts[count.index * 3],"username")}/' /etc/iscsi/iscsid.conf",
    "sed -i 's/.*node\\.session\\.auth\\.password \\?=.*/node.session.auth.password = ${lookup(local.block_allowed_hosts[count.index * 3],"password")}/' /etc/iscsi/iscsid.conf",
    "sed -i 's/.*discovery\\.sendtargets\\.auth\\.authmethod \\?=.*/discovery.sendtargets.auth.authmethod = CHAP/' /etc/iscsi/iscsid.conf",
    "sed -i 's/.*discovery\\.sendtargets\\.auth\\.username \\?=.*/discovery.sendtargets.auth.username = ${lookup(local.block_allowed_hosts[count.index * 3],"username")}/' /etc/iscsi/iscsid.conf",
    "sed -i 's/.*discovery\\.sendtargets\\.auth\\.password \\?=.*/discovery.sendtargets.auth.password = ${lookup(local.block_allowed_hosts[count.index * 3],"password")}/' /etc/iscsi/iscsid.conf",
    "mpathconf --enable --with_multipathd y",
    "systemctl enable iscsi",
    "systemctl restart iscsi",
    "iscsiadm -m discovery -t sendtargets -p ${element(ibm_storage_block.storagenode_block.*.hostname,count.index * 3)}",
    "iscsiadm -m discovery -t sendtargets -p ${element(ibm_storage_block.storagenode_block.*.hostname,count.index * 3 + 1)}",
    "iscsiadm -m discovery -t sendtargets -p ${element(ibm_storage_block.storagenode_block.*.hostname,count.index * 3 + 2)}",
    "iscsiadm -m node --login",
    "sed -i 's/^SELINUX=.*/SELINUX=enforcing/' /etc/selinux/config",
    "fixfiles restore /",
    "setenforce 1",
           ]
  }

}
