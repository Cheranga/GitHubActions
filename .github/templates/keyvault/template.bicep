param keyVaultName string = ''
param location string = resourceGroup().location
param readAccessPrincipalIdList string

var readAccessList = trim(readAccessPrincipalIdList) == ''? [
  ''
] : split(trim(readAccessPrincipalIdList), ',')

resource keyVault 'Microsoft.KeyVault/vaults@2021-10-01' = if (length(readAccessList) > 0) {
  name: keyVaultName
  location: location
  properties: {
    enabledForDeployment:true
    enabledForDiskEncryption:true
    enabledForTemplateDeployment:true
    sku: {
      family: 'A'
      name: 'standard'
    }     
    tenantId: subscription().tenantId
    
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
}
