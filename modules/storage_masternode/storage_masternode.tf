# STORAGE.tf
# This module deploys the storage services for the architecture
# file storage for infra
# block storage for master and app

provider "ibm" {}

#################################################
# Block Storage
#################################################

resource "ibm_storage_block" "masterblock" {
  type           = "Performance"
  datacenter     = "${var.datacenter}"
  capacity       = 80
  iops           = 100
  os_format_type = "Linux"
}

##################################################
# variables
##################################################

variable "datacenter" {}

################################################
# Output variables
################################################
output "masterblockid" {
  value = "${ibm_storage_block.masterblock.id}"
}
