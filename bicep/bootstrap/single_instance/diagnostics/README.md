Deployment steps:

- If there is an Log analytics group that already exists in a landing zone, determine the workspace ID of that workspace. Alternatively, a new log analytics workspace can be created in a new resource group. The following commands create a resource group and Log analytics workspace

```powershell
az group create --resource-group laworkspacerg --location centralindia
```

```powershell
az deployment group create --resource-group laworkspacerg --template-file "single_instance/diagnostics/laworkspace.bicep"
```

This should generate an output with the Workspace ID:

```powershell
    "outputs": {
      "laworkspaceId": {
        "type": "String",
        "value": "/subscriptions/c5518e67-7743-4dff-adcf-0f3ddd3fe296/resourceGroups/laworkspacerg/providers/Microsoft.OperationalInsights/workspaces/laworkspace1"
      }
```

- Change the parameter workspaceID in the parameter file for the resources where diagnostics is required. Adding the dcrWorkspaceResourceId parameter also enables syslog and perf counter data collection from Oracle VMs, by creating a Data Collection rule and associating it with each VM.

- Deploy the Data guard template with diagnostics settings enabled .

```powershell
az deployment sub create --name demo --location centralindia --template-file main.bicep --parameters single_instance/diagnostics/single_instance.bicepparam
```