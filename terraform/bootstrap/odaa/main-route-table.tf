resource "azurerm_route_table" "this" {
    location                      = var.location
    name                          = var.route_table.name
    resource_group_name           = var.resource_group_name
    disable_bgp_route_propagation = var.route_table.disable_bgp_route_propagation
    tags                          = var.tags
  
    dynamic "route" {
      for_each = var.route_table.route == null ? [] : var.route_table.route
      content {
        address_prefix         = route.value.address_prefix
        name                   = route.value.name
        next_hop_in_ip_address = route.value.next_hop_in_ip_address
        next_hop_type          = route.value.next_hop_type
      }
    }
  }
  
  