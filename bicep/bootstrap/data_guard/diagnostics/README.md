Deployment steps:

- Create a Resource Group for the Log analytics workspace
az group create --resource-group laworkspacerg --location centralindia

- Create the log analytics workspace in the resource group
az deployment group create --resource-group laworkspacerg --template-file "data_guard/diagnostics/laworkspace.bicep"

This should generate an output with the Workspace ID:

```powershell
    "outputs": {
      "laworkspaceId": {
        "type": "String",
        "value": "/subscriptions/c5518e67-7743-4dff-adcf-0f3ddd3fe296/resourceGroups/laworkspacerg/providers/Microsoft.OperationalInsights/workspaces/laworkspace1"
      }
```

- Change the parameter workspaceID in the parameter file where diagnostics is required

- Deploy the Data guard template with diagnostics settings enabled .
az deployment sub create --name demo --location centralindia --template-file main.bicep --parameters data_guard/diagnostics/data_guard.bicepparam