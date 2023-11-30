This folder contains bicep code for deploying 
- A Resource group
- Oracle VMs for deploying Data guard

Deployment steps

- Change directory to ~/lza-oracle/bicep/bootstrap

For Single instance:
az deployment sub create --name demo --location centralindia --template-file main.bicep --parameters single_instance/default/single_instance.bicepparam

For Data Guard:
az deployment sub create --name demo --location centralindia --template-file main.bicep --parameters data_guard/default/data_guard.bicepparam