# LB.tf
# Used to create the local IBM load balancer for the VMs in the infra node
#

##############################################################################
# Create a local loadbalancer
##############################################################################
resource "ibm_lbaas" "infra_lbaas" {
  name        = "${var.infra_lbass_name}-${var.random_id}"
  description = "lbass for infra nodes"
  subnets     = ["${var.subnet_id}"]
}


resource "ibm_lbaas_server_instance_attachment" "infra_lbaas_member" {
  count = "${var.node_count}"
  private_ip_address = "${element(var.infra_private_ip,count.index)}"
  weight             = 50
  lbaas_id           = "${ibm_lbaas.infra_lbaas.id}"
}

variable "infra_lbass_name" {

}

variable "subnet_id" {
}

variable "infra_private_ip" {
  type = "list"
} 

variable "node_count" {

}

variable "random_id" {}

output "infra_lbass_vip" {
  value = "${ibm_lbaas.infra_lbaas.vip}"
}