targetScope = 'subscription'
@description('Name of the Resource Group')
param resourceGroupName string = 'oraGroup1'

@description('Location')
param location string = 'germanywestcentral'

@description('Oracle VM Image reference')
param oracleImageReference object

param virtualNetworks array = []
param vnetSubnets array = []
param networkInterfaces array = []
param publicIPAddresses array = []
param networkSecurityGroups array = []
param virtualMachines array = []
param dataDisks array = []

@description('Tags to be added to the resources')
param tags object = {}

var rgName = 'rg-${resourceGroupName}'

// Create the Resource Group
module rg '../../bicep_units/modules/common_infrastructure/infrastructure.bicep' = {
  name: 'rg'
  scope: subscription()
  params: {
    resourceGroupName: rgName
    location: location
  }
}

// Create the Virtual Network
module networks '../../bicep_units/modules/network/vnet.bicep' = [for (vnet, i) in virtualNetworks: {
  name: '${vnet.virtualNetworkName}${i}'
  dependsOn: [ rg ]
  scope: resourceGroup(rgName)
  params: {
    virtualNetworkName: vnet.virtualNetworkName
    vnetSubnets: vnetSubnets
    location: location
    vnetAddressPrefix: vnet.addressPrefixes
    tags: tags
  }
}
]

// Create a Blank NSG
module nsgs '../../bicep_units/modules/network/nsg.bicep' = [for (nsg, i) in networkSecurityGroups: {
  name: '${nsg.networkSecurityGroupName}${i}'
  dependsOn: [ networks ]
  scope: resourceGroup(rgName)
  params: {
    networkSecurityGroupName: nsg.networkSecurityGroupName
    location: location
    tags: tags
  }
}]

// Create the Subnet and associate the first NSG created earlier
module subnets '../../bicep_units/modules/network/subnet.bicep' = [for (subnet, i) in vnetSubnets:{
  name: '${subnet.subnetName}${i}'
  dependsOn: [ networks ]
  scope: resourceGroup(rgName)
  params: {
    subnetName: subnet.subnetName
    virtualNetworkName: subnet.virtualNetworkName
    subnetAddressPrefix: subnet.addressPrefix
    networkSecurityGroupId: nsgs[0].outputs.resourceId
  }
}
]

// Create Public IP addresses 
module pips 'br/public:avm-res-network-publicipaddress:0.1.0' = [for (pip, i) in publicIPAddresses: {
  name: 'pip-${pip.publicIPAddressName}${i}'
  dependsOn: [ rg ]
  scope: resourceGroup(rgName)
  params: {
    location: location
    name: 'pip-${pip.publicIPAddressName}'
    enableTelemetry: false
    tags: tags
  }
}
]

// Create NICs on the first subnet created, and associate Public IP addresses with each NIC
// The # of NICs should match the # of Public IPs.

module nics 'br/public:avm-res-network-networkinterface:0.1.0' = [for (nic, i) in networkInterfaces: {
  name: 'nic-${nic.networkInterfaceName}${i}'
  dependsOn: [ pips, subnets, nsgs ]
  scope: resourceGroup(rgName)
  params: {
    location: location
    name: 'nic-${nic.networkInterfaceName}'
    enableAcceleratedNetworking: true
    ipConfigurations: [
      {
        name: 'ipconfig1'
        subnetResourceId: subnets[0].outputs.subnetId
        publicIpAddressResourceId: pips[i].outputs.resourceId
      }
    ]
    enableTelemetry: false
    tags: tags
  }
}
]

// Create a VM based on the supplied Oracle Image
module vms '../../bicep_units/modules/compute/vm.bicep' = [for (vm, i) in virtualMachines: {
  name: 'vm-${vm.virtualMachineName}${i}'
  dependsOn: [ nics ]
  scope: resourceGroup(rgName)
  params: {
    vmName: vm.virtualMachineName
    adminUsername: vm.adminUsername
    sshPublicKey: vm.sshPublicKey
    avZone: vm.avZone
    nicId: nics[i].outputs.resourceId
    vmSize: vm.vmSize
    location: location
    tags: tags
    oracleImageReference: oracleImageReference
  }
}]

// Create a Data disk and attach to the VM
module storage '../../bicep_units/modules/storage/datadisk.bicep' =  [for (disk, i) in dataDisks: {
  name: 'disk-${disk.diskName}${i}'
  dependsOn: [vms]
  scope: resourceGroup(rgName)
  params: {
    diskName: disk.diskName
    diskSize: disk.size
    diskType: disk.type
    location: location
    lun: disk.lun
    vmName: 'vm-${disk.virtualMachineName}'
    avZone: disk.avZone
    tags: tags
  }
}]
