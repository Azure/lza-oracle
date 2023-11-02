@description('Name of the VNET')
param virtualNetworkName string = 'vNet'

@description('Name of the subnet in the virtual network')
param subnetName string = 'Subnet'

@description('Subnet Address prefix')
param subnetAddressPrefix string = '10.0.0.0/24'

resource existingVirtualNetwork 'Microsoft.Network/virtualNetworks@2023-04-01' existing = {
  name: virtualNetworkName
}

// TODO: idempotency check
resource subnet 'Microsoft.Network/virtualNetworks/subnets@2023-04-01' = {
  parent: existingVirtualNetwork
  name: subnetName
  properties: {
    addressPrefix: subnetAddressPrefix
  }
  
}

output subnetId string = subnet.id 
