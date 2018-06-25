
# Rendering a installer config file for openshift installation
data "template_file" "ose_config" {
  template = "${file("${path.cwd}/templates/installer.cfg.yml.tpl")}"
  vars {
    master_private_ip = "${module.masternode.master_private_ip}"
    master_hostname = "${module.masternode.master_hostname}"
    master_public_ip = "${module.masternode.master_public_ip}"
    app_private_ip = "${module.appnode.app_private_ip}"
    app_hostname = "${module.appnode.app_hostname}"
    app_public_ip = "${module.appnode.app_public_ip}"
    infra_private_ip = "${module.infranode.infra_private_ip}"
    infra_hostname = "${module.infranode.infra_hostname}"
    infra_public_ip = "${module.infranode.infra_public_ip}"
  }
}

# Create a installer config file for openshift installation
resource "local_file" "ose_config_file" {
  content     = "${data.template_file.ose_config.rendered}"
  filename = "${path.cwd}/templates/installer.cfg.yml"
}

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

# Rendering the update master file.
data "template_file" "ose_master_config" {
  template = "${file("${path.cwd}/templates/update_master.sh.tpl")}"
  vars {
    bastion_public_ip = "${module.bastion.bastion_ip_address}"
  }
}

# Create the update master file.
resource "local_file" "ose_master_config_file" {
  content     = "${data.template_file.ose_master_config.rendered}"
  filename = "${path.cwd}/scripts/update_master.sh"
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