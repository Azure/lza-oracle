#########################################################################################
#                                                                                       #
#  Virtual Machine                                                                      #
#                                                                                       #
#########################################################################################
resource "azurerm_linux_virtual_machine" "oracle_vm" {
  count               = var.database_server_count
  name                = "${var.vm_name}-${count.index}"
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name

  admin_username                  = var.sid_username
  disable_password_authentication = !local.enable_auth_password

  admin_ssh_key {
    username   = var.sid_username
    public_key = var.public_key
  }

  source_image_reference {
    publisher = "Oracle"
    offer     = "Oracle-Linux"
    sku       = "79-gen2"
    version   = "7.9.36"
  }

  os_disk {
    name                   = "osdisk"
    caching                = "ReadWrite"
    storage_account_type   = var.deployer.disk_type
    disk_encryption_set_id = try(var.options.disk_encryption_set_id, null)
    disk_size_gb           = 128
  }

  network_interface_ids = [var.nic_id]

  size = local.oracle_sku

  additional_capabilities {
    ultra_ssd_enabled = local.enable_ultradisk
  }

  identity {
    type         = var.aad_system_assigned_identity ? "SystemAssigned, UserAssigned" : "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.deployer.id]
  }

  tags = merge(local.tags, var.tags)

  lifecycle {
    ignore_changes = [
      // Ignore changes to computername
      tags,
      computer_name
    ]
  }
}

data "azurerm_virtual_machine" "oracle_vm" {
  count               = var.database_server_count
  name                = "${var.vm_name}-${count.index}"
  resource_group_name = var.resource_group.name

  depends_on = [azurerm_linux_virtual_machine.oracle_vm]
}
