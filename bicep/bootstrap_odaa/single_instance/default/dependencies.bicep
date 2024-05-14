
targetScope = 'subscription'

param resourceGroupName string = '<rgName>'
param location string = '<location>'
param tags object = {
  environment: 'dev'
}
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

module hubvnet 'br/public:avm/res/network/virtual-network:0.1.1' = {
  name: 'hubvnet'
  scope: resourceGroup(resourceGroupName)
  dependsOn: [rg]
  params: {
    name: 'hubvnet'
    subnets: [
      {
        name: 'default'
        addressPrefix: '10.1.0.0/24'
      }
    ]
    location: 'centralindia'
    addressPrefixes: ['10.1.0.0/16']
  }
}

module odainfra '../../../bootstrap_odaa/main.bicep' = {
  name: 'odainfra'
  dependsOn: [rg,hubvnet]
  params: {
    resourceGroupName: resourceGroupName
    location: 'centralindia'
    virtualNetworks: [
      {
        virtualNetworkName: 'odavnet'
        addressPrefixes: [
          '10.0.0.0/16' ]
        subnets: [
          {
            subnetName: 'client'
            addressPrefix: '10.0.0.0/24'
          }
          {
            subnetName: 'database'
            addressPrefix: '10.0.1.0/24'
            delegatedToOracleService: true
          }
       ]
       vnetPeerings : [
        {
          name: 'odavnet-peer'
          remoteVirtualNetworkId: hubvnet.outputs.resourceId
          allowForwardedTraffic: true
          allowGatewayTransit: true
          allowVirtualNetworkAccess: true
          useRemoteGateways: false
          remotePeeringAllowForwardedTraffic: true
          remotePeeringAllowVirtualNetworkAccess: true
          remotePeeringEnabled: true
          tags: tags
        }
       ]
      }
    ]
    routeTables:[
      {
        routeTableName: 'odavrt'
        routes: [
          {
            routeName: 'odavrt'
            addressPrefix: '0.0.0.0/0' 
            nextHopType: 'VirtualAppliance'
            nextHopIpAddress: '10.1.0.25'
          }
        ]
      }
    ]
  }
}
