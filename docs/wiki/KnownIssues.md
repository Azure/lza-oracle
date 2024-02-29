# Known Issues

## JIT with Terraform

When using Terraform to deploy the infrastructure the deployment fails intermittently as it is unable to reference the VM that was just created. This is due to the "eventual consistency" of Azure resources. This is a known issue with Terraform and Azure and is not specific to this repository. The workaround is to re-run the Terraform deployment if that happens.
