param storageAccountName string
param friendlyName string

@allowed([
  'queue_read_write'
])
param accessibility string

@secure()
param servicePrincipalId string

var roleDefinitions = {
  queue_read_write: '974c5e8b-45b9-4653-ba55-5f855dd0fb88' //  storage queue data contributor
}

resource role 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = {
  scope: subscription()
  name: roleDefinitions[accessibility]
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-02-01' existing = {
  scope: resourceGroup()  
  name: storageAccountName
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(resourceGroup().id, friendlyName, role.id)  
  scope:storageAccount
  properties: {
    roleDefinitionId: role.id
    principalId: servicePrincipalId
    principalType: 'ServicePrincipal'
  }  
}

