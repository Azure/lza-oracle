@description('Name of the VNET')
param virtualNetworkName string = 'vNet'

@description('Location')
param location string = resourceGroup().location

@description('VNET Address prefix')
param vnetAddressPrefix string = '10.0.0.0/16'

@description('Tags to be added to the resources')
param tags object ={}

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2023-04-01' = {
  name: virtualNetworkName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
  }
  tags: tags
}

output virtualNetworkId string = virtualNetwork.id
