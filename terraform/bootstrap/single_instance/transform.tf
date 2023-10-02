locals {
  infrastructure = {
    region = coalesce(var.location, try(var.infrastructure.region, ""))
    resource_group = {
      name = try(
        coalesce(
          var.resourcegroup_name,
          try(var.infrastructure.resource_group.name, "")
        ),
        ""
      )
      arm_id = try(
        coalesce(
          var.resourcegroup_arm_id,
          try(var.infrastructure.resource_group.arm_id, "")
        ),
        ""
      )
    }
    vnet = {
      name = try(
        coalesce(
          local.vnet_oracle_name,
          try(var.infrastructure.vnet.name, "")
        ),
        ""
      )
      arm_id = try(
        coalesce(
          var.vnet_arm_id,
          try(var.infrastructure.vnet.arm_id, "")
        ),
        ""
      )
    }
    subnet = {
      name = try(
        coalesce(
          local.database_subnet_name,
          try(var.infrastructure.subnet.name, "")
        ),
        ""
      )
      arm_id = try(
        coalesce(
          var.subnet_arm_id,
          try(var.infrastructure.subnet.arm_id, "")
        ),
        ""
      )
    }
    tags = try(
      coalesce(
        var.resourcegroup_tags,
        try(var.infrastructure.tags, {})
      ),
      {}
    )
  }
}
