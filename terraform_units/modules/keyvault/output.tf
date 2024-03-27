output "user_assigned_identity_deployer" {
  value = azurerm_user_assigned_identity.deployer
}
output "key_vault_id" {
  value = module.avm_res_keyvault_vault.resource.id
  
}
