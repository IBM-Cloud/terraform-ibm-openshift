#################################################
# Common Variables
#################################################
variable "random_id" {}
variable "datacenter" {}
variable "domain" {}
variable "private_vlan_id" {}
variable "public_vlan_id" {}
variable "block_storage_type" {
    default = "Performance"
}
variable "hourly_billing" {}

#################################################
# Storage node Variables
#################################################
variable "storage_node_count" {}
variable "storage_hostname" {
  default = "storage"
}
variable "storage_hostname_prefix" {
  default = "IBM"
}
variable "storage_flavor" {}
variable "storage_os_ref_code" {
  default = "REDHAT_7_64"
}
variable "storage_node_pub_sg" {}

variable "storage_node_prv_sg" {}

variable "storage_ssh_key_ids" {
  type = "list"
}

variable "storage_private_ssh_key" {}