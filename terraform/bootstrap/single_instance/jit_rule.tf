#########################################################################################
#                                                                                       #
#  JIT Access Policy                                                                    #
#                                                                                       #
#########################################################################################
data "azurerm_virtual_machine" "oracle_vm" {
  name                = module.vm.vm.name
  resource_group_name = module.common_infrastructure.resource_group.name

  depends_on = [module.vm, module.storage
  ]
}

resource "time_sleep" "wait_for_vm_creation" {
  create_duration = var.jit_wait_for_vm_creation

  depends_on = [data.azurerm_virtual_machine.oracle_vm,
    module.storage
  ]
}

resource "azapi_resource" "jit_ssh_policy" {
  count                     = module.vm.database_server_count
  provider = azapi
  name                      = "JIT-SSH-Policy"
  parent_id                 = "${module.common_infrastructure.resource_group.id}/providers/Microsoft.Security/locations/${module.common_infrastructure.resource_group.location}"
  type                      = "Microsoft.Security/locations/jitNetworkAccessPolicies@2020-01-01"
  schema_validation_enabled = false
  body = jsonencode({
    "kind" : "Basic"
    "properties" : {
      "virtualMachines" : [{
        "id" : "/subscriptions/${module.common_infrastructure.current_subscription.subscription_id}/resourceGroups/${module.common_infrastructure.resource_group.name}/providers/Microsoft.Compute/virtualMachines/${data.azurerm_virtual_machine.oracle_vm.name}",
        "ports" : [
          {
            "number" : 22,
            "protocol" : "TCP",
            "allowedSourceAddressPrefix" : "*",
            "maxRequestAccessDuration" : "PT3H"
          }
        ]
      }]
    }
  })

  depends_on = [
    time_sleep.wait_for_vm_creation
  ]
}
