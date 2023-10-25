@description('Name of the Network Security Group')
param networkSecurityGroupName string = 'SecGroupNet'

@description('Location')
param location string = resourceGroup().location

@description('Tags to be added to the resources')
param tags object ={}

resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2023-04-01' = {
  name: networkSecurityGroupName
  location: location
  tags: tags
  properties: {
  }
}

output nsgId string = networkSecurityGroup.id
