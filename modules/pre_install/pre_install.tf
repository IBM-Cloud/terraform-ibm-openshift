resource "null_resource" "pre_install" {

  connection {
    type     = "ssh"
    user     = "root"
    host = "${var.bastion_ip_address}"
    private_key = "${file(var.private_ssh_key)}"
  }

  provisioner "file" {
    source      = "${var.private_ssh_key}"
    destination = "~/.ssh/id_rsa"
  }

    provisioner "remote-exec" {
    inline = [
      "chmod 400 /root/.ssh/id_rsa",
      "cat /tmp/scripts/hosts >> /etc/hosts",
      "/tmp/scripts/pre_install_steps.sh ${join(",",concat(var.app_private_ip,var.infra_private_ip,var.master_private_ip))}",
      "/tmp/scripts/prepare_bastion.sh",

    ]
  
    }

}


variable "bastion_ip_address" {

}

variable "master_private_ip" {
  type="list"

}

variable "infra_private_ip" {
   type="list"

}

variable "app_private_ip" {
   type="list"

}

variable "private_ssh_key"{

}
