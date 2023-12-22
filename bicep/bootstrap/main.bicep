//
// This is the main driver file for deploying each resource defined in the parameters.
// It is responsible for creating the Resource Group, Virtual Network, Subnet, NSG, Public IP, NIC, VM, and Data Disk.
// This script deployment is at subscription scope, hence individual resources need to have their scope defined
// to ensure they are created in the correct resource group.
//

targetScope = 'subscription'

import * as avmtypes from '../../bicep_units/modules/common_infrastructure/common_types.bicep'

@description('Name of the Resource Group')
param resourceGroupName string = 'oraGroup1'

@description('Location')
param location string = 'centralindia'

@description('Oracle VM Image reference')
param oracleImageReference object

@description('List of virtual networks')
param virtualNetworks avmtypes.vnetType[] = []

@description('List of subnets')
param vnetSubnets avmtypes.subnetType[] = []

@description('List of network interfaces')
param networkInterfaces avmtypes.nicType[] = []

@description('List of public IP addresses')
param publicIPAddresses avmtypes.pipType[] = []

@description('List of network security groups')
param networkSecurityGroups avmtypes.nsgType[] = []

@description('List of virtual machines')
param virtualMachines avmtypes.vmType[] = []

@description('List of data disks')
param dataDisks avmtypes.dataDiskType[] = []

@description('Workspace Resource ID DCR for VMs')
param dcrWorkspaceResourceId string?

@description('Tags to be added to the resources')
param tags object = {}

var rgName = '${avmtypes.resourceGroupPrefix}-${resourceGroupName}'

// Create the Resource Group
module rg '../../bicep_units/modules/common_infrastructure/infrastructure.bicep' = {
  name: 'rg'
  scope: subscription()
  params: {
    resourceGroupName: rgName
    location: location
  }
}

// Create a list of virtual networks, based on parameter values.
// Subnets will also have to be provided, subnets will be created as part 
// of vnet resource - to avoid idempotency issues.
module networks '../../bicep_units/modules/network/vnet.bicep' = [for (vnet, i) in virtualNetworks: {
  name: '${vnet.virtualNetworkName}${i}'
  dependsOn: [ rg ]
  scope: resourceGroup(rgName)
  params: {
    virtualNetworkName: vnet.virtualNetworkName
    vnetSubnets: vnetSubnets
    location: location
    vnetAddressPrefix: vnet.addressPrefixes
    diagnosticSettings: !empty(vnet.?diagnosticSettings) ? vnet.diagnosticSettings : []
    roleAssignments: !empty(vnet.?roleAssignments) ? vnet.roleAssignments : []
    lock: !empty(vnet.?lock) ? vnet.lock : null  
    enableTelemetry: false
    tags: tags
  }
}
]


