locals {
  sid_auth_type        = try(var.database.authentication.type, "key")
  enable_auth_password = local.sid_auth_type == "password"
  enable_auth_key      = local.sid_auth_type == "key"

  enable_ultradisk = false
  tags             = {}





  ### Variables for creating NICs
  database_ips = (var.use_secondary_ips) ? (
    flatten(concat(local.database_primary_ips, local.database_secondary_ips))) : (
    local.database_primary_ips
  )


  //ToDo: data.azurerm_subnet.subnet_oracle ???
  database_primary_ips = [
    {
      name                          = "IPConfig1"
      subnet_id                     = var.db_subnet.id
      nic_ips                       = var.database_nic_ips
      private_ip_address_allocation = var.database.use_DHCP ? "Dynamic" : "Static"
      offset                        = 0
      primary                       = true
    }
  ]

  database_secondary_ips = [
    {
      name                          = "IPConfig2"
      subnet_id                     = var.db_subnet.id
      nic_ips                       = var.database_nic_secondary_ips
      private_ip_address_allocation = var.database.use_DHCP ? "Dynamic" : "Static"
      offset                        = var.database_server_count
      primary                       = false
    }
  ]

  // Subnet IP Offsets
  // Note: First 4 IP addresses in a subnet are reserved by Azure
  oracle_ip_offsets = {
    oracle_vm = 3
  }

  # ip_configuration_list = [for ipconfig in database_ips : {
  #     name                          = ipconfig.name
  #     subnet_id                     = ipconfig.subnet_id
  #     private_ip_address_allocation = ipconfig.private_ip_address_allocation

  #     public_ip_address_id          = ipconfig.primary ? azurerm_public_ip.public_ip_oracle[0].id : null
  #     primary                       = ipconfig.primary

  #     private_ip_address = try(ipconfig.nic_ips[0],
  #         var.database.use_DHCP ? (
  #           null) : (
  #           cidrhost(
  #             var.db_subnet.address_prefixes[0],
  #             oracle_ip_offsets + ipconfig.offset
  #           )
  #         )
  #       )
  #   }]


  vm_default_config_data = {
    var.vm_name = {
      name                               = var.vm_name
      os_type                            = "Linux"
      generate_admin_password_or_ssh_key = false
      enable_auth_password               = !local.enable_auth_password
      admin_username                     = var.sid_username
      admin_ssh_keys                     = var.public_key
      source_image_reference = var.vm_source_image_reference
      virtualmachine_sku_size = var.vm_sku
      os_disk = var.vm_os_disk
      availability_zone = var.availability_zone
      enable_telemetry = var.enable_telemetry

    }
  }

##Aun falta considerar el escenario de DataGuard! hay una variable "is_data_guard" que se tiene que considerar




  # Variable with the data to create the Oracle VM
  vm_config_data_parameter = coalesce(var.vm_config_data, local.vm_default_config_data)


}
