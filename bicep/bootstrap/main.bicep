//
// This is the main driver file for deploying each resource defined in the parameters.
// It is responsible for creating the Resource Group, Virtual Network, Subnet, NSG, Public IP, NIC, VM, and Data Disk.
// This script deployment is at subscription scope, hence individual resources need to have their scope defined
// to ensure they are created in the correct resource group.
//

targetScope = 'subscription'

//import * as avmtypes from '../../bicep_units/modules/common_infrastructure/common_types.bicep'

@description('Name of the Resource Group')
param resourceGroupName string = 'oraGroup2'

@description('Location')
param location string = 'centralindia'

@description('Oracle VM Image reference')
param oracleImageReference object

@description('List of virtual networks')
param virtualNetworks array

@description('List of subnets')
param vnetSubnets array

@description('List of network security groups')
param networkSecurityGroups array

@description('List of virtual machines')
param virtualMachines array

@description('Workspace Resource ID DCR for VMs')
param dcrWorkspaceResourceId string?

@description('Tags to be added to the resources')
param tags object = {}

//var rgName = '${avmtypes.resourceGroupPrefix}-${resourceGroupName}'

// Create the Resource Group
module rg '../../bicep_units/modules/common_infrastructure/infrastructure.bicep' = {
  name: 'rg'
  scope: subscription()
  params: {
    resourceGroupName: resourceGroupName
    location: location
  }
}

// Create a list of virtual networks, based on parameter values.
// Subnets will also have to be provided, subnets will be created as part 
// of vnet resource - to avoid idempotency issues.
// module networks '../../bicep_units/modules/network/vnet.bicep' = [for (vnet, i) in virtualNetworks: {
//   name: '${vnet.virtualNetworkName}${i}'
//   dependsOn: [ rg ]
//   scope: resourceGroup(resourceGroupName)
//   params: {
//     virtualNetworkName: vnet.virtualNetworkName
//     vnetSubnets: vnetSubnets
//     location: location
//     vnetAddressPrefix: vnet.addressPrefixes
//     diagnosticSettings: !empty(vnet.?diagnosticSettings) ? vnet.diagnosticSettings : []
//     roleAssignments: !empty(vnet.?roleAssignments) ? vnet.roleAssignments : []
//     lock: !empty(vnet.?lock) ? vnet.lock : null
//     enableTelemetry: false
//     tags: tags
//   }
// }
// ]

// Create a list of virtual networks, based on parameter values.
// Subnets will also have to be provided, subnets will be created as part 
// of vnet resource - to avoid idempotency issues.
module networks 'br/public:avm/res/network/virtual-network:0.1.1' = [for (vnet, i) in virtualNetworks: {
  name: '${vnet.virtualNetworkName}${i}'
  dependsOn: [ rg, nsgs ]
  scope: resourceGroup(resourceGroupName)
  params: {
    name: vnet.virtualNetworkName
    subnets: [ {
        name: vnet.subnetName
        addressPrefix: vnet.addressPrefix
        networkSecurityGroupResourceId: nsgs[0].outputs.resourceId
      }
    ]
    location: location
    addressPrefixes: vnet.addressPrefixes
    enableTelemetry: false
    tags: tags
  }
}
]

// Create NSG resources, based on parameter values.
module nsgs '../../bicep_units/modules/network/nsg.bicep' = [for (nsg, i) in networkSecurityGroups: {
  name: '${nsg.networkSecurityGroupName}${i}'
  dependsOn: [ rg ]
  scope: resourceGroup(resourceGroupName)
  params: {
    networkSecurityGroupName: nsg.networkSecurityGroupName
    securityRules: nsg.securityRules
    location: location
    diagnosticSettings: !empty(nsg.?diagnosticSettings) ? nsg.diagnosticSettings : []
    roleAssignments: !empty(nsg.?roleAssignments) ? nsg.roleAssignments : []
    lock: !empty(nsg.?lock) ? nsg.lock : null
    enableTelemetry: false
    tags: tags
  }
}]

// // Create subnets and associate NSGs if provided
// module subnets '../../bicep_units/modules/network/subnet.bicep' = [for (subnet, i) in vnetSubnets: {
//   name: '${subnet.subnetName}${i}'
//   dependsOn: [ networks, nsgs ]
//   scope: resourceGroup(resourceGroupName)
//   params: {
//     subnetName: subnet.subnetName
//     virtualNetworkName: subnet.virtualNetworkName
//     subnetAddressPrefix: subnet.addressPrefix
//     networkSecurityGroupName: !empty(subnet.?networkSecurityGroupName) ? subnet.networkSecurityGroupName : null
//   }
// }
// ]

// // Create Public IP addresses 
// module pips 'br/public:avm-res-network-publicipaddress:0.1.0' = [for (pip, i) in publicIPAddresses: {
//   name: '${avmtypes.pipResourcePrefix}-${pip.publicIPAddressName}${i}'
//   dependsOn: [ rg ]
//   scope: resourceGroup(rgName)
//   params: {
//     location: location
//     name: '${avmtypes.pipResourcePrefix}-${pip.publicIPAddressName}'
//     diagnosticSettings: !empty(pip.?diagnosticSettings) ? pip.diagnosticSettings : []
//     roleAssignments: !empty(pip.?roleAssignments) ? pip.roleAssignments : []
//     lock: !empty(pip.?lock) ? pip.lock : null
//     enableTelemetry: false
//     tags: tags
//   }
// }
// ]

// // Create NICs on the first subnet created, and associate Public IP addresses with each NIC
// // Optionally assign a Public IP

