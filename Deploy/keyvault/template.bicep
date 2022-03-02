param keyVaultName string = ''
param location string = resourceGroup().location
param readAccessPrincipalIdList string
param writeAccessPrincipalIdList string

var readAccessList = trim(readAccessPrincipalIdList) == ''? [
  ''
] : split(trim(readAccessPrincipalIdList), ',')

var writeAccessList = trim(writeAccessPrincipalIdList) == ''? [
  ''
] : split(trim(writeAccessPrincipalIdList), ',')

resource readAccessPolicies 'Microsoft.KeyVault/vaults/accessPolicies@2021-10-01' = if (length(readAccessList) > 0){  
  name: '${keyVaultName}/readAccess'
  properties: {
    accessPolicies: [for sp in readAccessList:{
      objectId:sp
      tenantId:subscription().tenantId
      permissions:{
        secrets:[
          'get'
          'list'
        ]
      }
    }]
  }
  dependsOn:[
    keyVault
  ]
}

resource writeAccessPolicies 'Microsoft.KeyVault/vaults/accessPolicies@2021-10-01' = if (length(writeAccessList) > 0){  
  name: '${keyVaultName}/writeAccess'
  properties: {
    accessPolicies: [for sp in writeAccessList:{
      objectId:sp
      tenantId:subscription().tenantId
      permissions:{
        secrets:[
          'set'
          'delete'          
        ]
      }
    }]
  }
  dependsOn:[
    keyVault
  ]
}

resource keyVault 'Microsoft.KeyVault/vaults@2021-10-01' = {
  name: keyVaultName
  location: location
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }    
    tenantId: subscription().tenantId
  }
}
