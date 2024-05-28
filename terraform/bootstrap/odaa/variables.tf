variable "location" {
  type        = string
  description = "(Required) The Azure location where the Oracle deployment should exist. Changing this forces a new resource to be created."
  nullable    = false
}

variable "resource_group_name" {
  type        = string
  description = "The resource group where the resources will be deployed."
}

variable "tags" {
  type        = map(string)
  default     = null
  description = "(Optional) Tags of the resource."
}

variable "virtual_network" {
  type = object({
    address_space           = list(string)
    name                    = string
    bgp_community           = optional(string,null)
    ddos_protection_plan    = optional(object({
      enable = bool
      id     = string
    }),null)
    dns_servers             = optional(list(string),null)
    edge_zone               = optional(string,null)
    encryption              = optional(object({
      enforcement = string
    }),null)
    flow_timeout_in_minutes = optional(number,null)
    subnet                  = optional(set(object({
      address_prefix = string
      name           = string
      security_group = optional(string,null)
    })),null)
  })
}

variable "route_table" {
  type = object({
    name                   = string
    disable_bgp_route_propagation = optional(bool,null)
    route                  = optional(set(object({
      address_prefix         = string
      name                   = string
      next_hop_in_ip_address = string
      next_hop_type          = string
    })),null)
  })
}