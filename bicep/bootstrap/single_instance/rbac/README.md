Deployment steps:

- Create a Service principal or managed identity

- Add Role definitions for selected resources - with the Principal ID of the service principal created

- Deploy the Data guard template with diagnostics settings enabled .

```powershell
az deployment sub create --name demo --location centralindia --template-file main.bicep --parameters single_instance/diagnostics/single_instance.bicepparam
```