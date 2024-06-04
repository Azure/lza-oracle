// OperationId: CloudExadataInfrastructures_CreateOrUpdate, CloudExadataInfrastructures_Get, CloudExadataInfrastructures_Delete
// PUT /subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/Oracle.Database/cloudExadataInfrastructures/{cloudexadatainfrastructurename}
resource "azapi_resource" "cloudExadataInfrastructure" {
  count     = var.deploy_odaa_infra ? 1 : 0
  type      = "Oracle.Database/cloudExadataInfrastructures@2023-09-01-preview"
  parent_id = var.resource_group_id
  name      = var.odaa_infra_name
  body = jsonencode({
    "location" : var.location,
    "zones" : var.zones,
    "tags" : var.tags,
    "properties" : {
      "computeCount" : var.computeCount,
      "displayName" : var.odaa_infra_displayName,
      "maintenanceWindow" : {
        "leadTimeInWeeks" : var.leadTimeInWeeks,
        "preference" : var.preference,
        "patchingMode" : var.patchingMode
      },
      "shape" : var.shape,
      "storageCount" : var.storageCount
    }
  })
  schema_validation_enabled = false
}

# ------------------------------- DB Server -----------------------------------------------

data "azapi_resource_list" "listDbServersByCloudExadataInfrastructure" {
  type                   = "Oracle.Database/cloudExadataInfrastructures/dbServers@2023-09-01-preview"
  parent_id              = azapi_resource.cloudExadataInfrastructure[0].id
  depends_on             = [azapi_resource.cloudExadataInfrastructure]
  response_export_values = ["*"]
}

# ------------------------------- Cluster -----------------------------------------------

//-------------VMCluster resources ------------
// OperationId: CloudVmClusters_CreateOrUpdate, CloudVmClusters_Get, CloudVmClusters_Delete
// PUT GET DELETE /subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/Oracle.Database/cloudVmClusters/{cloudvmclustername}
resource "azapi_resource" "cloudVmCluster" {
  count                     = var.deploy_odaa_cluster ? 1 : 0
  type                      = "Oracle.Database/cloudVmClusters@2023-09-01-preview"
  parent_id                 = var.resource_group_id
  name                      = var.odaa_cluster_name
  schema_validation_enabled = var.schema_validation_enabled
  depends_on                = [azapi_resource.cloudExadataInfrastructure]
  body = jsonencode({
    "properties" : {
      "dataStorageSizeInTbs" : var.dataStorageSizeInTbs,
      "dbNodeStorageSizeInGbs" : var.dbNodeStorageSizeInGbs,
      "memorySizeInGbs" : var.memorySizeInGbs,
      "timeZone" : var.timeZone,
      "hostname" : var.hostname,
      "domain" : var.domain,
      "cpuCoreCount" : var.cpuCoreCount,
      "ocpuCount" : var.ocpuCount,
      "clusterName" : var.odaa_cluster_name,
      "dataStoragePercentage" : var.dataStoragePercentage,
      "isLocalBackupEnabled" : var.isLocalBackupEnabled,
      "cloudExadataInfrastructureId" : (var.deploy_odaa_cluster && var.deploy_odaa_infra) ? var.deploy_odaa_infra ? resource.azapi_resource.cloudExadataInfrastructure[0].id : var.cloudExadataInfrastructureId : null,
      "isSparseDiskgroupEnabled" : var.isSparseDiskgroupEnabled,
      "sshPublicKeys" : var.sshPublicKeys,
      "nsgCidrs" : var.nsgCidrs,
      "licenseModel" : "LicenseIncluded",
      "scanListenerPortTcp" : var.scanListenerPortTcp,
      "scanListenerPortTcpSsl" : var.scanListenerPortTcpSsl,
      "vnetId" : data.azurerm_virtual_network.odaa_vnet.id,
      "giVersion" : var.giVersion,
      "subnetId" : data.azurerm_subnet.odaa_subnet.id,
      "backupSubnetCidr" : data.azurerm_subnet.odaa_subnet.address_prefixes[0],
      "dataCollectionOptions" : {
        "isDiagnosticsEventsEnabled" : var.isDiagnosticsEventsEnabled,
        "isHealthMonitoringEnabled" : var.isHealthMonitoringEnabled,
        "isIncidentLogsEnabled" : var.isIncidentLogsEnabled
      },
      "displayName" : var.odaa_cluster_displayName,
      "dbServers" : [
        "${jsondecode(data.azapi_resource_list.listDbServersByCloudExadataInfrastructure.output).value[0].properties.ocid}",
        "${jsondecode(data.azapi_resource_list.listDbServersByCloudExadataInfrastructure.output).value[1].properties.ocid}"
      ]
    },
    "location" : var.location
    }
  )
  response_export_values = ["properties.ocid"]
}

