# STORAGE.tf
# This module deploys the storage services for the architecture
# file storage for infra nodes
# block storage for master and app nodes

provider "ibm" {}

#################################################
# File Storage
#################################################

resource "ibm_storage_file" "infranodefile" {
  type       = "Performance"
  datacenter = "${var.datacenter}"
  capacity   = "80"
  iops       = "100"
}

##################################################
# variables
##################################################

variable "datacenter" {}

################################################
# Output variables
################################################

output "infranodefileid" {
  value = "${ibm_storage_file.infranodefile.id}"
}
