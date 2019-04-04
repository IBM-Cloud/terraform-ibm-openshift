#################################################
# Prepare to install Openshift
#################################################
resource "null_resource" "pre_install_cluster" {

  connection {
    type     = "ssh"
    user     = "root"
    host = "${var.bastion_ip_address}"
    private_key = "${file(var.bastion_private_ssh_key)}"
  }

  provisioner "file" {
    source      = "${var.bastion_private_ssh_key}"
    destination = "~/.ssh/id_rsa"
  }

  provisioner "file" {
    source      = "${path.cwd}/inventory_repo/"
    destination = "/root"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod 400 /root/.ssh/id_rsa",
      "chmod +x /tmp/scripts/*",
      "cat /root/hosts >> /etc/hosts",
      "/tmp/scripts/pre_install_steps.sh ${join(",",concat(var.app_private_ip,var.infra_private_ip,var.master_private_ip,var.storage_private_ip))} ${join(",",concat(var.app_host,var.infra_host,var.master_host,var.storage_host))} ${var.domain}"
    ]
  }
}

#################################################
# Install Openshift
#################################################
resource "null_resource" "deploy_cluster" {
  depends_on = ["null_resource.pre_install_cluster"]

  connection {
    type     = "ssh"
    user     = "root"
    host = "${var.bastion_ip_address}"
    private_key = "${file(var.bastion_private_ssh_key)}"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /root/*",
      "ansible-playbook -i /root/inventory.cfg /usr/share/ansible/openshift-ansible/playbooks/prerequisites.yml",    
      "ansible-playbook -i /root/inventory.cfg /usr/share/ansible/openshift-ansible/playbooks/deploy_cluster.yml",
    ]
  }
}

#################################################
# Perform post-install configurations for Openshift
#################################################
resource "null_resource" "post_install_cluster" {

  connection {
    type     = "ssh"
    user     = "root"
    host = "${var.bastion_ip_address}"
    private_key = "${file(var.bastion_private_ssh_key)}"
  }

  provisioner "remote-exec" {
    inline = [
      "/tmp/scripts/post_install_steps.sh ${join(",",var.master_private_ip)} ${join(",",concat(var.app_private_ip,var.infra_private_ip,var.storage_private_ip))}",
    ]
  }
  depends_on    = ["null_resource.deploy_cluster"]
}