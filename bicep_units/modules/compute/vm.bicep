@description('The name of Virtual Machine.')
param vmName string = 'oravm'

@description('Username for the Virtual Machine.')
param adminUsername string

@description('SSH Public key')
param sshPublicKey string 

@description('The size of the VM')
param vmSize string = 'Standard_D2ds_v5'

@description('Availability zone')
param avZone string = '1'

@description('Location for all resources.')
param location string = resourceGroup().location

@description('ID of the network interface')
param nicId string 

@description('Tags to be added to the resources')
param tags object ={}

var sshConfiguration = {
  disablePasswordAuthentication: true
  ssh: {
    publicKeys: [
      {
        path: '/home/${adminUsername}/.ssh/authorized_keys'
        keyData: sshPublicKey
      }
    ]
  }
}

var oracleImageReference =   {
  publisher: 'oracle'
  offer: 'oracle-database-19-3'
  sku: 'oracle-database-19-0904'
  version: 'latest'
}

resource vm 'Microsoft.Compute/virtualMachines@2023-03-01' = {
  name: vmName
  location: location
  zones: [avZone]
  identity: {
    type: 'SystemAssigned'
  }
  tags: tags
  properties: {
    
    hardwareProfile: {
      vmSize: vmSize
    }
    storageProfile: {
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Premium_LRS'           
        }
      }
      imageReference: oracleImageReference
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nicId
        }
      ]
    }
    osProfile: {
      computerName: vmName
      adminUsername: adminUsername
      linuxConfiguration: sshConfiguration 
    }
    
  }
}

output vmId string = vm.id
