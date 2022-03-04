param keyVaultName string = ''
param location string = resourceGroup().location

@secure()
param secretData string

var secretDataItems = json(secretData).items

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
    accessPolicies:[]    
  }  
}

resource keyVaultSecret 'Microsoft.KeyVault/vaults/secrets@2021-06-01-preview'=[for item in secretDataItems:{
  name: '${keyVault.name}/${item.name}'
  properties: {
    value:'${item.value}'
  }  
}]
