targetScope='subscription'
@description('Name of the Resource Group')
param resourceGroupName string = 'oraGroup'

@description('Location')
param location string = 'westeurope'

resource resourceGroup 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: resourceGroupName
  location: location
}

