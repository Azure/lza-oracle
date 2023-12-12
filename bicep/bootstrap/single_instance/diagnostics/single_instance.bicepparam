using '../../main.bicep'
import * as avmtypes from '../../../../bicep_units/modules/common_infrastructure/common_types.bicep'

param resourceGroupName = 'oraGroup1'

param location  = 'centralindia'

param dcrWorkspaceResourceId = '/subscriptions/<subscriptionId>/resourceGroups/<LAworkspaceResourceGroupName>/providers/Microsoft.OperationalInsights/workspaces/<workSpaceName>'

param virtualNetworks  = [
  {
    virtualNetworkName: 'vnet1'
    addressPrefixes: [
      '10.0.0.0/16']
    diagnosticSettings: [
      {
        workspaceResourceId: '/subscriptions/<subscriptionId>/resourceGroups/<LAworkspaceResourceGroupName>/providers/Microsoft.OperationalInsights/workspaces/<workSpaceName>'
        name: 'vnetdiag'
        metricCategories: [
          {
            category: 'AllMetrics'
            enabled: true
          }
        ]
        logCategoriesAndGroups: [
          {
            categoryGroup: 'allLogs'
            enabled: true
          }
        ]
        logAnalyticsDestinationType: 'Dedicated'
      }
    ]
  }
]

param vnetSubnets = [
  {
    virtualNetworkName : 'vnet1'
    subnetName: 'subnet1'
    addressPrefix: '10.0.0.0/24'
    networkSecurityGroupName : 'ora01nsg'
  }
]

param networkSecurityGroups = [
  {
    networkSecurityGroupName : 'ora01nsg'
    securityRules: [
    ]
    diagnosticSettings: [
      {
        workspaceResourceId: '/subscriptions/<subscriptionId>/resourceGroups/<LAworkspaceResourceGroupName>/providers/Microsoft.OperationalInsights/workspaces/<workSpaceName>'
        name: 'nsgdiag'
        logCategoriesAndGroups: [
          {
            categoryGroup: 'allLogs'
            enabled: true
          }
        ]
        logAnalyticsDestinationType: 'Dedicated'
      }
    ]
  }
]

param publicIPAddresses = [
  {
    publicIPAddressName : 'pip01'
    diagnosticSettings: [
      {
        workspaceResourceId: '/subscriptions/<subscriptionId>/resourceGroups/<LAworkspaceResourceGroupName>/providers/Microsoft.OperationalInsights/workspaces/<workSpaceName>'
        name: 'pipdiag'
        metricCategories: [
          {
            category: 'AllMetrics'
            enabled: true
          }
        ]
        logCategoriesAndGroups: [
          {
            categoryGroup: 'allLogs'
            enabled: true
          }
        ]
        logAnalyticsDestinationType: 'Dedicated'
      }
    ]
  }
]

param networkInterfaces = [
  {
    virtualNetworkName : 'vnet1'
    subnetName : 'subnet1'
    networkInterfaceName : 'ora01nic0'
    publicIPAddressName: 'pip01'
    diagnosticSettings: [
      {
        workspaceResourceId: '/subscriptions/<subscriptionId>/resourceGroups/<LAworkspaceResourceGroupName>/providers/Microsoft.OperationalInsights/workspaces/<workSpaceName>'
        name: 'nicdiag'
        metricCategories: [
          {
            category: 'AllMetrics'
            enabled: true
          }
        ]
        logAnalyticsDestinationType: 'Dedicated'
      }
    ]
  }
]

param dataDisks = [
  {
    diskName : 'ora01disk0'
    diskSizeGB : 256
    type : 'Premium_LRS'
    lun : 0
    virtualMachineName : 'ora01'
    avZone : '1'
  }
]

param virtualMachines = [
  {
    virtualMachineName : 'ora01'
    vmSize : 'Standard_D4s_v5'
    avZone : '1'
    adminUsername : 'oracle'
    sshPublicKey : ''
    diagnosticSettings: [
      {
        workspaceResourceId: '/subscriptions/<subscriptionId>/resourceGroups/<LAworkspaceResourceGroupName>/providers/Microsoft.OperationalInsights/workspaces/<workSpaceName>'
        name: 'vmdiag'
        metricCategories: [
          {
            category: 'AllMetrics'
            enabled: true
          }
        ] 
        logAnalyticsDestinationType : 'Dedicated'
        vmAgentConfiguration : {
          publisher : 'Microsoft.Azure.Monitor'
          type : 'AzureMonitorLinuxAgent' 
          autoUpgradeMinorVersion : true
          enableAutomaticUpgrade : true
        }
        enableVmGuestMonitoring : true
      }
    ]
  }
]

param tags = {
  environment: 'dev'
  costCenter: 'it'
}

param oracleImageReference = {
  publisher : 'oracle'
  offer : 'oracle-database-19-3'
  sku : 'oracle-database-19-0904'
  version: 'latest'
}
