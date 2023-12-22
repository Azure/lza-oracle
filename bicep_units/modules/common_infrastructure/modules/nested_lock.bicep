
import * as avmtypes from '../common_types.bicep'

@description('Optional. The lock settings of the service.')
param lock avmtypes.lockType

@description('Required. The name of the Resource Group.')
param resourceGroupName string

resource resourceGroup_lock 'Microsoft.Authorization/locks@2020-05-01' = if (!empty(lock ?? {}) && lock.?kind != 'None') {
  name: lock.?name ?? 'lock-${resourceGroupName}'
  properties: {
    level: lock.?kind ?? ''
    notes: lock.?kind == 'CanNotDelete' ? 'Cannot delete resource or child resources.' : 'Cannot delete or modify the resource or child resources.'
  }
}
