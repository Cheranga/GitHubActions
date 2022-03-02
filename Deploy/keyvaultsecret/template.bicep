param keyVaultName string = ''
param secretName string = ''
@secure()
param secretValue string


resource keyVaultSecret 'Microsoft.KeyVault/vaults/secrets@2021-06-01-preview'={
  name: '${keyVaultName}/${secretName}'
  properties: {
    value:secretValue
  }
}
