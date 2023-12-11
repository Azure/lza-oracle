using '../../main.bicep'
import * as avmtypes from '../../../../bicep_units/modules/common_infrastructure/common_types.bicep'

param resourceGroupName = 'oraGroup1'

param location = 'centralindia'

param virtualNetworks = [
  {
    virtualNetworkName: 'vnet1'
    addressPrefixes: [
      '10.0.0.0/16' ]
  }
]

param vnetSubnets = [
  {
    virtualNetworkName: 'vnet1'
    subnetName: 'subnet1'
    addressPrefix: '10.0.0.0/24'
    networkSecurityGroupName: 'ora01nsg'
  }
]

param networkSecurityGroups = [
  {
    networkSecurityGroupName: 'ora01nsg'
    securityRules: [
    ]
  }
]

param publicIPAddresses = [
  {
    publicIPAddressName: '01'
  }
  {
    publicIPAddressName: '02'
  }
  {
    publicIPAddressName: '03'
  }
]

param networkInterfaces = [
  {
    virtualNetworkName: 'vnet1'
    subnetName: 'subnet1'
    networkInterfaceName: '01'
    publicIPAddressName: '01'
  }
  {
    virtualNetworkName: 'vnet1'
    subnetName: 'subnet1'
    networkInterfaceName: '02'
    publicIPAddressName: '02'
  }
  {
    virtualNetworkName: 'vnet1'
    subnetName: 'subnet1'
    networkInterfaceName: '03'
    publicIPAddressName: '03'
  }
]

param dataDisks = [
  {
    diskName: 'primary'
    diskSizeGB: 256
    type: 'Premium_LRS'
    lun: 0
    virtualMachineName: 'primary'
    avZone: '1'
  }
  {
    diskName: 'secondary'
    diskSizeGB: 256
    type: 'Premium_LRS'
    lun: 0
    virtualMachineName: 'secondary'
    avZone: '2'
  }
  {
    diskName: 'observer'
    diskSizeGB: 256
    type: 'Premium_LRS'
    lun: 0
    virtualMachineName: 'observer'
    avZone: '2'
  }
]

param virtualMachines = [
  {
    virtualMachineName: 'primary'
    vmSize: 'Standard_D4s_v5'
    avZone: '1'
    adminUsername : ''
    sshPublicKey : ''
  }
  {
    virtualMachineName: 'secondary'
    vmSize: 'Standard_D4s_v5'
    avZone: '2'
    adminUsername : ''
    sshPublicKey : ''  }
  {
    virtualMachineName: 'observer'
    vmSize: 'Standard_D4s_v5'
    avZone: '2'
    adminUsername : ''
    sshPublicKey : ''
  }
]

param tags = {
  environment: 'dev'
  costCenter: 'it'
}

param oracleImageReference = {
  publisher: 'oracle'
  offer: 'oracle-database-19-3'
  sku: 'oracle-database-19-0904'
  version: 'latest'
}
