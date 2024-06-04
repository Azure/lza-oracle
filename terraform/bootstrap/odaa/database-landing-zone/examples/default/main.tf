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
  deploy_odaa_infra = var.deploy_odaa_infra
  deploy_odaa_cluster = var.deploy_odaa_cluster
}

data "azapi_resource" "dbServer" {
  count = var.deploy_odaa_infra ? 1 : 0
  type = "Oracle.Database/cloudExadataInfrastructures@2023-09-01-preview"
  parent_id = azurerm_resource_group.this.id
  name = var.odaa_infra_name
}