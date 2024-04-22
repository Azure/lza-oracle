###############################################################################
#                                                                             #
#                             Resource Group                                  #
#                                                                             #
###############################################################################
output "resource_group" {
  value = module.common_infrastructure.resource_group
}

###############################################################################
#                                                                             #
#                            Network                                          #
#                                                                             #
###############################################################################
# output "network_location" {
#   value = module.network.network_location
# }

# output "db_subnet" {
#   value = module.network.db_subnet
# }


###############################################################################
#                                                                             #
#                            Storage                                          #
#                                                                             #
###############################################################################
# output "database_data_disks" {
#   value = module.storage.data_disks
# }

# output "database_asm_disks" {
#   value = module.storage.asm_disks
# }

# output "database_redo_disks" {
#   value = module.storage.redo_disks
# }

###############################################################################
#                                                                             #
#                    Virtual Machine                                          #
#                                                                             #
###############################################################################


output "vm_map_collection" {
  value = module.vm.vm_map_collection
}

output "vm_public_ip_address" {
  value = module.vm.vm.public_ip_address
}


###############################################################################
#                    J I T    Rules                                           #
###############################################################################

output "si_jit_ssh_policy" {
  value = jsondecode(azapi_resource.jit_ssh_policy[0].output)
}

