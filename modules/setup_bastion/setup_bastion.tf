resource "null_resource" "setup_bastion" {

  connection {
    type     = "ssh"
    user     = "root"
    host = "${var.bastion_ip_address}"
    private_key = "${file(var.private_ssh_key)}"
  }
  provisioner "file" {
    source      = "${path.cwd}/scripts"
    destination = "/tmp"
   
  }


    provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/scripts/*",
      "/tmp/scripts/rhn_register.sh ${var.rhn_username} ${var.rhn_password} ${var.pool_id}",

    ]
  
    }

}


variable "bastion_ip_address" {

}


variable "private_ssh_key" {

}

variable "rhn_username"{

}

variable "rhn_password"{

}

variable "pool_id"{

}
