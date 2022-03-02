param sgName string
param sku string
param tier string = 'Standard'
param location string = resourceGroup().location

var storageKind = 'StorageV2'

resource stg 'Microsoft.Storage/storageAccounts@2021-02-01' = {
  name: sgName
  location: location
  kind: storageKind
  sku: {
    name: sku
    tier: tier    
  }
}


output storageAccountConnectionString string = 'DefaultEndpointsProtocol=https;AccountName=${stg.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${listKeys(stg.id, stg.apiVersion).keys[0].value}'
output subsResourceId string = resourceId('Microsoft.Storage/storageAccounts',sgName)

