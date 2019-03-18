
##############################################################################
# Create a local loadbalancer for Infra node
##############################################################################
resource "ibm_lbaas" "infra_lb" {
  name        = "${var.infra_lb_name}-${var.random_id}"
  description = "load-balancer for infra nodes"
  subnets     = ["${var.infra_subnet_id}"]
}

resource "ibm_lbaas_server_instance_attachment" "infra_lb_member" {
  count              = "${var.infra_node_count}"
  private_ip_address = "${element(var.infra_private_ip,count.index)}"
  weight             = 50
  lbaas_id           = "${ibm_lbaas.infra_lb.id}"
}
