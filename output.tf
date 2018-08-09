
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
output "master_host" {
  value = "${module.masternode.master_hostname}"
}

output "master_hostname" {
  value = "${module.masternode.master_host}"
}