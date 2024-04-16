data "azurerm_client_config" "current" {}

module "common_infrastructure" {
  source = "../../../terraform_units/modules/common_infrastructure"

  infrastructure                 = local.infrastructure
  is_diagnostic_settings_enabled = var.is_diagnostic_settings_enabled
  diagnostic_target              = var.diagnostic_target
  availability_zone              = 1
  tags                           = var.resourcegroup_tags
}




#New module for network
module "network" {
  source = "../../../terraform_units/modules/network"

  resource_group                 = module.common_infrastructure.resource_group
  is_data_guard                  = module.common_infrastructure.is_data_guard
  is_diagnostic_settings_enabled = module.common_infrastructure.is_diagnostic_settings_enabled
  diagnostic_target              = module.common_infrastructure.diagnostic_target
  storage_account_id             = module.common_infrastructure.target_storage_account_id
  log_analytics_workspace_id     = try(module.common_infrastructure.log_analytics_workspace.id, "")
  eventhub_authorization_rule_id = module.common_infrastructure.eventhub_authorization_rule_id
  partner_solution_id            = module.common_infrastructure.partner_solution_id
  tags                           = module.common_infrastructure.tags

  #ToDo:
  # role_assignments_nic = {
  #   role_assignment_1 = {
  #     name                             = "Contributor"
  #     skip_service_principal_aad_check = false
  #   }
  # }

  role_assignments_pip = {
    role_assignment_1 = {
      name                             = "Contributor"
      skip_service_principal_aad_check = false
    }
  }

  role_assignments_nsg = {
    role_assignment_1 = {
      name                             = "Contributor"
      skip_service_principal_aad_check = false
    }
  }

  role_assignments_vnet = {
    role_assignment_1 = {
      name                             = "Contributor"
      skip_service_principal_aad_check = false
    }
  }

  role_assignments_subnet = {
    role_assignment_1 = {
      name                             = "Contributor"
      skip_service_principal_aad_check = false
    }
  }
}

#New module for Compute, this is the new module that will be used to create the VM, using AVM
module "vm" {
  source = "../../../terraform_units/modules/compute"

  resource_group_name             = module.common_infrastructure.created_resource_group_name
  location                        = var.location
  vm_name                         = "vm-0"
  public_key                      = var.ssh_key
  sid_username                    = "oracle"
  vm_sku                          = var.vm_sku
  vm_source_image_reference       = var.vm_source_image_reference
  vm_user_assigned_identity_id    = var.vm_user_assigned_identity_id
  aad_system_assigned_identity    = true
  public_ip_address_resource_id   = module.network.db_server_puplic_ip_resources[0].id
  vm_os_disk                      = var.vm_os_disk

  is_diagnostic_settings_enabled = module.common_infrastructure.is_diagnostic_settings_enabled
  diagnostic_target              = module.common_infrastructure.diagnostic_target
  storage_account_id             = module.common_infrastructure.target_storage_account_id
  storage_account_sas_token      = module.common_infrastructure.target_storage_account_sas
  log_analytics_workspace     = module.common_infrastructure.log_analytics_workspace!=null ? {
    id = module.common_infrastructure.log_analytics_workspace.id
    name = module.common_infrastructure.log_analytics_workspace.name
  }: null
  data_collection_rules = module.common_infrastructure.data_collection_rules
  partner_solution_id            = module.common_infrastructure.partner_solution_id
  tags                           = module.common_infrastructure.tags
  vm_lock = var.lock
  db_subnet                      = module.network.db_subnet
  availability_zone              = module.common_infrastructure.availability_zone

  role_assignments = {
    role_assignment_1 = {
      role_definition_id_or_name       = "Virtual Machine Contributor"
      principal_id                     = data.azurerm_client_config.current.object_id
      skip_service_principal_aad_check = false
    }
  }

  role_assignments_nic = {
    role_assignment_1 = {
      role_definition_id_or_name       = "Contributor"
      principal_id                     = data.azurerm_client_config.current.object_id
      skip_service_principal_aad_check = false
    }
  }

  vm_extensions = {
    azure_monitor_agent = {
      name                       = "vm-0-azure-monitor-agent"
      publisher                  = "Microsoft.Azure.Monitor"
      type                       = "AzureMonitorLinuxAgent"
      type_handler_version       = "1.1"
      auto_upgrade_minor_version = true
      automatic_upgrade_enabled  = true
      settings                   = null
    },
    dependency_agent = {
      name                       = "vm-0-dependency-agent"
      publisher                  = "Microsoft.Azure.Monitoring.DependencyAgent"
      type                       = "DependencyAgentLinux"
      type_handler_version       = "9.10"
      auto_upgrade_minor_version = true
      automatic_upgrade_enabled  = true
      settings = jsonencode({
        enableAMA = "true"
      })
    }
  }

  depends_on = [module.network, module.common_infrastructure]
}

#########################################################################################


module "storage" {
  source = "../../../terraform_units/modules/storage"

  resource_group = module.common_infrastructure.resource_group
  naming         = "oracle"
  vm             = module.vm.vm
  tags           = module.common_infrastructure.tags
  database_disks_options = {
    data_disks = var.database_disks_options.data_disks
    asm_disks  = var.database_disks_options.asm_disks
    redo_disks = var.database_disks_options.redo_disks
  }
  availability_zone = module.common_infrastructure.availability_zone

  role_assignments = {
    role_assignment_1 = {
      name                             = "Contributor"
      skip_service_principal_aad_check = false
    }
  }
}

