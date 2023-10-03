variable "infrastructure" {
  description = "Details of the Azure infrastructure to deploy the SAP landscape into"
  default     = {}
}

variable "database" {
  description = "Details of the database node"
  default = {
    use_DHCP = true
    authentication = {
      type = "key"
    }
    data_disks = [
      {
        count                     = 1
        caching                   = "ReadOnly"
        create_option             = "Empty"
        disk_size_gb              = 1024
        lun                       = 0
        disk_type                 = "Premium_LRS"
        write_accelerator_enabled = false
      },
      {
        count                     = 1
        caching                   = "None"
        create_option             = "Empty"
        disk_size_gb              = 1024
        lun                       = 1
        disk_type                 = "Premium_LRS"
        write_accelerator_enabled = false
      }
    ]
  }
}

variable "options" {
  description = "Options for the Oracle deployment"
  default     = {}
}

variable "vnet_arm_id" {
  description = "ARM ID of the VNet to be deployed"
  default     = ""
}

variable "subnet_arm_id" {
  description = "ARM ID of the subnet to be deployed"
  default     = ""
}


variable "is_diagnostic_settings_enabled" {
  description = "Whether diagnostic settings are enabled"
  default     = false
}

variable "diagnostic_target" {
  description = "The destination type of the diagnostic settings"
  default     = "Log_Analytics_Workspace"
  validation {
    condition     = contains(["Log_Analytics_Workspace", "Storage_Account", "Event_Hubs", "Partner_Solutions"], var.diagnostic_target)
    error_message = "Allowed values are Log_Analytics_Workspace, Storage_Account, Event_Hubs, Partner_Solutions"
  }
}