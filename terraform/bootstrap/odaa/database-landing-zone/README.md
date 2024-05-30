# WORK IN PROGRESS - DO NOT USE IN PRODUCTION WORKLOADS

# Oracle Database at Azure

This repo creates the necessary Azure infrastructure for deploying Oracle appliances. It creates a virtual network, subnets for delegating to Oracle database service, route tables(if required), vnet peerings (if required) and ExaData infrastructure/cluster if(if required).  


## Prerequisites

1. Azure Active Directory Tenant.
2. Minimum 1 subscription, for when deploying VMs. If you don't have an Azure subscription, create a [free account](https://azure.microsoft.com/en-us/free/?ref=microsoft.com&utm_source=microsoft.com&utm_medium=docs&utm_campaign=visualstudio) before you begin.
3. An Oracle subscription for provisioning ODAA clusters

## Authenticate Terraform to Azure

To use Terraform commands against your Azure subscription, you must first authenticate Terraform to that subscription. [This doc](https://learn.microsoft.com/en-us/azure/developer/terraform/authenticate-to-azure?tabs=bash) describes how to authenticate Terraform to your Azure subscription.

## Getting started

- Fork this repo to your own GitHub organization, you should not create a direct clone of the repo. Pull requests based off direct clones of the repo will not be allowed.
- Clone the repo from your own GitHub organization to your developer workstation.
- Review your current configuration to determine what scenario applies to you. We have guidance that will help deploy Oracle VMs in your subscription.


## Usage Samples

### Default Example 
This test provisions a resource group, virtual network, two subnets (Client and Database), and delegates the Database subnet to the Oracle service.  It also creates a route table and associates with subnets.  In addition to this, the following are also created :

 - A spoke VNet 
 - Peerings between Hub and Database vnet

Usage:

- Change directory to bicep/bootstrap_odaa/single_instance/default

- Customize main.tf to set appropriate values for all parameters.

```
$ pwd
/path/to/this/repo/terraform/bootstrap_odaa/examples/default

$ terraform init

$ terraform plan 

$ terraform apply 
```
