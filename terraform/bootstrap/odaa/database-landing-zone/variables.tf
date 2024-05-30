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
  type        = map(string)
  default     = {
    scenario = "ODAA Terraform Deployment"
  }
  description = "(Optional) Tags of the resource."
}

variable "virtual_network" {
  type = object({
    address_space           = list(string)
    name                    = string
    ddos_protection_plan    = optional(object({
      enable = bool
      id     = string
    }),null)
    encryption              = optional(object({
      enforcement = string
    }),null)
    flow_timeout_in_minutes = optional(number,null)
    subnet                  = optional(set(object({
      delegate_to_oracle = bool
      address_prefixes = list(string)
      name           = string
      security_group = optional(string,null)
    })),null)
    peerings = optional(map(object({
      remote_vnet_id          = string
      allow_forwarded_traffic = bool
      allow_gateway_transit   = bool
      use_remote_gateways     = bool
    })), {})
  })
  default = {
    name = "vnet-odaa"
    address_space = ["10.0.0.0/16"]
    subnet = [
    {
      name = "snet-odaa"
      address_prefixes = [ "10.0.0.0/24" ]
      delegate_to_oracle = true
      associate_route_table = false
    } ]
  }
}

variable "route_tables" {
  type = map(object({
    name                   = string
    disable_bgp_route_propagation = optional(bool,null)
    route                  = optional(set(object({
      address_prefix         = string
      name                   = string
      next_hop_in_ip_address = string
      next_hop_type          = string
    })),null)
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