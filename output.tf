
#Bastion Node Output
output "bastion_public_ip" {
  value = "${module.bastion.bastion_ip_address}"
}

# APP Node output
output "app_public_ip" {
  value = "${module.appnode.app_public_ip}"
}

output "app_private_ip" {
  value = "${module.appnode.app_private_ip}"
}
output "app_host" {
  value = "${module.appnode.app_hostname}"
}

# Infra Node output
output "infra_public_ip" {
  value = "${module.infranode.infra_public_ip}"
}

output "infra_private_ip" {
  value = "${module.infranode.infra_private_ip}"
}
output "infra_host" {
  value = "${module.infranode.infra_hostname}"
}

# Master Node output
output "master_public_ip" {
  value = "${module.masternode.master_public_ip}"
}

output "master_private_ip" {
  value = "${module.masternode.master_private_ip}"
}
output "master_host" {
  value = "${module.masternode.master_hostname}"
}



