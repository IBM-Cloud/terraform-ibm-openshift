output "app_lbass_vip" {
  value = "${ibm_lbaas.app_lb.vip}"
}

output "infra_lbass_vip" {
  value = "${ibm_lbaas.infra_lb.vip}"
}
