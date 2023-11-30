using '../../main.bicep'
import * as avmtypes from '../../../../bicep_units/modules/common_infrastructure/common_types.bicep'

param resourceGroupName = 'oraGroup1'

param location  = 'centralindia'

param virtualNetworks  = [
  {
    virtualNetworkName: 'vnet1'
    addressPrefixes: [
      '10.0.0.0/16']
    roleAssignments: [
      {
        roleDefinitionIdOrName: 'Owner'
        principalId: '374d1a60-dea0-4573-a526-ff9d3569a60b'
        principalType: 'ServicePrincipal'      
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
      {
        securityRuleName: 'ssh'
        securityRuleDescription: 'Allow SSH inbound traffic'
        priority: 100
        direction: 'Inbound'
        access: 'Allow'
        protocol: 'Tcp'
        sourcePortRange: '*'
        destinationPortRange: '22'
        sourceAddressPrefix: '*'
        destinationAddressPrefix: '*'
      } 
    ]
  }
]

param publicIPAddresses = [
  {
    publicIPAddressName : 'pip01'
    roleAssignments: [
      {
        roleDefinitionIdOrName: 'Owner'
        principalId: '374d1a60-dea0-4573-a526-ff9d3569a60b'
        principalType: 'ServicePrincipal'      
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
    roleAssignments: [
      {
        roleDefinitionIdOrName: 'Owner'
        principalId: '374d1a60-dea0-4573-a526-ff9d3569a60b'
        principalType: 'ServicePrincipal'      
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
    adminUsername : 'oracle'
    sshPublicKey : 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC6H+chNty9QAhF1lU8LVy1VsuXVrzuYYMJRNGZL4jKXUHyTHyFbL9miaRlH1dDUZ5/cNWwfRwNSK8g4eNifxTpZDrf3EBvrPjJiA4jVO9/iN5Qwucjul6gnZDkHZ5UFzGYImZ3Qkr/XUTlXcXHmfCAWF/sSXura7uNUtdVw3bwZXJCu41OVGGsMn8ENjfKLztXBDoMCe5qtVfGSs0mEmK03+bOHg/2KErqprjriFi3hI5JNE4sK2vBTXyx1czOH8G3Qo7vGcdGYTUUTXkV9LYBizWU5qn5l0MoJ1ZrFAywP6VyE36VAGEjPyTPWLCtVI7lVAOoVNb8JokkZznFuf91'
    avZone : '1'
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
