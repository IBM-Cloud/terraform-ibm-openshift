
variable "hourly_billing" {
  default = "true"
}

variable "datacenter" {
  default = "lon06"
}

variable "hostname_prefix"{
  default = "IBM-OCP"
}

variable "bastion_count" {
  default = 1
}

variable "master_count" {
  default = 1
}

variable "infra_count" {
  default = 1
}

variable "app_count" {
  default = 1
}

variable "storage_count" {
  description = "Set to 0 to configure openshift without glusterfs configuration and 3 or more to configure openshift with glusterfs"
  default = 0
}

variable "ssh_public_key" {
  default     = "~/.ssh/id_rsa.pub"
}

variable "ssh-label" {
  default = "ssh_key_terraform"
}

variable "vm_domain" {
  default = "IBM-OpenShift.cloud"
}


variable "ibm_sl_username"{
}


variable "ibm_sl_api_key"{
}

variable "rhn_username"{
  default = ""
}

variable "rhn_password"{
  default = ""
}

variable "pool_id"{
   default = ""
}

variable "private_ssh_key"{
  default     = "~/.ssh/id_rsa"
}

variable vlan_count {
  description = "Set to 0 if using existing and 1 if deploying a new VLAN"
  default = "1"
}
variable private_vlanid {
  description = "ID of existing private VLAN to connect VSIs"
  default = "2543851"
}

variable public_vlanid {
  description = "ID of existing public VLAN to connect VSIs"
  default = "2543849"
}

### Flavors to be changed to actual values in '#...'

variable bastion_flavor {
  default = "B1_4X16X100"
}

variable master_flavor {
   default = "B1_4X16X100"
}

variable infra_flavor {
   default = "B1_4X16X100"
}

variable app_flavor {
   default = "B1_4X16X100"
}

variable storage_flavor {
   default = "B1_4X16X100"
}