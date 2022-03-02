param keyVaultName string = ''
param location string = resourceGroup().location

resource keyVault 'Microsoft.KeyVault/vaults@2021-10-01' = {
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
  }
}
