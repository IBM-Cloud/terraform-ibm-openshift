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
# App Node Variables
#################################################
variable "app_node_count" {}

variable "app_hostname" {
  default = "app"
}
variable "app_hostname_prefix" {
  default = "IBM"
}
variable "app_os_ref_code" {
  default = "REDHAT_7_64"
}
variable "app_flavor" {}

variable "app_node_pub_sg" {}

variable "app_node_prv_sg" {}

variable "app_ssh_key_ids" {
  type = "list"
}

variable "app_private_ssh_key" {}
