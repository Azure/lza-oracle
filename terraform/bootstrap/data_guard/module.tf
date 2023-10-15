module "common_infrastructure" {
  source = "../../../terraform_units/modules/common_infrastructure"

  infrastructure                 = local.infrastructure
  is_data_guard                  = true
  is_diagnostic_settings_enabled = var.is_diagnostic_settings_enabled
  diagnostic_target              = var.diagnostic_target
  tags                           = var.resourcegroup_tags
}

module "vm_primary" {
  source = "../../../terraform_units/modules/compute"

  subscription_id           = module.common_infrastructure.current_subscription.subscription_id
  resource_group            = module.common_infrastructure.resource_group
  vm_name                   = "vm-primary"
  public_key                = var.ssh_key
  sid_username              = "oracle"
  nic_id                    = module.network.nics_oracledb_primary.id
  vm_sku                    = var.vm_sku
  vm_source_image_reference = var.vm_source_image_reference

  vm_os_disk = {
    name                   = "osdisk-primary"
    caching                = "ReadWrite"
    storage_account_type   = "Premium_LRS"
    disk_encryption_set_id = null
    disk_size_gb           = 128
  }

  aad_system_assigned_identity    = false
  assign_subscription_permissions = true

  is_diagnostic_settings_enabled = module.common_infrastructure.is_diagnostic_settings_enabled
  diagnostic_target              = module.common_infrastructure.diagnostic_target
  storage_account_id             = module.common_infrastructure.target_storage_account_id
  storage_account_sas_token      = module.common_infrastructure.target_storage_account_sas
  log_analytics_workspace_id     = module.common_infrastructure.log_analytics_workspace_id
  eventhub_authorization_rule_id = module.common_infrastructure.eventhub_authorization_rule_id
  partner_solution_id            = module.common_infrastructure.partner_solution_id
  tags                           = module.common_infrastructure.tags

  availability_zone = 1

  role_assignments = {
    role_assignment_1 = {
      name                             = "Virtual Machine Contributor"
      skip_service_principal_aad_check = false
    }
  }
}

module "vm_secondary" {
  source = "../../../terraform_units/modules/compute"

  subscription_id           = module.common_infrastructure.current_subscription.subscription_id
  resource_group            = module.common_infrastructure.resource_group
  vm_name                   = "vm-secondary"
  public_key                = var.ssh_key
  sid_username              = "oracle"
  nic_id                    = module.network.nics_oracledb_secondary.id
  vm_sku                    = var.vm_sku
  vm_source_image_reference = var.vm_source_image_reference

  vm_os_disk = {
    name                   = "osdisk-secondary"
    caching                = "ReadWrite"
    storage_account_type   = "Premium_LRS"
    disk_encryption_set_id = null
    disk_size_gb           = 128
  }

  aad_system_assigned_identity    = false
  assign_subscription_permissions = true

  is_diagnostic_settings_enabled = module.common_infrastructure.is_diagnostic_settings_enabled
  diagnostic_target              = module.common_infrastructure.diagnostic_target
  storage_account_id             = module.common_infrastructure.target_storage_account_id
  storage_account_sas_token      = module.common_infrastructure.target_storage_account_sas
  log_analytics_workspace_id     = module.common_infrastructure.log_analytics_workspace_id
  eventhub_authorization_rule_id = module.common_infrastructure.eventhub_authorization_rule_id
  partner_solution_id            = module.common_infrastructure.partner_solution_id
  tags                           = module.common_infrastructure.tags

  availability_zone = 2

  role_assignments = {
    role_assignment_1 = {
      name                             = "Virtual Machine Contributor"
      skip_service_principal_aad_check = false
    }
  }
}

module "vm_observer" {
  source = "../../../terraform_units/modules/compute"

  subscription_id           = module.common_infrastructure.current_subscription.subscription_id
  resource_group            = module.common_infrastructure.resource_group
  vm_name                   = "vm-observer"
  public_key                = var.ssh_key
  sid_username              = "oracle"
  nic_id                    = module.network.nics_oracledb_observer.id
  vm_sku                    = var.vm_sku
  vm_source_image_reference = var.vm_source_image_reference

  vm_os_disk = {
    name                   = "osdisk-observer"
    caching                = "ReadWrite"
    storage_account_type   = "Premium_LRS"
    disk_encryption_set_id = null
    disk_size_gb           = 128
  }

  aad_system_assigned_identity    = false
  assign_subscription_permissions = true

  is_diagnostic_settings_enabled = module.common_infrastructure.is_diagnostic_settings_enabled
  diagnostic_target              = module.common_infrastructure.diagnostic_target
  storage_account_id             = module.common_infrastructure.target_storage_account_id
  storage_account_sas_token      = module.common_infrastructure.target_storage_account_sas
  log_analytics_workspace_id     = module.common_infrastructure.log_analytics_workspace_id
  eventhub_authorization_rule_id = module.common_infrastructure.eventhub_authorization_rule_id
  partner_solution_id            = module.common_infrastructure.partner_solution_id
  tags                           = module.common_infrastructure.tags

  availability_zone = 3

  role_assignments = {
    role_assignment_1 = {
      name                             = "Virtual Machine Contributor"
      skip_service_principal_aad_check = false
    }
  }
}

module "network" {
  source = "../../../terraform_units/modules/network"

