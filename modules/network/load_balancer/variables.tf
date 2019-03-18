#################################################
# Common Variables
#################################################
variable "random_id" {}

#################################################
# Load Balancer Variables for App Node 
#################################################
variable "app_node_count" {
}
variable "app_lb_name" {
}
variable "app_subnet_id" {
}
variable "app_private_ip" {
  type = "list"
} 

#################################################
# Load Balancer Variables for Infra Node 
#################################################
variable "infra_node_count" {
}
variable "infra_lb_name" {
}
variable "infra_subnet_id" {
}
variable "infra_private_ip" {
  type = "list"
} 
