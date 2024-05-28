resource "azurerm_virtual_network" "this" {
  address_space           = var.virtual_network.address_space
  location                = var.location
  name                    = var.virtual_network.name
  resource_group_name     = var.resource_group_name
  bgp_community           = var.virtual_network.bgp_community
  dns_servers             = var.virtual_network.dns_servers
  edge_zone               = var.virtual_network.edge_zone
  flow_timeout_in_minutes = var.virtual_network.flow_timeout_in_minutes
  tags = var.tags

  dynamic "ddos_protection_plan" {
    for_each = var.virtual_network.ddos_protection_plan == null ? [] : [var.virtual_network.ddos_protection_plan]
    content {
      enable = ddos_protection_plan.value.enable
      id     = ddos_protection_plan.value.id
    }
  }
  dynamic "encryption" {
    for_each = var.virtual_network.encryption == null ? [] : [var.virtual_network.encryption]
    content {
      enforcement = encryption.value.enforcement
    }
  }
  dynamic "subnet" {
    for_each = var.virtual_network.subnet == null ? [] : var.virtual_network.subnet
    content {
      address_prefix = subnet.value.address_prefix
      name           = subnet.value.name
      security_group = subnet.value.security_group
    }
  }
}
