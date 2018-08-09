
#Bastion Node Output
output "bastion_public_ip" {
  value = "${module.bastion.bastion_ip_address}"
}

output "bastion_private_ip" {
  value = "${module.bastion.bastion_private_ip}"
}

output "bastion_hostname" {
  value = "${module.bastion.bastion_hostname}"
}

output "bastion_domain" {
  value = "${module.bastion.bastion_domain}"
} 


# APP Node output
output "app_private_ip" {
  value = "${module.appnode.app_private_ip}"
}

output "app_hostname" {
  value = "${module.appnode.app_host}"
}

# Infra Node output


output "infra_private_ip" {
  value = "${module.infranode.infra_private_ip}"
}

output "infra_hostname" {
  value = "${module.infranode.infra_host}"
}

# Master Node output

output "master_private_ip" {
  value = "${module.masternode.master_private_ip}"
}

output "master_hostname" {
  value = "${module.masternode.master_host}"
}

output "master_public_ip" {
  value = "${module.masternode.master_public_ip}"
}

# lbass output

output "app_lbass_url" {
  value = "${module.lbaas_app.app_lbass_vip}"
}

output "infra_lbass_url" {
  value = "${module.lbaas_infra.infra_lbass_vip}"
}