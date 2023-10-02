variable "location" {
  description = "Defines the Azure location where the resources will be deployed"
  type        = string
  default     = "eastus"
}

variable "resourcegroup_name" {
  description = "If defined, the name of the resource group into which the resources will be deployed"
  default     = ""
}

variable "resourcegroup_arm_id" {
  description = "Azure resource identifier for the resource group into which the resources will be deployed"
  default     = ""
}

variable "resourcegroup_tags" {
  description = "tags to be added to the resource group"
  default     = {}
}

variable "database_db_nic_ips" {
  description = "If provided, the database tier virtual machines will be configured using the specified IPs"
  default     = [""]
}

variable "ssh_key" {
  description = "value of the ssh public key to be used for the virtual machines"
}
