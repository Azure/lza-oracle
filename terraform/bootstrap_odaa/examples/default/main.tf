terraform {
  required_version = ">= 1.3.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.7.0, < 4.0.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.5.0, < 4.0.0"
    }
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}


## Section to provide a random Azure region for the resource group
# This allows us to randomize the region for the resource group.
module "regions" {
  source  = "Azure/regions/azurerm"
  version = ">= 0.3.0"
}

# This allows us to randomize the region for the resource group.
resource "random_integer" "region_index" {
  max = length(module.regions.regions) - 1
  min = 0
}
## End of section to provide a random Azure region for the resource group

# This ensures we have unique CAF compliant names for our resources.
module "naming" {
  source  = "Azure/naming/azurerm"
  version = ">= 0.3.0"
}

locals {
  routes = {
    route1 = {
      name = "routeInternet"
      next_hop_type = "VirtualAppliance"
      next_hop_in_ip_address = "10.0.0.4"
      address_prefix = "10.0.0.0/24"
    }
  }
}
locals {
  peerings = {
    peeringToHub = {
      remote_vnet_id = module.hub_vnet.virtual_network_id
      allow_forwarded_traffic = true
      allow_gateway_transit = true
      use_remote_gateways = false
    }
  }
}
locals {
  subnets = {
    snet-odaa = {
      address_prefixes = ["10.1.0.0/24"]
      delegations = [
        {
          name = "snet-odaa"
          service_delegation = {
            name = "Oracle.Database/networkAttachments"
            actions = [
              "Microsoft.Network/networkinterfaces/*",
              "Microsoft.Network/virtualNetworks/subnets/join/action"
            ]
          }  
        }
      ]
      route_table = {
        id = azurerm_route_table.odaasubnet_routetable.id
      }
    }
  }
}

# This is required for resource modules
resource "azurerm_resource_group" "rg" {
  location = module.regions.regions[random_integer.region_index.result].name
  name     = module.naming.resource_group.name_unique
}

module "hub_vnet" {
  source  = "Azure/avm-res-network-virtualnetwork/azurerm"
  version = "0.1.4"
  name = "vnet-hub"
  location = azurerm_resource_group.rg.location
  virtual_network_address_space = ["10.0.0.0/16"]
  subnets = {
    snet-default = {
      address_prefixes = ["10.0.0.0/24"]
    }
  }
  resource_group_name =  azurerm_resource_group.rg.name
}

resource "azurerm_route_table" "odaasubnet_routetable" {
  name = "rt-odaaroutetable"
  resource_group_name = azurerm_resource_group.rg.name
  location = azurerm_resource_group.rg.location
}

resource "azurerm_route" "odaasubnet_routes" {  
  for_each = local.routes
  name = each.value.name
  next_hop_type = each.value.next_hop_type
  next_hop_in_ip_address = each.value.next_hop_in_ip_address
  address_prefix = each.value.address_prefix
  route_table_name = azurerm_route_table.odaasubnet_routetable.name
  resource_group_name = azurerm_resource_group.rg.name
}

module "odaa_deployment"  {
  source = "../../single_instance"
  resource_group_id = azurerm_resource_group.rg.id
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  odaa_vnet = {
    name = "vnet-odaavnet"
    subnets = local.subnets
    address_space = ["10.1.0.0/16"]
    peerings = local.peerings
  } 
}