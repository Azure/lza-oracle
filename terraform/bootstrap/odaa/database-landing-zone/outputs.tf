output "virtual_network" {
  value = module.odaa_vnet
}

output "route_tables" {
  value = { for instance in azurerm_route_table.rt_odaa : instance.id => {
    instance.id : instance
  }}
}