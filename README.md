# Oracle Deployment Automation - Single VM Version


## Overview

This repository describes how to create and install Oracle DB on an Azure VM in an automated fashion, through the use of "terraform" and "ansible".

A single Azure VM will be deployed in a VNET in your Azure subscription.

## Pre-requisities

1. An Azure subscription. If you don't have an Azure subscription, create a [free account](https://azure.microsoft.com/en-us/free/?ref=microsoft.com&utm_source=microsoft.com&utm_medium=docs&utm_campaign=visualstudio) before you begin.
2. A compute source running Ubuntu. This can either be a local computer or [an Azure VM](https://learn.microsoft.com/en-us/azure/virtual-machines/linux/quick-create-portal?tabs=ubuntu). 
3. [Terraform installed](https://developer.hashicorp.com/terraform/downloads) on the compute source.
4. [Ansible installed](https://docs.ansible.com/ansible/latest/installation_guide/installation_distros.html) on the compute source.
5. [Az CLI installed](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-linux?pivots=apt) on the compute source.

## Next Steps

1. [Clone this repo](docs/wiki/CLONE.md) onto the compute resource.
2. [Provision infrastructure on Azure](docs/wiki/TERRAFORM.md) via terraform.
3. [Review the infrastructure](docs/wiki/REVIEW_INFRA.md) provisioned on Azure.
4. [Install and configure Oracle DB](docs/wiki/ANSIBLE.md) via ansible.
5. [Test the final configuration](docs/wiki/TEST.md).


## Trademarks

This project may contain trademarks or logos for projects, products, or services. Authorized use of Microsoft 
trademarks or logos is subject to and must follow 
[Microsoft's Trademark & Brand Guidelines](https://www.microsoft.com/en-us/legal/intellectualproperty/trademarks/usage/general).
Use of Microsoft trademarks or logos in modified versions of this project must not cause confusion or imply Microsoft sponsorship.
Any use of third-party trademarks or logos are subject to those third-party's policies.
