metadata name = 'subnet'
metadata description = 'This module provisions subnets for a vnet'
metadata owner = 'Azure/module-maintainers'

@description('Name of the VNET')
param virtualNetworkName string = 'vNet'

@description('Name of the subnet in the virtual network')
param subnetName string = 'Subnet'

@description('Subnet Address prefix')
param subnetAddressPrefix string = '10.0.0.0/24'

@description('Network security group')
param networkSecurityGroupId string 

// AVM req - a Prefix is required
param vnetResourcePrefix string = 'vnet'

// AVM req - a Prefix is required
param subnetResourcePrefix string = 'snet'

// AVM optional settings

resource existingVirtualNetwork 'Microsoft.Network/virtualNetworks@2023-04-01' existing = {
  name: '${vnetResourcePrefix}-${virtualNetworkName}'
}

// TODO: idempotency check
resource subnet 'Microsoft.Network/virtualNetworks/subnets@2023-04-01' = {
  parent: existingVirtualNetwork
  name: '${subnetResourcePrefix}-${subnetName}'
  properties: {
    addressPrefix: subnetAddressPrefix
    networkSecurityGroup: {id: networkSecurityGroupId}
  }
}

output subnetId string = subnet.id 
