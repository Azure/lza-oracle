<!-- markdownlint-disable -->
## Telemetry Tracking Using Customer Usage Attribution (PID)
<!-- markdownlint-restore -->

Microsoft can identify the deployments of the Azure Resource Manager and Bicep templates with the deployed Azure resources. Microsoft can correlate these resources used to support the deployments. Microsoft collects this information to provide the best experiences with their products and to operate their business. The telemetry is collected through [customer usage attribution](https://docs.microsoft.com/azure/marketplace/azure-partner-customer-usage-attribution). The data is collected and governed by Microsoft's privacy policies, located at the [trust center](https://www.microsoft.com/trustcenter).

To disable this tracking, we have included a parameter called `parTelemetryOptOut` to the following Terraform files in this repo with a simple boolean flag. The default value `false` which **does not** disable the telemetry. If you would like to disable this tracking, then simply set this value to `true` and this module will not be included in deployments and **therefore disables** the telemetry tracking.

- ./terraform/bootstrap/data_guard/module.tf
- ./terraform/bootstrap/single_instance/module.tf

If you are happy with leaving telemetry tracking enabled, no changes are required.

In the module.tf file, you will see the following:

```terraform
fixme input from tf devs
```

The default value is `false`, but by changing the parameter value `true` and saving this file, when you deploy this module regardless of the deployment method the module deployment below will be ignored and therefore telemetry will not be tracked.

```terraform
fixme input from tf devs
```

## Module PID Value Mapping

The following are the unique ID's (also known as PIDs) used in each of the files:

| File Name                     | PID                                  |
| ------------------------------- | ------------------------------------ |
| ./terraform/bootstrap/data_guard/module.tf            | 5c1ac525-f51f-411b-a7ca-b82d06798166 |
| ./terraform/bootstrap/single_instance/module.tf | 725d2e48-c3bc-4564-8cf9-ba7b59c55bb4 |
