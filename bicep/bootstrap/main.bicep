targetScope = 'subscription'
@description('Name of the Resource Group')
param resourceGroupName string = 'oraGroup1'

@description('Location')
param location string = 'germanywestcentral'

param virtualNetworks array = []
param vnetSubnets array = []
param networkInterfaces array = []
param publicIPAddresses array = []
param networkSecurityGroups array = []
param virtualMachines array = []
param dataDisks array = []

@description('Tags to be added to the resources')
param tags object = {}

// @description('Enable Data guard setup (with 3 machines)')
// param enableDataGuardSetup bool = false

// Create the Resource Group
module rg '../../bicep_units/modules/common_infrastructure/infrastructure.bicep' = {
  name: 'rg'
  scope: subscription()
  params: {
    resourceGroupName: resourceGroupName
    location: location
  }
}

// Create the Virtual Network
module networks '../../bicep_units/modules/network/vnet.bicep' = [for (vnet, i) in virtualNetworks: {
  name: '${vnet.virtualNetworkName}${i}'
  dependsOn: [ rg ]
  scope: resourceGroup(resourceGroupName)
  params: {
    virtualNetworkName: vnet.virtualNetworkName
    location: location
    vnetAddressPrefix: vnet.addressPrefixes
    tags: tags
  }
}
]

// Create the Subnet
module subnets '../../bicep_units/modules/network/subnet.bicep' = [for (subnet, i) in vnetSubnets: {
  name: '${subnet.subnetName}${i}'
  dependsOn: [ networks ]
  scope: resourceGroup(resourceGroupName)
  params: {
    subnetName: subnet.subnetName
    virtualNetworkName: subnet.virtualNetworkName
    subnetAddressPrefix: subnet.addressPrefix
  }
}
]

module pips 'br/public:avm-res-network-publicipaddress:0.1.0' = [for (pip, i) in publicIPAddresses: {
  name: '${pip.publicIPAddressName}${i}'
  dependsOn: [ rg ]
  scope: resourceGroup(resourceGroupName)
  params: {
    location: location
    name: pip.publicIPAddressName
    enableTelemetry: false
  }
}
]

// Create a Blank NSG
module nsgs '../../bicep_units/modules/network/nsg.bicep' = [for (nsg, i) in networkSecurityGroups: {
  name: '${nsg.networkSecurityGroupName}${i}'
  dependsOn: [ networks ]
  scope: resourceGroup(resourceGroupName)
  params: {
    networkSecurityGroupName: nsg.networkSecurityGroupName
    location: location
  }
}]

// Create Public IP addresses

module nics 'br/public:avm-res-network-networkinterface:0.1.0' = [for (nic, i) in networkInterfaces: {
  name: '${nic.networkInterfaceName}${i}'
  dependsOn: [ pips, subnets, nsgs ]
  scope: resourceGroup(resourceGroupName)
  params: {
    location: location
    name: nic.networkInterfaceName
    ipConfigurations: [
      {
        name: 'ipconfig1'
        subnetResourceId: subnets[i].outputs.subnetId
        nsgResourceId: nsgs[i].outputs.nsgId
        publicIpAddressResourceId: pips[i].outputs.resourceId
      }
    ]
    enableTelemetry: false
  }
}
]

// Create a VM based on the Oracle Image
module vms '../../bicep_units/modules/compute/vm.bicep' = [for (vm, i) in virtualMachines: {
  name: '${vm.virtualMachineName}${i}'
  dependsOn: [ nics ]
  scope: resourceGroup(resourceGroupName)
  params: {
    vmName: vm.virtualMachineName
    adminUsername: vm.adminUsername
    sshPublicKey: vm.sshPublicKey
    avZone: vm.avZone
    nicId: nics[i].outputs.resourceId
    vmSize: vm.vmSize
    location: location
    tags: tags
  }
}]

// Create a Data disk and attach to the VM
module storage '../../bicep_units/modules/storage/datadisk.bicep' =  [for (disk, i) in dataDisks: {
  name: '${disk.diskName}${i}'
  dependsOn: [vms]
  scope: resourceGroup(resourceGroupName)
  params: {
    diskName: disk.diskName
    diskSize: disk.size
    diskType: disk.type
    location: location
    lun: disk.lun
    vmName: disk.virtualMachineName
    avZone: disk.avZone
    tags: tags
  }
}]
