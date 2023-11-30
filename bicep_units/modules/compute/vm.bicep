
metadata name = 'vm'
metadata description = 'This module provisions a virtual machine along with supporting AVN resources'
metadata owner = 'Azure/module-maintainers'

import * as avmtypes from '../common_infrastructure/common_types.bicep'

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

// AVM req - a Prefix is required
param vmResourcePrefix string = avmtypes.vmResourcePrefix

@description('Oracle VM Image reference')
param oracleImageReference object

@description('Optional. The lock settings of the service.')
param lock avmtypes.lockType

@description('Optional. Array of role assignment objects that contain the \'roleDefinitionIdOrName\' and \'principalId\' to define RBAC role assignments on this resource. In the roleDefinitionIdOrName attribute, you can provide either the display name of the role definition, or its fully qualified ID in the following format: \'/providers/Microsoft.Authorization/roleDefinitions/c2f4ef07-c644-48eb-af81-4b1b4947fb11\'.')
param roleAssignments avmtypes.roleAssignmentType

@description('Optional. The diagnostic settings of the service.')
param diagnosticSettings avmtypes.diagnosticSettingType

@description('Optional. Enable telemetry via a Globally Unique Identifier (GUID).')
param enableTelemetry bool = true

@description('Tags to be added to the resources')
param tags object ={}

var virtualMachineName = '${vmResourcePrefix}-${vmName}'

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

resource vmUserIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: '${virtualMachineName}-identity'
  location: location
}

resource vm 'Microsoft.Compute/virtualMachines@2023-03-01' = {
  name: virtualMachineName
  location: location
  zones: [avZone]
  identity: {
    type: 'UserAssigned' 
    userAssignedIdentities: {
      '${vmUserIdentity.id}': {}
    }
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
      computerName: virtualMachineName
      adminUsername: adminUsername
      linuxConfiguration: sshConfiguration 
    }
    
  }
}

resource virtuaMachineLock 'Microsoft.Authorization/locks@2016-09-01' = if (!empty(lock ?? {}) && lock.?kind != 'None') { 
  name: lock.?name ?? 'lock-${virtualMachineName}'
  properties: {
    level: lock.?kind ?? ''
    notes: lock.?kind == 'CanNotDelete' ? 'Cannot delete resource or child resources.' : 'Cannot delete or modify the resource or child resources.'
  }
  scope: vm
}

resource virtualNetworkRoleAssignments 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = [for (roleAssignment, index) in (roleAssignments ?? []): {
  name: guid(vm.id, roleAssignment.principalId, roleAssignment.roleDefinitionIdOrName)
  properties: {
    roleDefinitionId: contains(avmtypes.builtInRoleNames, roleAssignment.roleDefinitionIdOrName) ? avmtypes.builtInRoleNames[roleAssignment.roleDefinitionIdOrName] : roleAssignment.roleDefinitionIdOrName
    principalId: roleAssignment.principalId
    description: roleAssignment.?description
    principalType: roleAssignment.?principalType
    condition: roleAssignment.?condition
    conditionVersion: !empty(roleAssignment.?condition) ? (roleAssignment.?conditionVersion ?? '2.0') : null // Must only be set if condtion is set
    delegatedManagedIdentityResourceId: roleAssignment.?delegatedManagedIdentityResourceId
  }
  scope: vm
}]


resource extension 'Microsoft.Compute/virtualMachines/extensions@2022-11-01' = [for (diagnosticSetting, index) in (diagnosticSettings ?? []): if (diagnosticSetting.enableVmGuestMonitoring) {
  name: '${uniqueString(deployment().name, location)}-VM-${index}'
  parent: vm
  location: location
  properties: {
    publisher: diagnosticSetting.vmAgentConfiguration.publisher
    type: diagnosticSetting.vmAgentConfiguration.type
    typeHandlerVersion: !empty(diagnosticSetting.?vmAgentConfiguration.?typeHandlerVersion) ? diagnosticSetting.vmAgentConfiguration.typeHandlerVersion : '1.21'
    autoUpgradeMinorVersion: diagnosticSetting.?vmAgentConfiguration.?autoUpgradeMinorVersion ?? true
    enableAutomaticUpgrade: diagnosticSetting.?vmAgentConfiguration.?enableAutomaticUpgrade ?? true 
    settings: {
      workspaceId: diagnosticSetting.workspaceResourceId
      authentication: {
        'identifier-name' : 'mi_res_id'
        'identifier-value' : vmUserIdentity.id
      }
    }
  } 
}]


resource defaultTelemetry 'Microsoft.Resources/deployments@2023-07-01' = if (enableTelemetry) {
  name: 'pid-47ed15a6-730a-4827-bcb4-0fd963ffbd82-${uniqueString(deployment().name, location)}'
  properties: {
    mode: 'Incremental'
    template: {
      '$schema': 'https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#'
      contentVersion: '1.0.0.0'
      resources: []
    }
  }
}

output vmId string = vm.id
output vmName string = vm.name
