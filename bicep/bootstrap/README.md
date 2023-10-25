This folder contains bicep code for deploying 
- A Resource group
- Oracle VMs for deploying Data guard

Run with : 
az deployment sub create --name demo --location centralindia --template-file main.bicep --parameters main.bicepparam

Edit main.bicepparam with parameters relevant for deployment. 
Note: the Location in main.bicepparam must match the location provided above