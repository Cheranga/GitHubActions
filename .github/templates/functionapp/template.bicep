param sgName string
param location string = resourceGroup().location
param storageSku string = 'Standard_LRS'
param storageSkuTier string = 'Standard'

var sanitizedStorageName = replace(trim(sgName), '-', '')

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-02-01' = {
  name: sanitizedStorageName
  location: location
  kind: 'StorageV2'
  sku: {
    name: storageSku
    tier: storageSkuTier
  }
}
