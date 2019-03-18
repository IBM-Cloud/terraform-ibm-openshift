##############################################################################
# Create a local loadbalancer for App node
##############################################################################
resource "ibm_lbaas" "app_lb" {
  name        = "${var.app_lb_name}-${var.random_id}"
  description = "load-balancer for app nodes"
  subnets     = ["${var.app_subnet_id}"]
}


resource "ibm_lbaas_server_instance_attachment" "app_lb_member" {
  count              = "${var.app_node_count}"
  private_ip_address = "${element(var.app_private_ip,count.index)}"
  weight             = 50
  lbaas_id           = "${ibm_lbaas.app_lb.id}"
}


