targetScope= 'subscription'
@description('Name of the Resource Group')
param resourceGroupName string = 'oraGroup'

@description('Location')
param location string  

@description('Virtual Network Name')
param virtualNetworkName string = 'vnet1'

@description('VNET Address prefix')
param vnetAddressPrefix string = '10.0.0.0/16'

@description('Subnet Address prefix')
param subnetAddressPrefix string = '10.0.0.0/24'

@description('Name of the Network Security Group')
param networkSecurityGroupName string = 'SecGroupNet'

@description('Name of the Network interface')
param networkInterfaceName string = 'NicName'

@description('Database disk size')
param databaseDiskSize int = 128

@description('The name of you Virtual Machine.')
param vmName string = 'oravm'

@description('Username for the Virtual Machine.')
param adminUsername string = 'bala'

@description('SSH Public key')
param sshPublicKey string 

@description('The size of the VM')
param vmSize string = 'Standard_D2ds_v5'

@description('Availability zone')
param avZone string = '1'

@description('Tags to be added to the resources')
param tags object ={}

@description('Enable Data guard setup (with 3 machines)')
param enableDataGuardSetup bool = false

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
module network '../../bicep_units/modules/network/vnet.bicep' = {
  name: 'vnet' 
  dependsOn:[rg]
  scope: resourceGroup(resourceGroupName)
  params: {
    virtualNetworkName: virtualNetworkName
    location: location  
    vnetAddressPrefix: vnetAddressPrefix
    tags: tags
  }
}

// Create the Subnet
module subnet '../../bicep_units/modules/network/subnet.bicep' = {
  name: 'subnet' 
  dependsOn:[network]
  scope: resourceGroup(resourceGroupName)
  params: {
    virtualNetworkName: virtualNetworkName
    subnetAddressPrefix: subnetAddressPrefix
  }
}

// Create a Blank NSG
module nsg '../../bicep_units/modules/network/nsg.bicep' = {
  name: 'nsg' 
  dependsOn:[network]
  scope: resourceGroup(resourceGroupName)
  params: {
    networkSecurityGroupName: networkSecurityGroupName
    location: location
  }
}

// Create a Public IP address
module pip '../../bicep_units/modules/network/pip.bicep' = {
  name: 'pip'
  dependsOn:[network]
  scope: resourceGroup(resourceGroupName)
  params: {
    pipName: 'publicIp1'
    location: location
    avZone: avZone
  }
}

// Create a NIC with the NSG and Public IP
module nic '../../bicep_units/modules/network/nic.bicep' = {
  name:'nic'
  dependsOn:[network,pip,subnet]
  scope: resourceGroup(resourceGroupName)
  params: {
    networkInterfaceName: networkInterfaceName
    location: location
    nsgId: nsg.outputs.nsgId
    pipId: pip.outputs.pipId
    subnetId: subnet.outputs.subnetId
  }
}

// Create a VM based on the Oracle Image
module vm '../../bicep_units/modules/compute/vm.bicep' = {
  name: 'vm'
  dependsOn: [nic]
  scope: resourceGroup(resourceGroupName)
  params: {
    vmName: vmName
    adminUsername: adminUsername
    sshPublicKey: sshPublicKey
    avZone: avZone
    nicId: nic.outputs.nicId
    vmSize: vmSize
    location: location
    tags: tags
  }
}

// Create a Data disk and attach to the VM
module storage '../../bicep_units/modules/storage/datadisk.bicep' = {
  name: 'storage'
  dependsOn: [vm]
  scope: resourceGroup(resourceGroupName)
  params: {
    diskName: 'dataDisk1'
    diskSize: databaseDiskSize
    diskType: 'Premium_LRS'
    location: location
    lun: 10
    vmName: vmName
    avZone: avZone
    tags: tags
  }
}

