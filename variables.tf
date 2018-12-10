variable "datacenter" {
  default = "dal05"
}

variable "infra_count" {
  default = 1
}

variable "app_count" {
  default = 1
}

variable "ssh_public_key" {
  default     = "~/.ssh/id_rsa.pub"
}

variable "ssh-label" {
  default = "ssh_key_openshift"
}

variable "vm_domain" {
  default = "ibm.com"
}


variable "ibm_sl_username"{
}


variable "ibm_sl_api_key"{
}

variable "private_ssh_key"{
  default     = "~/.ssh/id_rsa"
}

variable "rhn_username"{
}

variable "rhn_password"{
}

variable vlan_count {
  description = "Set to 0 if using existing and 1 if deploying a new VLAN"
  default = "1"
}
variable private_vlanid {
  description = "ID of existing private VLAN to connect VSIs"
  default = "CHANGE ME if vlan_count = 0"
}

variable public_vlanid {
  description = "ID of existing public VLAN to connect VSIs"
  default = "CHANGE ME if vlan_count = 0"
}

variable gw_count {
  description = "Set to 0 if using existing and 1 if deploying a new Vyatta Gateway"
  default = "0"
}

variable bastion_flavor {
  default = "B1_4X8X100"
}

variable master_flavor {
  default = "B1_4X8X100"
}

variable infra_flavor {
  default = "B1_4X8X100"
}

variable app_flavor {
  default = "B1_4X8X100"
}

variable app_lbass_name {
  default = "openshift-app"
}

variable infra_lbass_name {
  default = "openshift-infra"
}