provider ibm {}

//  This security group allows public ingress to the instances for HTTP, HTTPS
//  and common HTTP/S proxy ports.

//bastion sg
resource "ibm_security_group" "openshift-bastion" {
  name        = "${var.bastion_name}-${var.random_id}"
  description = "${var.bastion_description}"
}

resource "ibm_security_group_rule" "openshift-bastion-ingress_rule1" {
  direction         = "ingress"
  port_range_min    = "22"
  port_range_max    = "22"
  protocol          = "tcp"
  security_group_id = "${ibm_security_group.openshift-bastion.id}"
}

resource "ibm_security_group_rule" "openshift-bastion-egress_rule1" {
  direction         = "egress"
  security_group_id = "${ibm_security_group.openshift-bastion.id}"
}

//Ose master sg
resource "ibm_security_group" "openshift-master" {
  name        = "${var.master_name}-${var.random_id}"
  description = "${var.master_description}"
}

resource "ibm_security_group_rule" "openshift-master-ingress_rule1" {
  direction         = "ingress"
  port_range_min    = "22"
  port_range_max    = "22"
  protocol          = "tcp"
  security_group_id = "${ibm_security_group.openshift-master.id}"
  remote_ip         = "${ibm_security_group.openshift-bastion.id}"
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
  port_range_min    = "8053"
  port_range_max    = "8053"
  protocol          = "tcp"
  security_group_id = "${ibm_security_group.openshift-master.id}"
}

resource "ibm_security_group_rule" "openshift-master-ingress_rule4" {
  direction         = "ingress"
  port_range_min    = "8053"
  port_range_max    = "8053"
  protocol          = "udp"
  security_group_id = "${ibm_security_group.openshift-master.id}"
}

resource "ibm_security_group_rule" "openshift-master-ingress_rule5" {
  direction         = "ingress"
  port_range_min    = "53"
  port_range_max    = "53"
  protocol          = "tcp"
  security_group_id = "${ibm_security_group.openshift-master.id}"
}

resource "ibm_security_group_rule" "openshift-master-ingress_rule6" {
  direction         = "ingress"
  port_range_min    = "53"
  port_range_max    = "53"
  protocol          = "udp"
  security_group_id = "${ibm_security_group.openshift-master.id}"
}

resource "ibm_security_group_rule" "openshift-master-ingress_rule7" {
  direction         = "ingress"
  port_range_min    = "2379"
  port_range_max    = "2379"
  protocol          = "tcp"
  security_group_id = "${ibm_security_group.openshift-master.id}"
}

resource "ibm_security_group_rule" "openshift-master-ingress_rule8" {
  direction         = "ingress"
  port_range_min    = "2380"
  port_range_max    = "2380"
  protocol          = "tcp"
  security_group_id = "${ibm_security_group.openshift-master.id}"
}

#Allow Inbound to nodeport to access the app deployed on openshift.
resource "ibm_security_group_rule" "openshift-master-ingress_rule9" {
  direction         = "ingress"
  port_range_min    = "30000"
  port_range_max    = "32767"
  protocol          = "tcp"
  security_group_id = "${ibm_security_group.openshift-master.id}"
}

resource "ibm_security_group_rule" "openshift-master-egress_rule1" {
  direction         = "egress"
  security_group_id = "${ibm_security_group.openshift-master.id}"
}

#ose_node_sg
resource "ibm_security_group" "openshift-node" {
  name        = "${var.node_name}-${var.random_id}"
  description = "${var.node_description}"
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


resource "ibm_security_group_rule" "openshift-node-egress_rule1" {
  direction         = "egress"
  security_group_id = "${ibm_security_group.openshift-node.id}"
}



#Variable
variable "random_id" {}

//variable "openshift_gateway_public_address" {}

variable "bastion_name" {
  default     = "ose_bastion_sg"
  description = "Name of the security group"
}

variable "bastion_description" {
  default     = "bastion security grp for vms"
  description = "Description of the security group"
}

variable "master_name" {
  default     = "ose_master_sg"
  description = "Name of the security group"
}

variable "master_description" {
  default     = "master security grp for vms"
  description = "Description of the security group"
}

variable "node_name" {
  default     = "ose_node_sg"
  description = "Name of the security group"
}

variable "node_description" {
  default     = "node security grp for vms"
  description = "Description of the security group"
}

# Outputs
output "openshift_master_id" {
  value = "${ibm_security_group.openshift-master.id}"
}

output "openshift_bastion_id" {
  value = "${ibm_security_group.openshift-bastion.id}"
}

output "openshift_node_id" {
  value = "${ibm_security_group.openshift-node.id}"
}
