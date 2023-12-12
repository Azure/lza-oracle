
param location string = resourceGroup().location

param workspaceResourceId string = ''

var logAnalyticsWorkspaceName  = last(split(workspaceResourceId, '/'))

module dataCollectionRule 'br/public:avm/res/insights/data-collection-rule:0.1.0' = {
  name: 'dcrmodule-idcrlin'
  params: {
    // Required parameters
    dataFlows: [
      {
        destinations: [
          'azureMonitorMetrics-default'
        ]
        streams: [
          'Microsoft-InsightsMetrics'
        ]
      }
      {
        destinations: [
          logAnalyticsWorkspaceName
        ]
        streams: [
          'Microsoft-Syslog'
        ]
      }
    ]
    dataSources: {
      performanceCounters: [
        {
          counterSpecifiers: [
            'Logical Disk(*)\\% Free Inodes'
            'Logical Disk(*)\\% Free Space'
            'Logical Disk(*)\\% Used Inodes'
            'Logical Disk(*)\\% Used Space'
            'Logical Disk(*)\\Disk Read Bytes/sec'
            'Logical Disk(*)\\Disk Reads/sec'
            'Logical Disk(*)\\Disk Transfers/sec'
            'Logical Disk(*)\\Disk Write Bytes/sec'
            'Logical Disk(*)\\Disk Writes/sec'
            'Logical Disk(*)\\Free Megabytes'
            'Logical Disk(*)\\Logical Disk Bytes/sec'
            'Memory(*)\\% Available Memory'
            'Memory(*)\\% Available Swap Space'
            'Memory(*)\\% Used Memory'
            'Memory(*)\\% Used Swap Space'
            'Memory(*)\\Available MBytes Memory'
            'Memory(*)\\Available MBytes Swap'
            'Memory(*)\\Page Reads/sec'
            'Memory(*)\\Page Writes/sec'
            'Memory(*)\\Pages/sec'
            'Memory(*)\\Used MBytes Swap Space'
            'Memory(*)\\Used Memory MBytes'
            'Network(*)\\Total Bytes'
            'Network(*)\\Total Bytes Received'
            'Network(*)\\Total Bytes Transmitted'
            'Network(*)\\Total Collisions'
            'Network(*)\\Total Packets Received'
            'Network(*)\\Total Packets Transmitted'
            'Network(*)\\Total Rx Errors'
            'Network(*)\\Total Tx Errors'
            'Processor(*)\\% DPC Time'
            'Processor(*)\\% Idle Time'
            'Processor(*)\\% Interrupt Time'
            'Processor(*)\\% IO Wait Time'
            'Processor(*)\\% Nice Time'
            'Processor(*)\\% Privileged Time'
            'Processor(*)\\% Processor Time'
            'Processor(*)\\% User Time'
          ]
          name: 'perfCounterDataSource60'
          samplingFrequencyInSeconds: 60
          streams: [
            'Microsoft-InsightsMetrics'
          ]
        }
      ]
      syslog: [
        {
          facilityNames: [
            'auth'
            'authpriv'
          ]
          logLevels: [
            'Alert'
            'Critical'
            'Debug'
            'Emergency'
            'Error'
            'Info'
            'Notice'
            'Warning'
          ]
          name: 'sysLogsDataSource-debugLevel'
          streams: [
            'Microsoft-Syslog'
          ]
        }
        {
          facilityNames: [
            'cron'
            'daemon'
            'kern'
            'local0'
            'mark'
          ]
          logLevels: [
            'Alert'
            'Critical'
            'Emergency'
            'Error'
            'Warning'
          ]
          name: 'sysLogsDataSource-warningLevel'
          streams: [
            'Microsoft-Syslog'
          ]
        }
        {
          facilityNames: [
            'local1'
            'local2'
            'local3'
            'local4'
            'local5'
            'local6'
            'local7'
            'lpr'
            'mail'
            'news'
            'syslog'
          ]
          logLevels: [
            'Alert'
            'Critical'
            'Emergency'
            'Error'
          ]
          name: 'sysLogsDataSource-errLevel'
          streams: [
            'Microsoft-Syslog'
          ]
        }
      ]
    }
    destinations: {
      azureMonitorMetrics: {
        name: 'azureMonitorMetrics-default'
      }
      logAnalytics: [
        {
          name: logAnalyticsWorkspaceName
          workspaceResourceId: workspaceResourceId
        }
      ]
    }
    name: 'idcrlin001'
    // Non-required parameters
    description: 'Collecting Linux-specific performance counters and Linux Syslog'
    kind: 'Linux'
    location: location
    tags: {
      'hidden-title': 'Rule for collecting Oracle VM metrics, syslog'
      kind: 'Linux'
      resourceType: 'Data Collection Rules'
    }
  }
}

output dataCollectionRuleId string = dataCollectionRule.outputs.resourceId
