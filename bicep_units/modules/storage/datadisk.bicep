type storageDiskDescription = {
  name: string
  caching: string
  disk_size_gb: int
  lun: string
  managed_disk_type: string
  storage_account_type: string 
}
@description('Disk name')
param diskName string

@description('Disk size')
param diskSize int

@description('Logical unit')
param lun int

@description('Location')
param location string = resourceGroup().location

@description('The name of Virtual Machine.')
param vmName string = 'oravm'

@description('The type of storage account')
@allowed(['Premium_LRS','Standard_LRS','StandardSSD_LRS','StandardSSD_ZRS','PremiumV2_LRS','Premium_ZRS','UltraSSD_LRS'])
param diskType string = 'Premium_LRS'

@description('Availability zone')
param avZone string = '1'

@description('Tags to be added to the resources')
param tags object ={}

// create the disk 
resource data_disk 'Microsoft.Compute/disks@2023-04-02' =  {
  name: diskName
  location: location
  sku: {name: diskType}
  zones:[avZone]
  properties: { 
    creationData: {
      createOption: 'Empty'
      }
    diskSizeGB: diskSize
    
  }
  tags: tags
}

// attach the disk
resource vmDisk 'Microsoft.Compute/virtualMachines@2023-03-01' = {
  name: vmName
  location: location
  properties: {
    storageProfile:{
      dataDisks: [
        {
          createOption: 'Attach'
          managedDisk: {
            id: data_disk.id
          }  
          lun: lun
        }
      ]
    }
  }
}

output dataDiskId string =  data_disk.id
 