//
// This module creates the resource Group for all the subsequent resources.
//
metadata name = 'Common infrastructure'
metadata description = 'This module provisions a Resource Group'
metadata owner = 'Azure/module-maintainers'

import * as avmtypes from '../common_infrastructure/common_types.bicep'

targetScope='subscription'

@description('Name of the Resource Group')
param resourceGroupName string = 'oraGroup'

@description('Location')
param location string = 'westeurope'

@description('Optional. The lock settings of the service.')
param lock avmtypes.lockType

@description('Optional. Array of role assignment objects that contain the \'roleDefinitionIdOrName\' and \'principalId\' to define RBAC role assignments on this resource. In the roleDefinitionIdOrName attribute, you can provide either the display name of the role definition, or its fully qualified ID in the following format: \'/providers/Microsoft.Authorization/roleDefinitions/c2f4ef07-c644-48eb-af81-4b1b4947fb11\'.')
param roleAssignments avmtypes.roleAssignmentType

@description('Optional. Enable telemetry via a Globally Unique Identifier (GUID).')
param enableTelemetry bool = false

@description('Tags to be added to the resources')
param tags object ={}

resource resourceGroup 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: resourceGroupName
  location: location 
  
  tags: tags
}

module resourceGroup_lock 'modules/nested_lock.bicep' = if (!empty(lock ?? {}) && lock.?kind != 'None') {
  name: '${uniqueString(deployment().name, location)}-RG-Lock'
  params: {
    lock: lock
    resourceGroupName: resourceGroup.name
  }
  scope: resourceGroup
}

resource resourceGroupRoleAssignments 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = [for (roleAssignment, index) in (roleAssignments ?? []): {
  name: guid(resourceGroup.id, roleAssignment.principalId, roleAssignment.roleDefinitionIdOrName)
  properties: {
    roleDefinitionId: contains(avmtypes.builtInRoleNames, roleAssignment.roleDefinitionIdOrName) ? avmtypes.builtInRoleNames[roleAssignment.roleDefinitionIdOrName] : roleAssignment.roleDefinitionIdOrName
    principalId: roleAssignment.principalId
    description: roleAssignment.?description
    principalType: roleAssignment.?principalType
    condition: roleAssignment.?condition
    conditionVersion: !empty(roleAssignment.?condition) ? (roleAssignment.?conditionVersion ?? '2.0') : null // Must only be set if condtion is set
    delegatedManagedIdentityResourceId: roleAssignment.?delegatedManagedIdentityResourceId
  } 
}]


resource defaultTelemetry 'Microsoft.Resources/deployments@2023-07-01' = if (enableTelemetry) {
  name: 'pid-47ed15a6-730a-4827-bcb4-0fd963ffbd82-${uniqueString(deployment().name, location)}'
  location: location
  properties: {
    mode: 'Incremental'
    template: {
      '$schema': 'https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#'
      contentVersion: '1.0.0.0'
      resources: []
    }
  }
}

output resourceGroupName string = resourceGroup.name
