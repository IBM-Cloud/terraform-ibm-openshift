# Outputs
output "openshift_node_id" {
  value = "${ibm_security_group.openshift-node.id}"
}
