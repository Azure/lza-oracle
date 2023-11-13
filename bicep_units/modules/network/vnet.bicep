metadata name = 'vnet'
metadata description = 'This module provisions a virtual network for hosting Oracle VMs'
metadata owner = 'Azure/module-maintainers'

@description('Name of the VNET')
param virtualNetworkName string = 'vNet'

@description('Location')
param location string = resourceGroup().location

@description('VNET Address prefix')
param vnetAddressPrefix array

@description('Subnets ')
param vnetSubnets array 

// AVM req - a Prefix is required
param vnetResourcePrefix string = 'vnet'

// AVM req - a Prefix is required
param subnetResourcePrefix string = 'snet'

@description('Tags to be added to the resources')
param tags object ={}

var subnets = filter(vnetSubnets, x => x.virtualNetworkName == virtualNetworkName)

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2023-04-01' = {
  name: '${vnetResourcePrefix}-${virtualNetworkName}'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: vnetAddressPrefix
    }
    subnets: [ for subnet in subnets: {
        name: '${subnetResourcePrefix}-${subnet.subnetName}'
        properties: {
          addressPrefix: subnet.addressPrefix
        }
      }
    ]
  }
  tags: tags
}

output virtualNetworkId string = virtualNetwork.id