// Create NSG resources, based on parameter values.
module nsgs '../../bicep_units/modules/network/nsg.bicep' = [for (nsg, i) in networkSecurityGroups: {
  name: '${nsg.networkSecurityGroupName}${i}'
  dependsOn: [ networks ]
  scope: resourceGroup(rgName)
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

// Create subnets and associate NSGs if provided
module subnets '../../bicep_units/modules/network/subnet.bicep' = [for (subnet, i) in vnetSubnets:{
  name: '${subnet.subnetName}${i}'
  dependsOn: [ networks, nsgs ]
  scope: resourceGroup(rgName)
  params: {
    subnetName: subnet.subnetName
    virtualNetworkName: subnet.virtualNetworkName
    subnetAddressPrefix: subnet.addressPrefix
    networkSecurityGroupName: !empty(subnet.?networkSecurityGroupName)? subnet.networkSecurityGroupName : null
  }
}
]

// Create Public IP addresses 
module pips 'br/public:avm-res-network-publicipaddress:0.1.0' = [for (pip, i) in publicIPAddresses: {
  name: '${avmtypes.pipResourcePrefix}-${pip.publicIPAddressName}${i}'
  dependsOn: [ rg ]
  scope: resourceGroup(rgName)
  params: {
    location: location
    name: '${avmtypes.pipResourcePrefix}-${pip.publicIPAddressName}'
    diagnosticSettings: !empty(pip.?diagnosticSettings) ? pip.diagnosticSettings : []
    roleAssignments: !empty(pip.?roleAssignments) ? pip.roleAssignments : []
    lock: !empty(pip.?lock) ? pip.lock : null  
    enableTelemetry: false
    tags: tags
  }
}
]

// Create NICs on the first subnet created, and associate Public IP addresses with each NIC
// Optionally assign a Public IP

module nics 'br/public:avm-res-network-networkinterface:0.1.0' = [for (nic, i) in networkInterfaces: {
  name: '${avmtypes.nicResourcePrefix}-${nic.networkInterfaceName}${i}'
  dependsOn: [ pips, subnets, nsgs ]
  scope: resourceGroup(rgName)
  params: {
    location: location
    name: '${avmtypes.nicResourcePrefix}-${nic.networkInterfaceName}'
    enableAcceleratedNetworking: true
    ipConfigurations: [
      {
        name: 'ipconfig1'
        subnetResourceId: resourceId(subscription().subscriptionId,rgName,'Microsoft.Network/virtualNetworks/subnets','vnet-${nic.virtualNetworkName}','snet-${nic.subnetName}') 
        publicIpAddressResourceId: !empty(nic.publicIPAddressName)? resourceId(subscription().subscriptionId, rgName, 'Microsoft.Network/publicIPAddresses', 'pip-${nic.publicIPAddressName}') : null
      }
    ]
    diagnosticSettings: !empty(nic.?diagnosticSettings) ? nic.diagnosticSettings : []
    roleAssignments: !empty(nic.?roleAssignments) ? nic.roleAssignments : []
    lock: !empty(nic.?lock) ? nic.lock : null  
    enableTelemetry: false
    tags: tags
  }
}
]

// Create a Data collection rule, if a workspace ID has been defined for collecting 
// metrics and logs.
module dcr '../../bicep_units/modules/common_infrastructure/data_collection_rules.bicep' = if(!empty(dcrWorkspaceResourceId)) {
  scope: resourceGroup(rgName)
  dependsOn: [rg]
  name : 'dcr'
  params: {
    workspaceResourceId: dcrWorkspaceResourceId
    location: location
  }
}

// Create a set of VMs based on the supplied Oracle Image
module vms '../../bicep_units/modules/compute/vm.bicep' = [for (vm, i) in virtualMachines: {
  name: '${avmtypes.vmResourcePrefix}-${vm.virtualMachineName}${i}'
  dependsOn: [ nics, dcr ]
  scope: resourceGroup(rgName)
  params: {
    vmName: vm.virtualMachineName
    adminUsername: vm.adminUsername
    sshPublicKey: vm.sshPublicKey
    avZone: vm.avZone
    nicId: nics[i].outputs.resourceId
    vmSize: vm.vmSize
    location: location
    diagnosticSettings: !empty(vm.?diagnosticSettings) ? vm.diagnosticSettings : []
    roleAssignments: !empty(vm.?roleAssignments) ? vm.roleAssignments : []
    lock: !empty(vm.?lock) ? vm.lock : null  
    enableTelemetry: false    
    tags: tags
    oracleImageReference: oracleImageReference
    dataCollectionRuleId: !empty(dcrWorkspaceResourceId)?dcr.outputs.dataCollectionRuleId: null
  }
}]

// Create a set of Data disks and attach to the respective VM
module storage '../../bicep_units/modules/storage/datadisk.bicep' =  [for (disk, i) in dataDisks: {
  name: '${avmtypes.dataDiskResourcePrefix}-${disk.diskName}${i}'
  dependsOn: [vms]
  scope: resourceGroup(rgName)
  params: {
    diskName: disk.diskName
    diskSize: disk.diskSizeGB
    diskType: disk.type
    location: location
    lun: disk.lun
    vmName: '${avmtypes.vmResourcePrefix}-${disk.virtualMachineName}'
    avZone: disk.avZone
    roleAssignments: !empty(disk.?roleAssignments) ? disk.roleAssignments : []
    lock: !empty(disk.?lock) ? disk.lock : null  
    enableTelemetry: false    
    tags: tags
  }
}]


