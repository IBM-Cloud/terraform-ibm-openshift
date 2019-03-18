resource "ibm_security_group" "openshift-bastion" {
  name        = "${var.bastion_sg_name}-${var.random_id}"
  description = "${var.bastion_sg_description}"
}

resource "ibm_security_group_rule" "openshift-bastion-ingress_rule1" {
  direction         = "ingress"
  port_range_min    = "22"
  port_range_max    = "22"
  protocol          = "tcp"
  security_group_id = "${ibm_security_group.openshift-bastion.id}"
}

resource "ibm_security_group_rule" "openshift-bastion-ingress_rule2" {
  direction         = "ingress"
  port_range_min    = "80"
  port_range_max    = "80"
  protocol          = "tcp"
  security_group_id = "${ibm_security_group.openshift-bastion.id}"
}

resource "ibm_security_group_rule" "openshift-bastion-ingress_rule3" {
  direction         = "ingress"
  port_range_min    = "443"
  port_range_max    = "443"
  protocol          = "tcp"
  security_group_id = "${ibm_security_group.openshift-bastion.id}"
}

resource "ibm_security_group_rule" "openshift-bastion-egress_rule1" {
  direction         = "egress"
  security_group_id = "${ibm_security_group.openshift-bastion.id}"
}