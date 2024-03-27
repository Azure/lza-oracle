module "naming" {
  source  = "Azure/naming/azurerm"
  version = ">= 0.3.0"
}

module "avm_res_keyvault_vault" {
  source                      = "Azure/avm-res-keyvault-vault/azurerm"
  version                     = ">= 0.5.0"
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  name                        = module.naming.key_vault.name_unique
  resource_group_name         = var.resource_group.name
  location                    = var.resource_group.location
  enabled_for_disk_encryption = true

  network_acls = {
    default_action = "Allow"
    bypass         = "AzureServices"
  }

  role_assignments = {
    deployment_user_secrets = { #give the deployment user access to secrets
      role_definition_id_or_name = "Key Vault Secrets Officer"
      principal_id               = data.azurerm_client_config.current.object_id
    }
    deployment_user_keys = { #give the deployment user access to keys
      role_definition_id_or_name = "Key Vault Crypto Officer"
      principal_id               = data.azurerm_client_config.current.object_id
    }

    #Give the user assigned managed identity of the VM access to keys
    user_managed_identity_keys = {
      role_definition_id_or_name = "Key Vault Crypto Officer"
      principal_id               = azurerm_user_assigned_identity.deployer.principal_id
    }
  }

  wait_for_rbac_before_key_operations = {
    create = "60s"
  }

  wait_for_rbac_before_secret_operations = {
    create = "60s"
  }

  tags = local.tags

#   keys = {
#     des_key = {
#       name     = "des-disk-key"
#       key_type = "RSA"
#       key_size = 2048

#       key_opts = [
#         "decrypt",
#         "encrypt",
#         "sign",
#         "unwrapKey",
#         "verify",
#         "wrapKey",
#       ]
#     }
#   }
}

# resource "tls_private_key" "this" {
#   algorithm = "RSA"
#   rsa_bits  = 4096
# }

# resource "azurerm_key_vault_secret" "admin_ssh_key" {
#   key_vault_id = module.avm_res_keyvault_vault.resource.id
#   name         = "azureuser-ssh-private-key"
#   value        = tls_private_key.this.private_key_pem
#   depends_on = [
#     module.avm_res_keyvault_vault
#   ]
# }
