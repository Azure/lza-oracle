metadata name = 'nsg'
metadata description = 'This module provisions a Blank network security group'
metadata owner = 'Azure/module-maintainers'

@description('Name of the Network Security Group')
param networkSecurityGroupName string = 'SecGroupNet'

@description('Location')
param location string = resourceGroup().location

// AVM req - a Prefix is required
param nsgGroupPrefix string = 'nsg'

// AVM optional settings

@description('Tags to be added to the resources')
param tags object ={}

resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2023-04-01' = {
  name: '${nsgGroupPrefix}-${networkSecurityGroupName}'
  location: location
  tags: tags
  properties: {
  }
}

output resourceId string = networkSecurityGroup.id
