# Render the ose.repo file to use bastion public I
data "template_file" "ose_repo_config" {
  template = "${file("${path.cwd}/templates/ose.repo.tpl")}"
  vars {
    bastion_public_ip = "${module.bastion.bastion_ip_address}"
    
  }
}

# Create the ose.repo file 
resource "local_file" "ose_repo_config_file" {
  content     = "${data.template_file.ose_repo_config.rendered}"
  filename = "${path.cwd}/scripts/ose.repo"
}

data "template_file" "ose_inventory" {
  template = "${file("${path.cwd}/templates/inventory.cfg.tpl")}"
  vars {
    master_hostname = "${module.masternode.master_hostname}"
    app_hostname = "${module.appnode.app_hostname}"
    infra_hostname = "${module.infranode.infra_hostname}"
  }
}

# Create a installer config file for openshift installation
resource "local_file" "ose_inventory_file" {
  content     = "${data.template_file.ose_inventory.rendered}"
  filename = "${path.cwd}/templates/inventory.cfg"
}

# Rendering the update node file.
data "template_file" "ose_nodes_config" {
  template = "${file("${path.cwd}/templates/update_nodes.sh.tpl")}"
  vars {
    bastion_public_ip = "${module.bastion.bastion_ip_address}"
  }
}

# Create the update node file.
resource "local_file" "ose_nodes_config_file" {
  content     = "${data.template_file.ose_nodes_config.rendered}"
  filename = "${path.cwd}/scripts/update_nodes.sh"
}