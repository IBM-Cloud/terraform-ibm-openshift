data "template_file" "ose_repo_config" {
  template = "${file("${path.cwd}/template/ose.repo.tpl")}"
  vars {
    bastion_public_ip = "${module.bastion.bastion_ip_address}"
    
  }
}

//  Create the config file used for openshoft installation
resource "local_file" "ose_repo_config_file" {
  content     = "${data.template_file.ose_repo_config.rendered}"
  filename = "${path.cwd}/scripts/ose.repo"
}