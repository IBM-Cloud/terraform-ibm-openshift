#################################################
# Output Bastion Node
#################################################
output "bastion_public_ip" {
  value = "${module.bastion.bastion_ip_address}"
}

output "bastion_private_ip" {
  value = "${module.bastion.bastion_private_ip}"
}

output "bastion_hostname" {
  value = "${module.bastion.bastion_hostname}"
}


#################################################
# Output Master Node
#################################################
output "master_private_ip" {
  value = "${module.masternode.master_private_ip}"
}

output "master_hostname" {
  value = "${module.masternode.master_host}"
}

output "master_public_ip" {
  value = "${module.masternode.master_public_ip}"
}


#################################################
# Output Infra Node
#################################################
output "infra_private_ip" {
  value = "${module.infranode.infra_private_ip}"
}

output "infra_hostname" {
  value = "${module.infranode.infra_host}"
}

output "infra_public_ip" {
  value = "${module.infranode.infra_public_ip}"
}


#################################################
# Output App Node
#################################################
output "app_private_ip" {
  value = "${module.appnode.app_private_ip}"
}

output "app_hostname" {
  value = "${module.appnode.app_host}"
}

output "app_public_ip" {
  value = "${module.appnode.app_public_ip}"
}




