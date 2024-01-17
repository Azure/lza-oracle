//
// This is the main driver file for deploying each resource defined in the parameters.
// It is responsible for creating the Resource Group, Virtual Network, Subnet, NSG, Public IP, NIC, VM, and Data Disk.
// This script deployment is at subscription scope, hence individual resources need to have their scope defined
// to ensure they are created in the correct resource group.
//

targetScope = 'subscription'

//import * as avmtypes from '../../bicep_units/modules/common_infrastructure/common_types.bicep'

@description('Name of the Resource Group')
param resourceGroupName string 

@description('Location')
param location string = 'centralindia'

@description('Oracle VM Image reference')
param oracleImageReference object

@description('List of virtual networks')
param virtualNetworks array

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

// // Create NSG resources, based on parameter values.
// module nsgs '../../bicep_units/modules/network/nsg.bicep' = [for (nsg, i) in networkSecurityGroups: {
//   name: '${nsg.networkSecurityGroupName}${i}'
//   dependsOn: [ rg ]
//   scope: resourceGroup(resourceGroupName)
//   params: {
//     networkSecurityGroupName: nsg.networkSecurityGroupName
//     securityRules: nsg.securityRules
//     location: location
//     diagnosticSettings: !empty(nsg.?diagnosticSettings) ? nsg.diagnosticSettings : []
//     roleAssignments: !empty(nsg.?roleAssignments) ? nsg.roleAssignments : []
//     lock: !empty(nsg.?lock) ? nsg.lock : null
//     enableTelemetry: false
//     tags: tags
//   }
// }]

module nsgs 'br/public:avm/res/network/network-security-group:0.1.2' = [for (nsg, i) in networkSecurityGroups: {
  name: '${nsg.networkSecurityGroupName}${i}'
  dependsOn: [ rg ]
  scope: resourceGroup(resourceGroupName)
  params: {
    name: nsg.networkSecurityGroupName
    securityRules: nsg.securityRules
    location: location
    enableTelemetry: false
    tags: tags
  }
}]

// // Create a Data collection rule, if a workspace ID has been defined for collecting 
// // metrics and logs.
// module dcr '../../bicep_units/modules/common_infrastructure/data_collection_rules.bicep' = if (!empty(dcrWorkspaceResourceId)) {
//   scope: resourceGroup(resourceGroupName)
//   dependsOn: [ rg ]
//   name: 'dcr'
//   params: {
//     workspaceResourceId: dcrWorkspaceResourceId
//     location: location
//   }
// }

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
            subnetResourceId: networks[0].outputs.subnetResourceIds[0]
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

