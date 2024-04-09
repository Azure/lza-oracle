#########################################################################################
#                                                                                       #
#  Virtual Machine                                                                      #
#                                                                                       #
#########################################################################################


module "avm-res-compute-virtualmachine" {
  source   = "Azure/avm-res-compute-virtualmachine/azurerm"
  version  = "0.8.0"
  for_each = local.vm_data_config


  name                   = each.value.name
  location               = var.location                    #var.resource_group.location
  resource_group_name    = var.created_resource_group_name #var.resource_group.name
  virtualmachine_os_type = each.value.os_type

  generate_admin_password_or_ssh_key = each.value.generate_admin_password_or_ssh_key #false
  disable_password_authentication    = !each.value.enable_auth_password              #!local.enable_auth_password
  admin_username                     = each.value.admin_username                     #var.sid_username
  admin_ssh_keys = each.value.admin_ssh_keys
  source_image_reference  = each.value.source_image_reference
  virtualmachine_sku_size = each.value.virtualmachine_sku_size
  os_disk = each.value.os_disk


  # network_interface_ids = [var.nic_id]

  #Todo lo que esta en el archivo network_avmwrapper/nic.tf se tiene que pasar aqui!!
  network_interfaces = {
    network_interface_1 = {
      name                          = "oraclevmnic-001"
      location                      = var.location
      resource_group_name           = var.created_resource_group_name
      enable_accelerated_networking = true
      tags                          = merge(local.tags, var.tags)

      ip_configurations = {
        ip_configuration_1 = {
          name                          = "ipconfig1"
          private_ip_subnet_resource_id = var.db_subnet.id
          create_public_ip_address      = true
          public_ip_address_name        = "vmpip-0" #ToDo: cambiar
          # public_ip_address_resource_id = var.db_server_public_ip_resource.id
        }
      }

      # name                          = "oraclevmnic-${count.index}"
      # location                      = var.resource_group.location
      # resource_group_name           = var.resource_group.name
      # enable_accelerated_networking = true
      # tags                          = merge(local.tags, var.tags)



      #ip_configurations = local.ip_configuration_list

      # ip_configurations = {
      #   ip_configuration_1 = {
      #     name
      # subnet_id
      # private_ip_address
      # private_ip_address_allocation
      # public_ip_address_id
      # primary






      # }
      # }

    }
  }


  #Simple private IP single NIC with IPV4 private address
  # # # network_interfaces = {
  # # #   network_interface_1 = {
  # # #     name = "testnic1"
  # # #     ip_configurations = {
  # # #       ip_configuration_1 = {
  # # #         name                          = "testnic1-ipconfig1"
  # # #         private_ip_subnet_resource_id = azurerm_subnet.this_subnet_1.id
  # # #       }
  # # #     }
  # # #   }
  # # # }




  zone = var.availability_zone #common_infrastructure.availability_zone = 1


  availability_set_resource_id = var.availability_zone == null ? data.azurerm_availability_set.oracle_vm[0].id : null
  tags                         = merge(local.tags, var.tags)


  vm_additional_capabilities = {
    ultra_ssd_enabled = local.enable_ultradisk
  }





  managed_identities = {
    system_assigned            = false             #var.aad_system_assigned_identity # Este para que es ??? de donde?
    user_assigned_resource_ids = [var.deployer.id] # [azurerm_user_assigned_identity.deployer[0].id]
  }

  role_assignments_system_managed_identity = {
    role_assignment_1 = {
      scope_resource_id          = var.key_vault_id #module.avm_res_keyvault_vault.resource.id
      role_definition_id_or_name = "Key Vault Secrets Officer"
      description                = "Assign the Key Vault Secrets Officer role to the virtual machine's system managed identity"
    }
  }

  role_assignments = {
    role_assignment_2 = {
      principal_id               = data.azurerm_client_config.current.client_id
      role_definition_id_or_name = "Virtual Machine Contributor"
      description                = "Assign the Virtual Machine Contributor role to the deployment user on this virtual machine resource scope."
    }
  }



  #admin_credential_key_vault_resource_id
  #     lifecycle {
  #     ignore_changes = [
  #       // Ignore changes to computername
  #       tags,
  #       computer_name
  #     ]
  #   }

  #depends_on = [ data.azurerm_resource_group.rg ]
}

data "azurerm_virtual_machine" "oracle_vm" {
  count               = 1
  name                = module.avm-res-compute-virtualmachine[0].virtual_machine.name
  resource_group_name = var.created_resource_group_name

  depends_on = [module.avm-res-compute-virtualmachine]
}



