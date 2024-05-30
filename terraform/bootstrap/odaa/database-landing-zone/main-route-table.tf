resource "azurerm_route_table" "rt_odaa" {
  for_each = var.route_tables
    location                      = var.location
    name                          = each.value.name
    resource_group_name           = var.resource_group_name
    disable_bgp_route_propagation = each.value.disable_bgp_route_propagation
    tags                          = var.tags
    dynamic "route" {
      for_each = each.value.route == null ? [] : each.value.route
      content {
        address_prefix         = route.value.address_prefix
        name                   = route.value.name
        next_hop_in_ip_address = route.value.next_hop_in_ip_address
        next_hop_type          = route.value.next_hop_type
      }
    }
  }
  
  