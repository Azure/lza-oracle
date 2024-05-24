// This module creates the networking resources required for deploying ODA@Azure service.
//

targetScope = 'subscription'

@description('Name of the Resource Group')
param resourceGroupName string 

@description('Location')
param location string = 'eastus'

@description('Tags to be added to the resources')
param tags object = {}

@description('List of virtual networks')
param virtualNetworks array
 
@description('List of route tables')
param routeTables array = []

// Create a resource group
module rg 'br/public:avm/res/resources/resource-group:0.2.1' = {
  name: 'rg-${resourceGroupName}'
  scope: subscription()
  params: {
    name: resourceGroupName
    location: location
    enableTelemetry: false
    tags: tags
  }
}

// Create a list of virtual networks, based on parameter values.  This module also creates the subnets, virtual network peerings
// and associates the route tables with respective subnets.
// It also delegates specified subnets to ODA@Azure service
module networks 'br/public:avm/res/network/virtual-network:0.1.1' = [for (vnet, i) in virtualNetworks: {
  name: '${vnet.virtualNetworkName}${i}'
  dependsOn: [ rg, rtables]
  scope: resourceGroup(resourceGroupName)
  params: {
    name: vnet.virtualNetworkName
    subnets: [for (subnet, i) in vnet.?subnets:{
        name: subnet.subnetName
        addressPrefix: subnet.addressPrefix
        routeTableResourceId: !empty(rtables[0]) ? rtables[0].outputs.resourceId : ''
        delegations: contains(subnet,'delegatedToOracleService')?[{
          name: 'ODAatAzure'
          properties: {
            serviceName: 'Oracle.Database/networkAttachments' 
          }
        }]:[]
      }
    ]
    peerings: [for (peering,i) in !empty(vnet.?vnetPeerings)?vnet.vnetPeerings:{}: {
        remoteVirtualNetworkId: peering.remoteVirtualNetworkId
        allowVirtualNetworkAccess: peering.allowVirtualNetworkAccess
        allowForwardedTraffic: peering.allowForwardedTraffic
        allowGatewayTransit: peering.allowGatewayTransit
        useRemoteGateways: peering.useRemoteGateways
        remotePeeringAllowForwardedTraffic: peering.remotePeeringAllowForwardedTraffic
        remotePeeringAllowVirtualNetworkAccess: peering.remotePeeringAllowVirtualNetworkAccess
        remotePeeringEnabled: peering.remotePeeringEnabled
        location: location
        tags: tags
    }]
    location: location
    addressPrefixes: vnet.addressPrefixes
    enableTelemetry: false
    tags: tags
  }
}
]
 
//Create route tables if they are provided in the input
module rtables 'br/public:avm/res/network/route-table:0.1.0' = [for (rt, i) in routeTables: {
  name: '${rt.routeTableName}-${i}'
  dependsOn: [ rg]
  scope: resourceGroup(resourceGroupName)
  params: {
    name: rt.routeTableName
    location: location
    routes: [for (route, i) in rt.routes: {
      name: route.routeName
      properties: {
        addressPrefix: route.addressPrefix
        nextHopType: route.nextHopType
        nextHopIpAddress: route.nextHopIpAddress
      }
    }]
    tags: tags
  }
  }
]
