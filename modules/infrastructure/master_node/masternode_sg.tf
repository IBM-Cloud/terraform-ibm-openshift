//Ose master sg
resource "ibm_security_group" "openshift-master" {
  name        = "${var.master_sg_name}-${var.random_id}"
  description = "${var.master_sg_description}"
}

resource "ibm_security_group_rule" "openshift-master-ingress_rule1" {
  direction         = "ingress"
  port_range_min    = "22"
  port_range_max    = "22"
  protocol          = "tcp"
  security_group_id = "${ibm_security_group.openshift-master.id}"
}

resource "ibm_security_group_rule" "openshift-master-ingress_rule2" {
  direction         = "ingress"
  port_range_min    = "443"
  port_range_max    = "443"
  protocol          = "tcp"
  security_group_id = "${ibm_security_group.openshift-master.id}"
}

resource "ibm_security_group_rule" "openshift-master-ingress_rule3" {
  direction         = "ingress"
  port_range_min    = "80"
  port_range_max    = "80"
  protocol          = "tcp"
  security_group_id = "${ibm_security_group.openshift-master.id}"
}

resource "ibm_security_group_rule" "openshift-master-ingress_rule4" {
  direction         = "ingress"
  port_range_min    = "8053"
  port_range_max    = "8053"
  protocol          = "tcp"
  security_group_id = "${ibm_security_group.openshift-master.id}"
}

resource "ibm_security_group_rule" "openshift-master-ingress_rule5" {
  direction         = "ingress"
  port_range_min    = "8053"
  port_range_max    = "8053"
  protocol          = "udp"
  security_group_id = "${ibm_security_group.openshift-master.id}"
}

resource "ibm_security_group_rule" "openshift-master-ingress_rule6" {
  direction         = "ingress"
  port_range_min    = "53"
  port_range_max    = "53"
  protocol          = "tcp"
  security_group_id = "${ibm_security_group.openshift-master.id}"
}

resource "ibm_security_group_rule" "openshift-master-ingress_rule7" {
  direction         = "ingress"
  port_range_min    = "53"
  port_range_max    = "53"
  protocol          = "udp"
  security_group_id = "${ibm_security_group.openshift-master.id}"
}

resource "ibm_security_group_rule" "openshift-master-ingress_rule8" {
  direction         = "ingress"
  port_range_min    = "2379"
  port_range_max    = "2379"
  protocol          = "tcp"
  security_group_id = "${ibm_security_group.openshift-master.id}"
}

resource "ibm_security_group_rule" "openshift-master-ingress_rule9" {
  direction         = "ingress"
  port_range_min    = "2380"
  port_range_max    = "2380"
  protocol          = "tcp"
  security_group_id = "${ibm_security_group.openshift-master.id}"
}

#Allow Inbound to nodeport to access the app deployed on openshift.
resource "ibm_security_group_rule" "openshift-master-ingress_rule10" {
  direction         = "ingress"
  port_range_min    = "30000"
  port_range_max    = "32767"
  protocol          = "tcp"
  security_group_id = "${ibm_security_group.openshift-master.id}"
}

resource "ibm_security_group_rule" "openshift-master-ingress_rule11" {
  direction         = "ingress"
  port_range_min    = "8443"
  port_range_max    = "8443"
  protocol          = "tcp"
  security_group_id = "${ibm_security_group.openshift-master.id}"
}

resource "ibm_security_group_rule" "openshift-master-ingress_rule12" {
  direction         = "ingress"
  port_range_min    = "4789"
  port_range_max    = "4789"
  protocol          = "udp"
  security_group_id = "${ibm_security_group.openshift-master.id}"
}

resource "ibm_security_group_rule" "openshift-master-ingress_rule13" {
  direction         = "ingress"
  port_range_min    = "2049"
  port_range_max    = "2049"
  protocol          = "udp"
  security_group_id = "${ibm_security_group.openshift-master.id}"
}

resource "ibm_security_group_rule" "openshift-master-ingress_rule14" {
  direction         = "ingress"
  port_range_min    = "2049"
  port_range_max    = "2049"
  protocol          = "tcp"
  security_group_id = "${ibm_security_group.openshift-master.id}"
}

resource "ibm_security_group_rule" "openshift-master-ingress_rule15" {
  direction         = "ingress"
  port_range_min    = "8444"
  port_range_max    = "8444"
  protocol          = "tcp"
  security_group_id = "${ibm_security_group.openshift-master.id}"
}

resource "ibm_security_group_rule" "openshift-master-egress_rule1" {
  direction         = "egress"
  security_group_id = "${ibm_security_group.openshift-master.id}"
}
