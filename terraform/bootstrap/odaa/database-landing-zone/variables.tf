variable "location" {
  type        = string
  description = "(Required) The Azure location where the Oracle deployment should exist. Changing this forces a new resource to be created."
  nullable    = false
}

variable "resource_group_name" {
  type        = string
  description = "The resource group where the resources will be deployed."
}

variable "resource_group_id" {
  type        = string
  description = "The resource group id where the resources will be deployed."
}

variable "tags" {
  type = map(string)
  default = {
    scenario = "ODAA Terraform Deployment"
  }
  description = "(Optional) Tags of the resource."
}

variable "virtual_network" {
  type = object({
    address_space = list(string)
    name          = string
    ddos_protection_plan = optional(object({
      enable = bool
      id     = string
    }), null)
    encryption = optional(object({
      enforcement = string
    }), null)
    flow_timeout_in_minutes = optional(number, null)
    subnet = optional(set(object({
      delegate_to_oracle = bool
      address_prefixes   = list(string)
      name               = string
      security_group     = optional(string, null)
    })), null)
    peerings = optional(map(object({
      remote_vnet_id          = string
      allow_forwarded_traffic = bool
      allow_gateway_transit   = bool
      use_remote_gateways     = bool
    })), {})
  })
  default = {
    name          = "vnet-odaa"
    address_space = ["10.0.0.0/16"]
    subnet = [
      {
        name                  = "snet-odaa"
        address_prefixes      = ["10.0.0.0/24"]
        delegate_to_oracle    = true
        associate_route_table = false
    }]
  }
}

variable "route_tables" {
  type = map(object({
    name                          = string
    disable_bgp_route_propagation = optional(bool, null)
    route = optional(set(object({
      address_prefix         = string
      name                   = string
      next_hop_in_ip_address = string
      next_hop_type          = string
    })), null)
  }))
  default = {}
}

variable "deploy_odaa_infra" {
  type        = bool
  description = "Deploy the ODAA infrastructure"
  default     = false
}

variable "deploy_odaa_cluster" {
  type        = bool
  description = "Deploy the ODAA Cluster"
  default     = false
}

# Must be the same as odaa_infra_displayName
variable "odaa_infra_name" {
  description = "The name of the resource"
  type        = string
  default     = "odaa-infra"
}

variable "zones" {
  description = "The zones of the resource"
  type        = list(string)
  default     = ["3"]
}

variable "computeCount" {
  description = "The compute count of the resource"
  type        = number
  default     = 2
}

# Must be the same as odaa_infra_name
variable "odaa_infra_displayName" {
  description = "The display name of the resource"
  type        = string
  default     = "odaa-infra"
}

variable "leadTimeInWeeks" {
  description = "The lead time in weeks of the resource"
  type        = number
  default     = 0
}

variable "preference" {
  description = "The preference of the resource"
  type        = string
  default     = "NoPreference"
}

variable "patchingMode" {
  description = "The patching mode of the resource"
  type        = string
  default     = "Rolling"
}

variable "shape" {
  description = "The shape of the resource"
  type        = string
  default     = "Exadata.X9M"
}

variable "storageCount" {
  description = "The storage count of the resource"
  type        = number
  default     = 3
}

variable "odaa_cluster_name" {
  description = "The name of the resource"
  type        = string
  default     = "odaa-clstr"
  validation {
    condition     = length(var.odaa_cluster_name) <= 11
    error_message = "The length of the odac_cluster_name must be less than or equal to 11 characters."
  }
}

variable "schema_validation_enabled" {
  description = "Enable schema validation for the resource"
  type        = bool
  default     = false
}

variable "dataStorageSizeInTbs" {
  description = "The data storage size in TBs of the resource"
  type        = number
  default     = 30
  validation {
    condition     = var.dataStorageSizeInTbs <= 192
    error_message = "The data storage size in TBs must be less than or equal to 192."
  }
}

variable "dbNodeStorageSizeInGbs" {
  description = "The db node storage size in GBs of the resource"
  type        = number
  default     = 1000
}

variable "memorySizeInGbs" {
  description = "The memory size in GBs of the resource"
  type        = number
  default     = 1000
}

variable "timeZone" {
  description = "The time zone of the resource"
  type        = string
  default     = "UTC"
}

variable "hostname" {
  description = "The hostname of the resource"
  type        = string
  default     = "hostname1"
}

variable "domain" {
  description = "The domain of the resource"
  type        = string
  default     = "domain1"
}

variable "cpuCoreCount" {
  description = "The cpu core count of the resource"
  type        = number
  default     = 4
}

variable "ocpuCount" {
  description = "The ocpu count of the resource"
  type        = number
  default     = 3
}

variable "dataStoragePercentage" {
  description = "The data storage percentage of the resource"
  type        = number
  default     = 100
}

variable "isLocalBackupEnabled" {
  description = "The local backup enabled of the resource"
  type        = bool
  default     = false
}

variable "cloudExadataInfrastructureId" {
  description = "The cloud exadata infrastructure id of the resource"
  type        = string
  default     = ""
  # Example: "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg000/providers/Oracle.Database/cloudExadataInfrastructures/infra1"
}

variable "isSparseDiskgroupEnabled" {
  description = "The sparse diskgroup enabled of the resource"
  type        = bool
  default     = false
}

variable "sshPublicKeys" {
  description = "The ssh public keys of the resource"
  type        = list(string)
  default     = []
}

variable "nsgCidrs" {
  description = "Source and destination ranges"
  type        = list(any)
  default = [
    {
      "source": "10.0.0.0/16",
      "destinationPortRange": {
        "min": 1520,
        "max": 1522
      }
    } 
    # In Terraform, when you declare a variable of type list(any), the default value should be a list where each element is a map with the same structure.
  ]
}

variable "scanListenerPortTcp" {
  description = "The scan listener port tcp of the resource"
  type        = number
  default     = 1050
}

variable "scanListenerPortTcpSsl" {
  description = "The scan listener port tcp ssl of the resource"
  type        = number
  default     = 2484
}

variable "giVersion" {
  description = "The gi version of the resource"
  type        = string
  default     = "19.0.0.0"
}

variable "isDiagnosticsEventsEnabled" {
  description = "The diagnostics events enabled of the resource"
  type        = bool
  default     = false  
}

variable "isHealthMonitoringEnabled" {
  description = "The health monitoring enabled of the resource"
  type        = bool
  default     = false
}

variable "isIncidentLogsEnabled" {
  description = "The incident logs enabled of the resource"
  type        = bool
  default     = false
}

variable "odaa_cluster_displayName" {
  description = "The display name of the resource"
  type        = string
  default     = "cluster 1"
}

variable "backupSubnetCidr" {
  description = "The backup subnet CIDR range"
  type        = string
  default     = "10.1.0.0/24"
}