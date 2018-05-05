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
}

variable "ssh-label" {
  default = "ssh_key_openshift"
}

variable "vm-domain" {
  default = "ibm.com"
}

variable "ibm_sl_username"{}

variable "ibm_sl_api_key"{}