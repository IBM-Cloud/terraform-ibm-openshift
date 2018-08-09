resource "null_resource" "post_install" {

  connection {
    type     = "ssh"
    user     = "root"
    host = "${var.bastion_ip_address}"
    private_key = "${file(var.private_ssh_key)}"
  }

    provisioner "remote-exec" {
    inline = [
     
      "/tmp/scripts/post_install_steps.sh ${join(",",var.master_private_ip)} ${join(",",concat(var.app_private_ip,var.infra_private_ip))}",

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
