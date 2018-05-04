# STORAGE.tf
# This module deploys the storage services for the architecture
# file storage for infra nodes
# block storage for master and app tiers

provider "ibm" {}

#################################################
# Block Storage
#################################################

resource "ibm_storage_block" "appnodeblock" {
  count          = "${var.storage_count}"
  type           = "Performance"
  datacenter     = "${var.datacenter}"
  capacity       = 80
  iops           = 100
  os_format_type = "Linux"
}

##################################################
# variables
##################################################
variable "storage_count"{}

variable "datacenter" {}

################################################
# Output variables
################################################

output "appnodeblockid" {
  value = "${ibm_storage_block.appnodeblock.*.id}"
}
