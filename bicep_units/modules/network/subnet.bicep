metadata name = 'subnet'
metadata description = 'This module provisions subnets for a vnet and optionally associates a network security group.'
metadata owner = 'Azure/module-maintainers'

import * as avmtypes from '../common_infrastructure/common_types.bicep'

@description('Name of the VNET')
param virtualNetworkName string = 'vNet'

@description('Name of the subnet in the virtual network')
param subnetName string = 'Subnet'

@description('Subnet Address prefix')
param subnetAddressPrefix string = '10.0.0.0/24'

@description('Network security group')
param networkSecurityGroupName string? 

// AVM req - a Prefix is required
param vnetResourcePrefix string = avmtypes.vnetResourcePrefix

// AVM req - a Prefix is required
param subnetResourcePrefix string = 'snet'

// AVM optional settings

resource existingVirtualNetwork 'Microsoft.Network/virtualNetworks@2023-04-01' existing = {
  name: '${vnetResourcePrefix}-${virtualNetworkName}'
}

var networkSecurityGroupId = !empty(networkSecurityGroupName) ? resourceId(subscription().subscriptionId,resourceGroup().name,'Microsoft.Network/networkSecurityGroups', 'nsg-${networkSecurityGroupName}') : ''
 
// The subnet resource should also be defined in the Vnet resource definition
// Since Subnets are extension resources, other AVN resources such as locks, rbac are inherited 
// and not defined separately
resource subnet 'Microsoft.Network/virtualNetworks/subnets@2023-04-01' = {
  parent: existingVirtualNetwork
  name: '${subnetResourcePrefix}-${subnetName}'
  properties: {
    addressPrefix: subnetAddressPrefix
    networkSecurityGroup: !empty(networkSecurityGroupId)  ? {
      id: networkSecurityGroupId
    } : null
  }
}

output subnetId string = subnet.id 
