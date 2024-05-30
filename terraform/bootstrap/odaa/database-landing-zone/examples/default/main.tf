resource "azurerm_resource_group" "this" {
  location = local.region
  name     = "rg-odaa-terraform"
  tags     = local.tags
}

module "odaa_lz" {
  source = "../../"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  resource_group_id = azurerm_resource_group.this.id
  deploy_odaa_infra = false
  deploy_odaa_cluster = false
}