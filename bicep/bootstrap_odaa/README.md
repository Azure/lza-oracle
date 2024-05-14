# Oracle Database at Azure

This repo creates the necessary Azure infrastructure for deploying Oracle appliances. It creates a virtual network, subnets for delegating to Oracle database service, route tables(if required), and vnet peerings (if required). Please refer the parameter file  in tests/e2etests for setting up various parameters


## Installation

To install the necessary dependencies and deploy the Bicep file using Azure CLI, follow these steps:

1. Clone the repository.
2. Install Azure CLI by following the instructions provided in the [Azure CLI documentation](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli).
3. Open a terminal or command prompt and navigate to the cloned repository directory.
4. Run the following command to log in to your Azure account:

    ```bash
    az login

## Usage Samples

### Example 
This test provisions a resource group, virtual network, two subnets (Client and Database), and delegates the Database subnet to the Oracle service.  It also creates a route table and associates with subnets.  In addition to this, the following are also created :
 - A Hub vnet, and peerings between Hub and Database vnet

Usage:

- Change directory to bicep/bootstrap_odaa/single_instance/default

- Login to your Azure account with az cli

- Use the following command, customize the parameters as necessary

``` bash 
 az deployment sub create --name demo --location centralindia --template-file dependencies.bicep
```

## Parameters

### Parameter: `resourceGroupName`

- Required : Yes
- Description: The module creates the resource group, if it does not exist in the current subscription.
- Type : string

### Parameter: `location`

- Required : Yes
- Description: The Azure region to which the resource group and all resoruces are to be deployed
- Type: string

### Parameter: `virtualNetworks`

- Required: Yes
- Description: An object array that contains the virtual network properties, including Address prefixes, subnets and their respective properties
- Type: Object array

### Parameter: `routeTables`

- Required: No
- Description: An object array that contains description of a route table and properties - including an array of routes.
- Type: Object array

### Parameter: `tags`

- Required: No
- Description: A list of tags that need to be associated with the created resources.
- Type: Object array

