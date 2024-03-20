#########################################################################################
#                                                                                       #
#  Virtual Machine                                                                      #
#                                                                                       #
#########################################################################################

module "avm-res-compute-virtualmachine" {
  source  = "Azure/avm-res-compute-virtualmachine/azurerm"
  version = "0.4.0"
  # insert the 3 required variables here

  resource_group_name             = var.resource_group.name
  virtualmachine_os_type          = "Linux"
  name                            = "${var.vm_name}-${count.index}"
  location                        = var.resource_group.location
  virtualmachine_sku_size         = var.vm_sku
  zone                            = var.availability_zone #common_infrastructure.availability_zone = 1
  disable_password_authentication = !local.enable_auth_password
  admin_username                  = var.sid_username
  source_image_reference          = var.vm_source_image_reference
  availability_set_resource_id    = var.availability_zone == null ? data.azurerm_availability_set.oracle_vm[0].id : null
  tags                            = merge(local.tags, var.tags)


  vm_additional_capabilities = {
    ultra_ssd_enabled = local.enable_ultradisk
  }

  admin_ssh_keys = [{
    username   = var.sid_username
    public_key = var.public_key
  }]

  os_disk = {
    name                   = var.vm_os_disk.name
    caching                = var.vm_os_disk.caching
    storage_account_type   = var.vm_os_disk.storage_account_type
    disk_encryption_set_id = try(var.vm_os_disk.disk_encryption_set_id, null)
    disk_size_gb           = var.vm_os_disk.disk_size_gb
  }

  managed_identities = {
    system_assigned            = var.aad_system_assigned_identity
    user_assigned_resource_ids = [azurerm_user_assigned_identity.deployer[0].id]
  }

  #admin_credential_key_vault_resource_id
#     lifecycle {
#     ignore_changes = [
#       // Ignore changes to computername
#       tags,
#       computer_name
#     ]
#   }
}

data "azurerm_virtual_machine" "oracle_vm" {
  count               = 1
  name                = "${var.vm_name}-${count.index}"
  resource_group_name = var.resource_group.name

  depends_on = [azurerm_linux_virtual_machine.oracle_vm]
}

resource "azurerm_linux_virtual_machine" "oracle_vm" {
  #   source_image_reference {
  #     publisher = var.vm_source_image_reference.publisher
  #     offer     = var.vm_source_image_reference.offer
  #     sku       = var.vm_source_image_reference.sku
  #     version   = var.vm_source_image_reference.version
  #   }


  #   os_disk {
  #     name                   = var.vm_os_disk.name
  #     caching                = var.vm_os_disk.caching
  #     storage_account_type   = var.vm_os_disk.storage_account_type
  #     disk_encryption_set_id = try(var.vm_os_disk.disk_encryption_set_id, null)
  #     disk_size_gb           = var.vm_os_disk.disk_size_gb
  #   }

  network_interface_ids = [var.nic_id]



}


