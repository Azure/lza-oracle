@description('Name of the network interface')
param networkInterfaceName string 

@description('ID of the subnet')
param subnetId string

@description('ID of the public IP')
param pipId string

@description('ID of the Network security group')
param nsgId string

@description('Location')
param location string = resourceGroup().location

@description('Tags to be added to the resources')
param tags object ={}

resource networkInterface 'Microsoft.Network/networkInterfaces@2023-04-01' = {
  name: networkInterfaceName
  location: location
  tags: tags
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: subnetId
          }
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: pipId
          }
        }
      }
    ]
    networkSecurityGroup: {
      id: nsgId
    }
  }
}
output nicId string = networkInterface.id
