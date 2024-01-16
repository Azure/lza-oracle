using '../../main.bicep'
//import * as avmtypes from '../../../../bicep_units/modules/common_infrastructure/common_types.bicep'

param resourceGroupName = 'oraGroup5'

param location = 'norwayeast'

param virtualNetworks = [
  {
    virtualNetworkName: 'vnet1'
    addressPrefixes: [
      '10.0.0.0/16' ]
    subnetName: 'subnet1'
    addressPrefix: '10.0.0.0/24'
  } ]

param networkSecurityGroups = [
  {
    networkSecurityGroupName: 'ora01nsg'
    securityRules: []
  }
]

// param publicIPAddresses = [
//   {
//     publicIPAddressName: 'pip01'
//   }
// ]

// param networkInterfaces = [
//   {
//     virtualNetworkName: 'vnet1'
//     subnetName: 'subnet1'
//     networkInterfaceName: 'ora01nic0'
//     publicIPAddressName: 'pip01'
//   }
// ]

// param dataDisks = [
//   {
//     diskName: 'oracle-data-0'
//     diskSizeGB: 1024
//     type: 'Premium_LRS'
//     lun: 20
//     hostDiskCaching: 'ReadOnly'
//     virtualMachineName: 'ora01'
//     avZone: 1
//   }
//   {
//     diskName: 'oracle-asm-0'
//     diskSizeGB: 1024
//     type: 'Premium_LRS'
//     lun: 10
//     hostDiskCaching: 'ReadOnly'
//     virtualMachineName: 'ora01'
//     avZone: 1
//   }
//   {
//     diskName: 'oracle-redo-0'
//     diskSizeGB: 1024
//     type: 'Premium_LRS'
//     lun: 60
//     hostDiskCaching: 'None'
//     virtualMachineName: 'ora01'
//     avZone: 1
//   }
// ]

param virtualMachines = [
  {
    virtualMachineName: 'ora01'
    vmSize: 'Standard_D4s_v5'
    avZone: 1
    adminUsername: 'oracle'
    sshPublicKey: '<sshKey>'
    dataDisks: [
      {
        caching: 'None'
        writeAcceleratorEnabled: false
        diskSizeGB: '128'
        managedDisk: {
          storageAccountType: 'Premium_LRS'
        }
      }
      {
        caching: 'None'
        diskSizeGB: '128'
        managedDisk: {
          storageAccountType: 'Premium_LRS'
        }
      }
      {
        name: 'redo'
        caching: 'ReadOnly'
        writeAcceleratorEnabled: false
        diskSizeGB: '128'
        managedDisk: {
          storageAccountType: 'Premium_LRS'
        }
      }
    ]
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
