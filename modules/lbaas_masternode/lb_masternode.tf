# LB.tf
# Used to create the local IBM load balancer for the VMs in the master
#

##############################################################################
# Create a local loadbalancer
##############################################################################
resource "ibm_lb" "local_lb_masternode" {
  connections = "${var.lb-connections}"
  datacenter  = "${var.datacenter}"
  ha_enabled  = false
  dedicated   = "${var.lb-dedicated}"
}

resource "ibm_lb_service_group" "lb_service_group_masternode" {
  port             = "${var.lb-servvice-group-port}"
  routing_method   = "${var.lb-servvice-group-routing-method}"
  routing_type     = "${var.lb-servvice-group-routing-type}"
  load_balancer_id = "${ibm_lb.local_lb_masternode.id}"
  allocation       = "${var.lb-servvice-group-routing-allocation}"
}

resource "ibm_lb_service" "test_service" {
  port              = 80
  enabled           = true
  service_group_id  = "${ibm_lb_service_group.lb_service_group_masternode.service_group_id}"
  weight            = 1
  health_check_type = "DNS"
  ip_address_id     = "${var.ip_address_id}"
}

# Variables defined on loadbalancer
variable "ip_address_id" {}

variable "lb-connections" {
  default = 250
}

variable "datacenter" {}

variable "lb-dedicated" {
  default = false
}

variable "lb-servvice-group-port" {
  default = 80
}

variable "lb-servvice-group-routing-method" {
  default = "CONSISTENT_HASH_IP"
}

variable "lb-servvice-group-routing-type" {
  default = "HTTP"
}

variable "lb-servvice-group-routing-allocation" {
  default = 100
}

#output

output "lbass_id_masternode" {
  value = "${ibm_lb_service_group.lb_service_group_masternode.id}"
}

output "cluster_address_masternode" {
  value = "http://${ibm_lb.local_lb_masternode.ip_address}"
}
