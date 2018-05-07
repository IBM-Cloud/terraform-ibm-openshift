# LB.tf
# Used to create the local IBM load balancer for the VMs in the infra
#
##############################################################################
# Create a local loadbalancer
##############################################################################
resource "ibm_lb" "local_lb_infranode" {
  connections = "${var.lb-connections}"
  datacenter  = "${var.datacenter}"
  ha_enabled  = false
  dedicated   = "${var.lb-dedicated}"
}

resource "ibm_lb_service_group" "lb_service_group_infranode" {
  port             = "${var.lb-servvice-group-port}"
  routing_method   = "${var.lb-servvice-group-routing-method}"
  routing_type     = "${var.lb-servvice-group-routing-type}"
  load_balancer_id = "${ibm_lb.local_lb_infranode.id}"
  allocation       = "${var.lb-servvice-group-routing-allocation}"
}

resource "ibm_lb_service" "test_service" {
  count             = "${var.node_count}"
  port              = 80
  enabled           = true
  service_group_id  = "${ibm_lb_service_group.lb_service_group_infranode.service_group_id}"
  weight            = 1
  health_check_type = "DNS"

  ip_address_id = "${element(var.ip_address_id, count.index)}"
}

# Variables defined on loadbalancer

variable "ip_address_id" {
  type = "list"
}

variable "node_count" {}

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

output "lbass_id_infranode" {
  value = "${ibm_lb_service_group.lb_service_group_infranode.id}"
}

output "cluster_address_infranode" {
  value = "http://${ibm_lb.local_lb_infranode.ip_address}"
}
