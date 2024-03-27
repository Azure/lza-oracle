resource "azurerm_availability_set" "oracle_vm" {
  count               = var.availability_zone == null ? 1 : 0
  name                = "as-${count.index}"
  location            = var.location
  resource_group_name = var.created_resource_group_name
}

data "azurerm_availability_set" "oracle_vm" {
  count               = var.availability_zone == null ? 1 : 0
  name                = "as-${count.index}"
  resource_group_name = var.created_resource_group_name

  depends_on = [azurerm_availability_set.oracle_vm]
}
