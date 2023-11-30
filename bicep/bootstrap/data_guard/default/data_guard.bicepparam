using '../../main.bicep'
import * as avmtypes from '../../../../bicep_units/modules/common_infrastructure/common_types.bicep'

param resourceGroupName = 'oraGroup1'

param location = 'centralindia'

param virtualNetworks = [
  {
    virtualNetworkName: 'vnet1'
    addressPrefixes: [
      '10.0.0.0/16' ]
  }
]

param vnetSubnets = [
  {
    virtualNetworkName: 'vnet1'
    subnetName: 'subnet1'
    addressPrefix: '10.0.0.0/24'
    networkSecurityGroupName: 'ora01nsg'
  }
]

param networkSecurityGroups = [
  {
    networkSecurityGroupName: 'ora01nsg'
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
    publicIPAddressName: '01'
  }
  {
    publicIPAddressName: '02'
  }
  {
    publicIPAddressName: '03'
  }
]

param networkInterfaces = [
  {
    virtualNetworkName: 'vnet1'
    subnetName: 'subnet1'
    networkInterfaceName: '01'
    publicIPAddressName: '01'
  }
  {
    virtualNetworkName: 'vnet1'
    subnetName: 'subnet1'
    networkInterfaceName: '02'
    publicIPAddressName: '02'
  }
  {
    virtualNetworkName: 'vnet1'
    subnetName: 'subnet1'
    networkInterfaceName: '03'
    publicIPAddressName: '03'
  }
]

param dataDisks = [
  {
    diskName: 'primary'
    diskSizeGB: 256
    type: 'Premium_LRS'
    lun: 0
    virtualMachineName: 'primary'
    avZone: '1'
  }
  {
    diskName: 'secondary'
    diskSizeGB: 256
    type: 'Premium_LRS'
    lun: 0
    virtualMachineName: 'secondary'
    avZone: '2'
  }
  {
    diskName: 'observer'
    diskSizeGB: 256
    type: 'Premium_LRS'
    lun: 0
    virtualMachineName: 'observer'
    avZone: '1'
  }
]

param virtualMachines = [
  {
    virtualMachineName: 'primary'
    vmSize: 'Standard_D4s_v5'
    adminUsername: 'oracle'
    sshPublicKey: 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC6H+chNty9QAhF1lU8LVy1VsuXVrzuYYMJRNGZL4jKXUHyTHyFbL9miaRlH1dDUZ5/cNWwfRwNSK8g4eNifxTpZDrf3EBvrPjJiA4jVO9/iN5Qwucjul6gnZDkHZ5UFzGYImZ3Qkr/XUTlXcXHmfCAWF/sSXura7uNUtdVw3bwZXJCu41OVGGsMn8ENjfKLztXBDoMCe5qtVfGSs0mEmK03+bOHg/2KErqprjriFi3hI5JNE4sK2vBTXyx1czOH8G3Qo7vGcdGYTUUTXkV9LYBizWU5qn5l0MoJ1ZrFAywP6VyE36VAGEjPyTPWLCtVI7lVAOoVNb8JokkZznFuf91'
    avZone: '1'
  }
  {
    virtualMachineName: 'secondary'
    vmSize: 'Standard_D4s_v5'
    adminUsername: 'oracle'
    sshPublicKey: 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC6H+chNty9QAhF1lU8LVy1VsuXVrzuYYMJRNGZL4jKXUHyTHyFbL9miaRlH1dDUZ5/cNWwfRwNSK8g4eNifxTpZDrf3EBvrPjJiA4jVO9/iN5Qwucjul6gnZDkHZ5UFzGYImZ3Qkr/XUTlXcXHmfCAWF/sSXura7uNUtdVw3bwZXJCu41OVGGsMn8ENjfKLztXBDoMCe5qtVfGSs0mEmK03+bOHg/2KErqprjriFi3hI5JNE4sK2vBTXyx1czOH8G3Qo7vGcdGYTUUTXkV9LYBizWU5qn5l0MoJ1ZrFAywP6VyE36VAGEjPyTPWLCtVI7lVAOoVNb8JokkZznFuf91'
    avZone: '2'
  }
  {
    virtualMachineName: 'observer'
    vmSize: 'Standard_D4s_v5'
    adminUsername: 'oracle'
    sshPublicKey: 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC6H+chNty9QAhF1lU8LVy1VsuXVrzuYYMJRNGZL4jKXUHyTHyFbL9miaRlH1dDUZ5/cNWwfRwNSK8g4eNifxTpZDrf3EBvrPjJiA4jVO9/iN5Qwucjul6gnZDkHZ5UFzGYImZ3Qkr/XUTlXcXHmfCAWF/sSXura7uNUtdVw3bwZXJCu41OVGGsMn8ENjfKLztXBDoMCe5qtVfGSs0mEmK03+bOHg/2KErqprjriFi3hI5JNE4sK2vBTXyx1czOH8G3Qo7vGcdGYTUUTXkV9LYBizWU5qn5l0MoJ1ZrFAywP6VyE36VAGEjPyTPWLCtVI7lVAOoVNb8JokkZznFuf91'
    avZone: '1'
  }
]

param tags = {
  environment: 'dev'
  costCenter: 'it'
}

param oracleImageReference = {
  publisher: 'oracle'
  offer: 'oracle-database-19-3'
  sku: 'oracle-database-19-0904'
  version: 'latest'
}
