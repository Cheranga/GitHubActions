param name string
param location string = resourceGroup().location

@allowed([
  'nonprod'
  'prod'
])
param storageType string = 'nonprod'

var storageSku = {
  nonprod:'Standard_LRS'
  prod: 'Standard_GRS'
}

var storageTier = {
  nonprod: 'Standard'
  prod: 'Premium'
}

resource stg 'Microsoft.Storage/storageAccounts@2021-02-01' = {
  name: name  
  location: location
  kind: 'StorageV2'
  sku: {
    name: storageSku[storageType]
    tier: storageTier[storageType]
  }
}

resource queue 'Microsoft.Storage/storageAccounts/queueServices@2021-08-01' = {
  name: '${name}/aaa'  
}
