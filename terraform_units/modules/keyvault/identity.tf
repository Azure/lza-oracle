// User defined identity for all Deployers, assign contributor to the current subscription
resource "azurerm_user_assigned_identity" "deployer" {
  resource_group_name = var.resource_group.name
  location            = var.resource_group.location
  name                = "deployer"
  tags                = local.tags
}