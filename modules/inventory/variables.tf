variable "bastion_private_ip" {

}

variable "master_private_ip" {
  type = "list"

}

variable "master_public_ip" {
  type = "list"

}

variable "infra_private_ip" {
   type = "list"

}

variable "infra_public_ip" {
   type = "list"

}

variable "app_private_ip" {
   type = "list"

}

variable "storage_private_ip" {
   type = "list"

}

variable "master_host" {
   type = "list"

}

variable "infra_host" {
   type = "list"

}

variable "app_host" {
   type = "list"

}

variable "storage_host" {
   type = "list"

}


variable "domain" {

}

variable "master_node_count" {

}

variable "infra_node_count" {

}

variable "app_node_count" {

}

variable "storage_node_count" {

}
