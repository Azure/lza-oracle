# Deploy the ODAA vnet and subnet along with required values
# TODO: Add ddos_protection_plan, encryption
module "odaa_vnet" {
  source  = "Azure/avm-res-network-virtualnetwork/azurerm"
  version = "0.1.4"
  name = var.virtual_network.name
  location = var.location
  virtual_network_address_space = var.virtual_network.address_space
  tags = var.tags  
  subnets = {for idx, item in var.virtual_network.subnet:
    "${item.name}" => {
      address_prefixes = item.address_prefixes
      delegations = item.delegate_to_oracle ? [
        {
          name = item.name
          service_delegation = {
            name = "Oracle.Database/networkAttachments"
            actions = [
              "Microsoft.Network/networkinterfaces/*",
              "Microsoft.Network/virtualNetworks/subnets/join/action"
            ]
          }  
        }
      ]: []
    }
  }
  resource_group_name = var.resource_group_name
  vnet_peering_config = var.virtual_network.peerings
}

data "azurerm_virtual_network" "odaa_vnet" {
  name                = var.virtual_network.name
  resource_group_name = var.resource_group_name

  depends_on = [module.odaa_vnet]
}

data "azurerm_subnet" "odaa_subnet" {
  name                 = tolist(var.virtual_network.subnet)[0].name
  virtual_network_name = data.azurerm_virtual_network.odaa_vnet.name
  resource_group_name  = var.resource_group_name

  depends_on = [module.odaa_vnet]
}