# Render the ose.repo file to use bastion private IP I
data "template_file" "ose_repo_config" {
  template = "${file("${path.cwd}/templates/ose.repo.tpl")}"
  vars {
    bastion_private_ip = "${module.bastion.bastion_private_ip}"
    
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
    bastion_private_ip = "${module.bastion.bastion_private_ip}"
  }
}

# Create the update node file.
resource "local_file" "ose_nodes_config_file" {
  content     = "${data.template_file.ose_nodes_config.rendered}"
  filename = "${path.cwd}/scripts/update_nodes.sh"
}


# Create the Inventory file with master node info.
data "template_file" "ose_inventory" {
  template = "${file("${path.cwd}/templates/inventory.cfg.tpl")}"
  vars {
    master_hostname = "${module.masternode.master_hostname}"
  }
}

# Create a installer config file for openshift installation
resource "local_file" "ose_inventory_file" {
  content     = "${data.template_file.ose_inventory.rendered}\n"
  filename = "${path.cwd}/templates/inventory.cfg"
}

#--------------------------------#
#--------------------------------#

#Add app nodes to the inventory
data "template_file" "app_node_template" {
  count = "${length(module.appnode.app_host)}"
  template = "$${app_hostname} openshift_hostname=$${app_hostname} openshift_node_labels=\"{'region': 'primary', 'zone': 'east'}\""
  vars {
    app_hostname = "${element(module.appnode.app_host, count.index)}.${var.vm-domain}"
  }
}

resource "null_resource" "app_rendered_template8" {
  
  depends_on = ["local_file.ose_inventory_file"]
  provisioner "local-exec" {command = "cat >> ${path.cwd}/templates/inventory.cfg <<EOL\n${join("\n", data.template_file.app_node_template.*.rendered)}\nEOL"
  }
}

#--------------------------------#
#--------------------------------#

#Add infra nodes to the inventory

data "template_file" "infra_node_template" {
  count = "${length(module.infranode.infra_host)}"
  template = "$${infra_hostname} openshift_hostname=$${infra_hostname} openshift_node_labels=\"{'region': 'infra', 'zone': 'west'}\""
  vars {
    infra_hostname = "${element(module.infranode.infra_host, count.index)}.${var.vm-domain}"
  }
}

resource "null_resource" "infra_rendered_template8" {
  depends_on = ["local_file.ose_inventory_file","null_resource.app_rendered_template8"]
  provisioner "local-exec" {
    command = "cat >> ${path.cwd}/templates/inventory.cfg <<EOL\n${join("\n", data.template_file.infra_node_template.*.rendered)}\nEOL"
  }
}

#--------------------------------#
#--------------------------------#

# Create host file

data "template_file" "master_host_file_template" {
  template = "$${master_ip} $${master_hostname} $${master_hostname_domain} "
  vars {
    master_ip = "${module.masternode.master_private_ip}"
    master_hostname = "${module.masternode.master_host}"
    master_hostname_domain = "${module.masternode.master_host}.${var.vm-domain}"
  }
}

resource "null_resource" "master_host_file_render" {
  provisioner "local-exec" {
    command = "cat >> ${path.cwd}/scripts/hosts <<EOL\n${join("\n", data.template_file.master_host_file_template.*.rendered)}\nEOL"
  }
}

data "template_file" "app_host_file_template" {
  count = "${length(module.appnode.app_host)}"
  template = "$${app_ip} $${app_hostname} $${app_hostname_domain} "
  vars {
    app_ip = "${element(module.appnode.app_private_ip, count.index)}"
    app_hostname = "${element(module.appnode.app_host, count.index)}"
    app_hostname_domain = "${element(module.appnode.app_host, count.index)}.${var.vm-domain}"
  }
}

resource "null_resource" "app_host_file_render" {
  depends_on = ["null_resource.master_host_file_render"]
  provisioner "local-exec" {
    command = "cat >> ${path.cwd}/scripts/hosts <<EOL\n${join("\n", data.template_file.app_host_file_template.*.rendered)}\nEOL"
  }
}

data "template_file" "infra_host_file_template" {
  count = "${length(module.infranode.infra_host)}"
  template = "$${infra_ip} $${infra_hostname} $${infra_hostname_domain} "
  vars {
    infra_ip = "${element(module.infranode.infra_private_ip, count.index)}"
    infra_hostname = "${element(module.infranode.infra_host, count.index)}"
    infra_hostname_domain = "${element(module.infranode.infra_host, count.index)}.${var.vm-domain}"
  }
}

resource "null_resource" "infra_host_file_render" {
  depends_on = ["null_resource.app_host_file_render"]
  provisioner "local-exec" {
    command = "cat >> ${path.cwd}/scripts/hosts <<EOL\n${join("\n", data.template_file.infra_host_file_template.*.rendered)}\nEOL"
  }
}





