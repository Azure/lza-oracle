metadata name = 'nsg'
metadata description = 'This module provisions a network security group with required security rules.'
metadata owner = 'Azure/module-maintainers'

import * as avmtypes from '../common_infrastructure/common_types.bicep'

@description('Name of the Network Security Group')
param networkSecurityGroupName string = 'SecGroupNet'

@description('List of security rules')
param securityRules avmtypes.securityRuleType[] = []

@description('Location')
param location string = resourceGroup().location

param nsgGroupPrefix string = avmtypes.nsgResourcePrefix

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

var nsgName = '${nsgGroupPrefix}-${networkSecurityGroupName}'

resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2023-04-01' = {
  name: nsgName
  location: location
  tags: tags
  properties: {
    securityRules: [for item in securityRules: {
      name: item.securityRuleName
      properties: {
        description: item.securityRuleDescription
        protocol: item.protocol
        sourcePortRange: item.sourcePortRange
        destinationPortRange: item.destinationPortRange
        sourceAddressPrefix: item.sourceAddressPrefix
        destinationAddressPrefix: item.destinationAddressPrefix
        access: item.access
        priority: item.priority
        direction: item.direction
      }
    }]
  }
}


resource nsgLock 'Microsoft.Authorization/locks@2016-09-01' = if (!empty(lock ?? {}) && lock.?kind != 'None') { 
  name: lock.?name ?? 'lock-${nsgName}'
  properties: {
    level: lock.?kind ?? ''
    notes: lock.?kind == 'CanNotDelete' ? 'Cannot delete resource or child resources.' : 'Cannot delete or modify the resource or child resources.'
  }
  scope: networkSecurityGroup
}

resource nsgRoleAssignments 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = [for (roleAssignment, index) in (roleAssignments ?? []): {
  name: guid(networkSecurityGroup.id, roleAssignment.principalId, roleAssignment.roleDefinitionIdOrName)
  properties: {
    roleDefinitionId: contains(avmtypes.builtInRoleNames, roleAssignment.roleDefinitionIdOrName) ? avmtypes.builtInRoleNames[roleAssignment.roleDefinitionIdOrName] : roleAssignment.roleDefinitionIdOrName
    principalId: roleAssignment.principalId
    description: roleAssignment.?description
    principalType: roleAssignment.?principalType
    condition: roleAssignment.?condition
    conditionVersion: !empty(roleAssignment.?condition) ? (roleAssignment.?conditionVersion ?? '2.0') : null // Must only be set if condtion is set
    delegatedManagedIdentityResourceId: roleAssignment.?delegatedManagedIdentityResourceId
  }
  scope: networkSecurityGroup
}]

resource nsgDiagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = [for (diagnosticSetting, index) in (diagnosticSettings ?? []): {
  name: diagnosticSetting.?name ?? '${nsgName}-diagnosticSettings'
    properties: {
      
      storageAccountId: !empty(diagnosticSetting.?storageAccountId)? diagnosticSetting.storageAccountId : null
      eventHubAuthorizationRuleId: !empty(diagnosticSetting.?eventHubAuthorizationRuleId) ? diagnosticSetting.eventHubAuthorizationRuleId : null
      eventHubName: !empty(diagnosticSetting.?eventHubName) ? diagnosticSetting.eventHubName : null
      workspaceId: !empty(diagnosticSetting.?workspaceResourceId)? diagnosticSetting.workspaceResourceId : null
      metrics: !empty(diagnosticSetting.?metricCategories)? diagnosticSetting.metricCategories : []
      logs: !empty(diagnosticSetting.?logCategoriesAndGroups)? diagnosticSetting.logCategoriesAndGroups : []
      marketplacePartnerId: !empty(diagnosticSetting.?marketPlacePartnerResourceId)? diagnosticSetting.marketPlacePartnerResourceId : null
      logAnalyticsDestinationType: !empty(diagnosticSetting.?logAnalyticsDestinationType) ? diagnosticSetting.logAnalyticsDestinationType : null
    
    }
  scope: networkSecurityGroup
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

output resourceId string = networkSecurityGroup.id
