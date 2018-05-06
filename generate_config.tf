data "template_file" "ose_config" {
  template = "${file("${path.cwd}/template/installer.cfg.yml.tpl")}"
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

//  Create the config file used for openshoft installation
resource "local_file" "ose_config_file" {
  content     = "${data.template_file.ose_config.rendered}"
  filename = "${path.cwd}/template/installer.cfg.yml"
}