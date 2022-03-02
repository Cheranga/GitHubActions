param roleDefinitionId string = ''
param servicePrincipalId string = ''
param roleIdentifier string = ''

@allowed([
  'subscription'
  'resourcegroup'
])
param allowedScope string = 'subscription'

var scopeToUse = allowedScope == 'subscription'? subscription() : resourceGroup()

@description('This will be a built in Azure AAD role. See https://docs.microsoft.com/azure/role-based-access-control/built-in-roles#contributor')
resource roleDefinition 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = {
  scope:  subscription()
  name: roleDefinitionId
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(resourceGroup().id, roleIdentifier, roleDefinition.id)
  scope: scopeToUse
  properties: {
    roleDefinitionId: roleDefinition.id
    principalId: servicePrincipalId
    principalType: 'ServicePrincipal'
  }  
}
