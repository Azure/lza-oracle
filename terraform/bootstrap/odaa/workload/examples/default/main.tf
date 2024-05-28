resource "azurerm_resource_group" "this" {
  location = local.region
  name     = "rg-odaa-terraform"
  tags     = local.tags
}

module "ptn-oracle" {
  source = "../../"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  virtual_network = {
    address_space = ["10.0.0.0/16"]
    name          = "vnet-odaa-terraform"
    subnet = [{
        address_prefix = "10.0.0.0/24"
        name           = "subnet1" 
    }]
  }
  route_table = {
    name = "route-table-odaa-terraform"
    route = [{
      address_prefix = "10.0.0.0/24"
      name           = "route1"
      next_hop_in_ip_address = "10.100.0.0"
      next_hop_type = "VirtualAppliance"
    }]
  }
}