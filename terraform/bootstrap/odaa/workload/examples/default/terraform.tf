terraform {
  required_version = "~> 1.7"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.74"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
    azapi = {
      source = "azure/azapi"
      version = "~> 1.13.1"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "azapi" {
}