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

module "odaa_vnet" {
  source  = "Azure/avm-res-network-virtualnetwork/azurerm"
  version = "0.1.4"
  name = var.odaa_vnet.name
  location = var.location
  virtual_network_address_space = var.odaa_vnet.address_space
  subnets = var.odaa_vnet.subnets
  resource_group_name = var.resource_group_name
}