  resource_group                 = module.common_infrastructure.resource_group
  is_data_guard                  = module.common_infrastructure.is_data_guard
  is_diagnostic_settings_enabled = module.common_infrastructure.is_diagnostic_settings_enabled
  diagnostic_target              = module.common_infrastructure.diagnostic_target
  storage_account_id             = module.common_infrastructure.target_storage_account_id
  log_analytics_workspace_id     = module.common_infrastructure.log_analytics_workspace_id
  eventhub_authorization_rule_id = module.common_infrastructure.eventhub_authorization_rule_id
  partner_solution_id            = module.common_infrastructure.partner_solution_id
  tags                           = module.common_infrastructure.tags

  role_assignments_nic = {
    role_assignment_1 = {
      name                             = "Contributor"
      skip_service_principal_aad_check = false
    }
  }

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

module "storage_primary" {
  source = "../../../terraform_units/modules/storage"

  resource_group = module.common_infrastructure.resource_group
  is_data_guard  = module.common_infrastructure.is_data_guard
  naming         = "oracle-primary"
  vm             = module.vm_primary.vm[0]
  tags           = module.common_infrastructure.tags
  database_disks_options = {
    data_disks = var.database_disks_options.data_disks
    asm_disks  = var.database_disks_options.asm_disks
    redo_disks = var.database_disks_options.redo_disks
  }
  availability_zone = 1

  role_assignments = {
    role_assignment_1 = {
      name                             = "Contributor"
      skip_service_principal_aad_check = false
    }
  }
}

module "storage_secondary" {
  source = "../../../terraform_units/modules/storage"

  resource_group = module.common_infrastructure.resource_group
  is_data_guard  = module.common_infrastructure.is_data_guard
  naming         = "oracle-secondary"
  vm             = module.vm_secondary.vm[0]
  tags           = module.common_infrastructure.tags
  database_disks_options = {
    data_disks = var.database_disks_options.data_disks
    asm_disks  = var.database_disks_options.asm_disks
    redo_disks = var.database_disks_options.redo_disks
  }
  availability_zone = 2

  role_assignments = {
    role_assignment_1 = {
      name                             = "Contributor"
      skip_service_principal_aad_check = false
    }
  }
}

module "storage_observer" {
  source = "../../../terraform_units/modules/storage"

  resource_group = module.common_infrastructure.resource_group
  is_data_guard  = module.common_infrastructure.is_data_guard
  naming         = "oracle-observer"
  vm             = module.vm_observer.vm[0]
  tags           = module.common_infrastructure.tags
  database_disks_options = {
    data_disks = var.database_disks_options.data_disks
    asm_disks  = var.database_disks_options.asm_disks
    redo_disks = var.database_disks_options.redo_disks
  }
  availability_zone = 3

  role_assignments = {
    role_assignment_1 = {
      name                             = "Contributor"
      skip_service_principal_aad_check = false
    }
  }
}

#########################################################################################
#                                                                                       #
#  JIT Access Policy                                                                    #
#                                                                                       #
#########################################################################################
resource "azapi_resource" "jit_ssh_policy_primary" {
  count                     = module.vm_primary.database_server_count
  name                      = "JIT-SSH-Policy-primary"
  parent_id                 = "${module.common_infrastructure.resource_group.id}/providers/Microsoft.Security/locations/${module.common_infrastructure.resource_group.location}"
  type                      = "Microsoft.Security/locations/jitNetworkAccessPolicies@2020-01-01"
  schema_validation_enabled = false
  body = jsonencode({
    "kind" : "Basic"
    "properties" : {
      "virtualMachines" : [{
        "id" : "/subscriptions/${module.common_infrastructure.current_subscription.subscription_id}/resourceGroups/${module.common_infrastructure.resource_group.name}/providers/Microsoft.Compute/virtualMachines/${module.vm_primary.vm[0].name}",
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

  depends_on = [module.vm_primary]
}

resource "azapi_resource" "jit_ssh_policy_secondary" {
  count                     = module.vm_secondary.database_server_count
  name                      = "JIT-SSH-Policy-secondary"
  parent_id                 = "${module.common_infrastructure.resource_group.id}/providers/Microsoft.Security/locations/${module.common_infrastructure.resource_group.location}"
  type                      = "Microsoft.Security/locations/jitNetworkAccessPolicies@2020-01-01"
  schema_validation_enabled = false
  body = jsonencode({
    "kind" : "Basic"
    "properties" : {
      "virtualMachines" : [{
        "id" : "/subscriptions/${module.common_infrastructure.current_subscription.subscription_id}/resourceGroups/${module.common_infrastructure.resource_group.name}/providers/Microsoft.Compute/virtualMachines/${module.vm_secondary.vm[0].name}",
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

  depends_on = [module.vm_secondary]
}

resource "azapi_resource" "jit_ssh_policy_observer" {
  count                     = module.vm_observer.database_server_count
  name                      = "JIT-SSH-Policy-observer"
  parent_id                 = "${module.common_infrastructure.resource_group.id}/providers/Microsoft.Security/locations/${module.common_infrastructure.resource_group.location}"
  type                      = "Microsoft.Security/locations/jitNetworkAccessPolicies@2020-01-01"
  schema_validation_enabled = false
  body = jsonencode({
    "kind" : "Basic"
    "properties" : {
      "virtualMachines" : [{
        "id" : "/subscriptions/${module.common_infrastructure.current_subscription.subscription_id}/resourceGroups/${module.common_infrastructure.resource_group.name}/providers/Microsoft.Compute/virtualMachines/${module.vm_observer.vm[0].name}",
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

  depends_on = [module.vm_observer]
}
