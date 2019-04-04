//  This security group allows public ingress to the instances for HTTP, HTTPS
//  and common HTTP/S proxy ports.

#ose_node_sg
resource "ibm_security_group" "openshift-node" {
  name        = "${var.node_sg_name}-${var.random_id}"
  description = "${var.node_sg_description}"
}

resource "ibm_security_group_rule" "openshift-node-ingress_rule1" {
  direction         = "ingress"
  port_range_min    = "443"
  port_range_max    = "443"
  protocol          = "tcp"
  security_group_id = "${ibm_security_group.openshift-node.id}"
}

resource "ibm_security_group_rule" "openshift-node-ingress_rule2" {
  direction         = "ingress"
  port_range_min    = "22"
  port_range_max    = "22"
  protocol          = "tcp"
  security_group_id = "${ibm_security_group.openshift-node.id}"
}

resource "ibm_security_group_rule" "openshift-node-ingress_rule3" {
  direction         = "ingress"
  port_range_min    = "10250"
  port_range_max    = "10250"
  protocol          = "tcp"
  security_group_id = "${ibm_security_group.openshift-node.id}"
}

resource "ibm_security_group_rule" "openshift-node-ingress_rule4" {
  direction         = "ingress"
  port_range_min    = "4789"
  port_range_max    = "4789"
  protocol          = "udp"
  security_group_id = "${ibm_security_group.openshift-node.id}"
}

resource "ibm_security_group_rule" "openshift-node-ingress_rule5" {
  direction         = "ingress"
  port_range_min    = "80"
  port_range_max    = "80"
  protocol          = "tcp"
  security_group_id = "${ibm_security_group.openshift-node.id}"
}

#Allow Inbound to nodeport to access the app deployed on openshift.
resource "ibm_security_group_rule" "openshift-node-ingress_rule6" {
  direction         = "ingress"
  port_range_min    = "30000"
  port_range_max    = "32767"
  protocol          = "tcp"
  security_group_id = "${ibm_security_group.openshift-node.id}"
}

resource "ibm_security_group_rule" "openshift-node-ingress_rule7" {
  direction         = "ingress"
  port_range_min    = "8443"
  port_range_max    = "8443"
  protocol          = "tcp"
  security_group_id = "${ibm_security_group.openshift-node.id}"
}

resource "ibm_security_group_rule" "openshift-node-ingress_rule8" {
  direction         = "ingress"
  port_range_min    = "10010"
  port_range_max    = "10010"
  protocol          = "tcp"
  security_group_id = "${ibm_security_group.openshift-node.id}"
}

resource "ibm_security_group_rule" "openshift-node-ingress_rule9" {
  direction         = "ingress"
  port_range_min    = "2222"
  port_range_max    = "2222"
  protocol          = "tcp"
  security_group_id = "${ibm_security_group.openshift-node.id}"
}

resource "ibm_security_group_rule" "openshift-node-ingress_rule10" {
  direction         = "ingress"
  port_range_min    = "24007"
  port_range_max    = "24007"
  protocol          = "tcp"
  security_group_id = "${ibm_security_group.openshift-node.id}"
}

resource "ibm_security_group_rule" "openshift-node-ingress_rule11" {
  direction         = "ingress"
  port_range_min    = "24008"
  port_range_max    = "24008"
  protocol          = "tcp"
  security_group_id = "${ibm_security_group.openshift-node.id}"
}

resource "ibm_security_group_rule" "openshift-node-ingress_rule12" {
  direction         = "ingress"
  port_range_min    = "49152"
  port_range_max    = "49251"
  protocol          = "tcp"
  security_group_id = "${ibm_security_group.openshift-node.id}"
}

resource "ibm_security_group_rule" "openshift-node-egress_rule1" {
  direction         = "egress"
  security_group_id = "${ibm_security_group.openshift-node.id}"
}

