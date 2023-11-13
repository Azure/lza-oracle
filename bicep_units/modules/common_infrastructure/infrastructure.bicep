metadata name = 'Common infrastructure'
metadata description = 'This module provisions a Resource Group'
metadata owner = 'Azure/module-maintainers'

targetScope='subscription'
@description('Name of the Resource Group')
param resourceGroupName string = 'oraGroup'

@description('Location')
param location string = 'westeurope'

@description('Tags to be added to the resources')
param tags object ={}

resource resourceGroup 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: resourceGroupName
  location: location
  tags: tags
}

output resourceGroupName string = resourceGroup.name
