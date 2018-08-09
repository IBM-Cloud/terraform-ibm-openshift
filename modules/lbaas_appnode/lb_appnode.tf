# LB.tf
# Used to create the local IBM load balancer for the VMs in the app node
#

##############################################################################
# Create a local loadbalancer
##############################################################################
resource "ibm_lbaas" "app_lbaas" {
  name        = "${var.app_lbass_name}-${var.random_id}"
  description = "lbass for app nodes"
  subnets     = ["${var.subnet_id}"]
}


resource "ibm_lbaas_server_instance_attachment" "app_lbaas_member" {
  count = "${var.node_count}"
  private_ip_address = "${element(var.app_private_ip,count.index)}"
  weight             = 50
  lbaas_id           = "${ibm_lbaas.app_lbaas.id}"
}

variable "app_lbass_name" {

}

variable "subnet_id" {
}

variable "app_private_ip" {
  type = "list"
} 

variable "node_count" {

}

variable "random_id" {}

output "app_lbass_vip" {
  value = "${ibm_lbaas.app_lbaas.vip}"
}
