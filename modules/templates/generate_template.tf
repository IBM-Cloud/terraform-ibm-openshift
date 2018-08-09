# Render the ose.repo file to use bastion private IP I
data "template_file" "ose_repo_config" {
  template = "${file("${path.cwd}/templates/ose.repo.tpl")}"
  vars {
    bastion_private_ip = "${var.bastion_private_ip}"
    
  }
}

# Create the ose.repo file 
resource "local_file" "ose_repo_config_file" {
  content     = "${data.template_file.ose_repo_config.rendered}"
  filename = "${path.cwd}/scripts/ose.repo"
}

#--------------------------------#
#--------------------------------#

# Rendering the update node file.
data "template_file" "ose_nodes_config" {
  template = "${file("${path.cwd}/templates/update_nodes.sh.tpl")}"
  vars {
    bastion_private_ip = "${var.bastion_private_ip}"
  }
}

# Create the update node file.
resource "local_file" "ose_nodes_config_file" {
  content     = "${data.template_file.ose_nodes_config.rendered}"
  filename = "${path.cwd}/scripts/update_nodes.sh"
}


# Create the Inventory file with master node info.
data "template_file" "ose_inventory" {
  count = "${var.master_count}"
  template = "${file("${path.cwd}/templates/inventory.cfg.tpl")}"
  vars {
    master_hostname = "${element(var.master_host, count.index)}.${var.vm_domain}"
    master_ip = "${element(var.master_private_ip, count.index)}"
  }
}

#--------------------------------#
#--------------------------------#

#Add infra nodes to the inventory

data "template_file" "infra_node_template" {
  count = "${var.infra_count}"
  template = "$${infra_hostname} openshift_hostname=$${infra_hostname} openshift_node_labels=\"{'region': 'infra', 'zone': 'west'}\""
  vars {
    infra_hostname = "${element(var.infra_host, count.index)}.${var.vm_domain}"
  }
}


#--------------------------------#
#--------------------------------#

#Add app nodes to the inventory
data "template_file" "app_node_template" {
  count = "${var.app_count}"
  template = "$${app_hostname} openshift_hostname=$${app_hostname} openshift_node_labels=\"{'region': 'primary', 'zone': 'east'}\""
  vars {
    app_hostname = "${element(var.app_host, count.index)}.${var.vm_domain}"
  }
}

# Create a installer config file for openshift installation
resource "local_file" "ose_inventory_file" {
  content     =  "${join("\n", concat(data.template_file.ose_inventory.*.rendered,data.template_file.infra_node_template.*.rendered,data.template_file.app_node_template.*.rendered))}"
  filename = "${path.cwd}/templates/inventory.cfg"
}



#--------------------------------#
#--------------------------------#

# Create host file

data "template_file" "master_host_file_template" {
  count = "${var.master_count}"
  template = "$${master_ip} $${master_hostname} $${master_hostname_domain} "
  vars {
    master_ip =  "${element(var.master_private_ip, count.index)}"
    master_hostname = "${element(var.master_host, count.index)}"
    master_hostname_domain = "${element(var.master_host, count.index)}.${var.vm_domain}"
  }
}


data "template_file" "app_host_file_template" {
  count = "${var.app_count}"
  template = "$${app_ip} $${app_hostname} $${app_hostname_domain} "
  vars {
    app_ip = "${element(var.app_private_ip, count.index)}"
    app_hostname = "${element(var.app_host, count.index)}"
    app_hostname_domain = "${element(var.app_host, count.index)}.${var.vm_domain}"
  }
}

data "template_file" "infra_host_file_template" {
  count = "${var.infra_count}"
  template = "$${infra_ip} $${infra_hostname} $${infra_hostname_domain} "
  vars {
    infra_ip = "${element(var.infra_private_ip, count.index)}"
    infra_hostname = "${element(var.infra_host, count.index)}"
    infra_hostname_domain = "${element(var.infra_host, count.index)}.${var.vm_domain}"
  }
}


data "template_file" "master_public_host_file_template" {
  count = "${var.master_count}"
  template = "$${master_ip} $${master_hostname} $${master_hostname_domain} "
  vars {
    master_ip =  "${element(var.master_public_ip, count.index)}"
    master_hostname = "${element(var.master_host, count.index)}"
    master_hostname_domain = "${element(var.master_host, count.index)}.${var.vm_domain}"
  }
}


# Create a installer config file for openshift installation
resource "local_file" "host_file_render" {
  content     =  "${join("\n", concat(data.template_file.master_host_file_template.*.rendered,data.template_file.infra_host_file_template.*.rendered,data.template_file.app_host_file_template.*.rendered,data.template_file.master_public_host_file_template.*.rendered))}"
  filename = "${path.cwd}/scripts/hosts"
}


variable "bastion_private_ip" {

}

variable "master_private_ip" {
  type = "list"

}

variable "master_public_ip" {
  type = "list"

}

variable "infra_private_ip" {
   type = "list"

}

variable "app_private_ip" {
   type = "list"

}


variable "master_host" {
   type = "list"

}

variable "infra_host" {
   type = "list"

}

variable "app_host" {
   type = "list"

}

variable "vm_domain" {

}

variable "master_count" {

}
variable "infra_count" {

}
variable "app_count" {

}
