output "virtual_network" {
  value = module.odaa_lz.virtual_network
}

output "route_tables" {
  value = module.odaa_lz.route_tables
}

output "odaa-infra" {
  value = module.odaa_lz.odaa-infra
}

output "odaa-cluster" {
  value = module.odaa_lz.odaa-cluster
}