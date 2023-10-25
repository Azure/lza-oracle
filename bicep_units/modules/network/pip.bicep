@description('Availability zone')
param avZone string = '1'

@description('Name of the Public IP')
param pipName string = 'pip1'

@description('Location for all resources.')
param location string = resourceGroup().location

@description('Tags to be added to the resources')
param tags object ={}

resource publicIPAddress 'Microsoft.Network/publicIPAddresses@2023-04-01' = {
  name: pipName
  location: location
  tags: tags
  sku: {
    name: 'Standard'
  }
  zones:[avZone]
  properties: {
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'
    idleTimeoutInMinutes: 4
  }
}

output pipId string = publicIPAddress.id
