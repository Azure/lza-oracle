@description('Location for the LA Workspace')
param location string = 'centralindia'

@description('Name of the LA Workspace')
param laWorkspaceName string = 'laworkspace1'

resource laworkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: laWorkspaceName  
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
  } 
}

output laworkspaceId string = laworkspace.id
