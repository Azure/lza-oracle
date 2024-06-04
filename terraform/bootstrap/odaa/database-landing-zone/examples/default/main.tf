resource "azurerm_resource_group" "this" {
  location = local.region
  name     = "rg-odaa-terraform"
  tags     = local.tags
}

resource "tls_private_key" "generated_ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "azapi_resource" "ssh_public_key" {
  type      = "Microsoft.Compute/sshPublicKeys@2023-09-01"
  name      = "${azurerm_resource_group.this.name}_key"
  location  = azurerm_resource_group.this.location
  parent_id = azurerm_resource_group.this.id
  body = jsonencode({
    properties = {
      publicKey = "${tls_private_key.generated_ssh_key.public_key_openssh}"
    }
  })
}

module "odaa_lz" {
  source = "../../"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  resource_group_id = azurerm_resource_group.this.id
  sshPublicKeys = [ tls_private_key.generated_ssh_key.public_key_openssh ]
  deploy_odaa_infra = var.deploy_odaa_infra
  deploy_odaa_cluster = var.deploy_odaa_cluster
}
