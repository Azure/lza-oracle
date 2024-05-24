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
  features {}
}
 
# This ensures we have unique CAF compliant names for our resources.
module "naming" {
  source  = "Azure/naming/azurerm"
  version = "0.3.0"
}

# Create a route table
resource "azurerm_route_table" "odaasubnet_routetable" {
  for_each = var.odaa_routetables
  name = each.value.name
  resource_group_name = var.resource_group_name
  location = var.location
}

# Add routes to the route table, based on requirements
resource "azurerm_route" "odaasubnet_routes" {  
  depends_on = [ azurerm_route_table.odaasubnet_routetable ]
  for_each = var.odaa_routes
  name = each.value.route_name
  next_hop_type = each.value.next_hop_type
  next_hop_in_ip_address = each.value.next_hop_in_ip_address
  address_prefix = each.value.address_prefix
  route_table_name = each.value.route_table_name
  resource_group_name = var.resource_group_name
}

# Deploy the ODAA vnet and subnet along with required values
module "odaa_vnet" {
  source  = "Azure/avm-res-network-virtualnetwork/azurerm"
  version = "0.1.4"
  name = var.odaa_vnet.name
  location = var.location
  virtual_network_address_space = var.odaa_vnet.address_space
  subnets = {for idx, item in var.odaa_subnets:
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
      route_table = azurerm_route_table.odaasubnet_routetable != null ? {
        id = azurerm_route_table.odaasubnet_routetable["route-table"].id
      } : {}
    }
  }

  resource_group_name = var.resource_group_name
  vnet_peering_config = var.odaa_vnet.peerings
}