// module nics 'br/public:avm-res-network-networkinterface:0.1.0' = [for (nic, i) in networkInterfaces: {
//   name: '${avmtypes.nicResourcePrefix}-${nic.networkInterfaceName}${i}'
//   dependsOn: [ pips, subnets, nsgs ]
//   scope: resourceGroup(rgName)
//   params: {
//     location: location
//     name: '${avmtypes.nicResourcePrefix}-${nic.networkInterfaceName}'
//     enableAcceleratedNetworking: true
//     networkSecurityGroupResourceId: nsgs[0].outputs.resourceId
//     ipConfigurations: [
//       {
//         name: 'ipconfig1'
//         subnetResourceId: resourceId(subscription().subscriptionId, rgName, 'Microsoft.Network/virtualNetworks/subnets', 'vnet-${nic.virtualNetworkName}', 'snet-${nic.subnetName}')
//         publicIpAddressResourceId: !empty(nic.publicIPAddressName) ? resourceId(subscription().subscriptionId, rgName, 'Microsoft.Network/publicIPAddresses', 'pip-${nic.publicIPAddressName}') : null
//       }
//     ]
//     diagnosticSettings: !empty(nic.?diagnosticSettings) ? nic.diagnosticSettings : []
//     roleAssignments: !empty(nic.?roleAssignments) ? nic.roleAssignments : []
//     lock: !empty(nic.?lock) ? nic.lock : null
//     enableTelemetry: false
//     tags: tags
//   }
// }
// ]

// Create a Data collection rule, if a workspace ID has been defined for collecting 
// metrics and logs.
module dcr '../../bicep_units/modules/common_infrastructure/data_collection_rules.bicep' = if (!empty(dcrWorkspaceResourceId)) {
  scope: resourceGroup(resourceGroupName)
  dependsOn: [ rg ]
  name: 'dcr'
  params: {
    workspaceResourceId: dcrWorkspaceResourceId
    location: location
  }
}

// Create a set of VMs based on the supplied Oracle Image
module vms 'br/public:avm/res/compute/virtual-machine:0.1.0' = [for (vm, i) in virtualMachines: {
  name: vm.virtualMachineName
  dependsOn: [ dcr ]
  scope: resourceGroup(resourceGroupName)
  params: {
    name: vm.virtualMachineName
    adminUsername: vm.adminUsername
    availabilityZone: vm.avZone
    osDisk: {
      caching: 'ReadWrite'
      diskSizeGB: '128'
      managedDisk: {
        storageAccountType: 'Premium_LRS'
      }
    }
    osType: 'Linux'
    publicKeys: [
      {
        keyData: vm.sshPublicKey
        path: '/home/${vm.adminUsername}/.ssh/authorized_keys'
      }
    ]
    nicConfigurations: [
      {
        ipConfigurations: [
          {
            name: 'ipconfig01'
            pipConfiguration: {
              publicIpNameSuffix: '-pip-01'
            }
            subnetResourceId: subnets[0].outputs.subnetId
          }
        ]
        nicSuffix: '-nic-01'
      }
    ]
    dataDisks: vm.dataDisks
    disablePasswordAuthentication: true
    vmSize: vm.vmSize
    location: location
    encryptionAtHost: false //revisit this
    // diagnosticSettings: !empty(vm.?diagnosticSettings) ? vm.diagnosticSettings : []
    // roleAssignments: !empty(vm.?roleAssignments) ? vm.roleAssignments : []
    // lock: !empty(vm.?lock) ? vm.lock : null
    enableTelemetry: false
    tags: tags
    imageReference: oracleImageReference
    //dataCollectionRuleId: !empty(dcrWorkspaceResourceId) ? dcr.outputs.dataCollectionRuleId : null
  }
}]

// // Create a set of VMs based on the supplied Oracle Image
// module vms '../../bicep_units/modules/compute/vm.bicep' = [for (vm, i) in virtualMachines: {
//   name: '${avmtypes.vmResourcePrefix}-${vm.virtualMachineName}${i}'
//   dependsOn: [ nics, dcr ]
//   scope: resourceGroup(rgName)
//   params: {
//     vmName: vm.virtualMachineName
//     adminUsername: vm.adminUsername
//     sshPublicKey: vm.sshPublicKey
//     avZone: vm.avZone
//     nicId: nics[i].outputs.resourceId
//     vmSize: vm.vmSize
//     location: location
//     diagnosticSettings: !empty(vm.?diagnosticSettings) ? vm.diagnosticSettings : []
//     roleAssignments: !empty(vm.?roleAssignments) ? vm.roleAssignments : []
//     lock: !empty(vm.?lock) ? vm.lock : null
//     enableTelemetry: false
//     tags: tags
//     oracleImageReference: oracleImageReference
//     dataCollectionRuleId: !empty(dcrWorkspaceResourceId) ? dcr.outputs.dataCollectionRuleId : null
//   }
// }]

//Create a set of Data disks and attach to the respective VM
// module storage '../../bicep_units/modules/storage/datadisk.bicep' = [for (disk, i) in dataDisks: {
//   name: 'disk-${disk.diskName}${i}'
//   dependsOn: [  ]
//   scope: resourceGroup(rgName)
//   params: {
//     diskName: disk.diskName
//     diskSize: disk.diskSizeGB
//     diskType: disk.type
//     location: location
//     avZone: disk.avZone
//     // roleAssignments: !empty(disk.?roleAssignments) ? disk.roleAssignments : []
//     // lock: !empty(disk.?lock) ? disk.lock : null
//     enableTelemetry: false
//     tags: tags
//   }
// }]

output nsgresid string = nsgs[0].outputs.resourceId
