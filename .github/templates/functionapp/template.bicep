param envName string
param funcAppName string
param sgName string
param location string = resourceGroup().location
param storageSku string = 'Standard_LRS'
param storageSkuTier string = 'Standard'

var sanitizedFuncAppName = '${toLower(replace(funcAppName, '-', ''))}${envName}'
var sanitizedStorageName = '${toLower(replace(sgName, '-', ''))}${envName}'

// Storage Account
resource storageAccount 'Microsoft.Storage/storageAccounts@2021-02-01' = {
  name: 'sg${sanitizedStorageName}'
  location: location
  kind: 'StorageV2'
  sku: {
    name: storageSku
    tier: storageSkuTier
  }  
}

// Application Insights
resource appIns 'Microsoft.Insights/components@2020-02-02' = {
  name: 'ins-${sanitizedFuncAppName}-${envName}'
  location: location
  kind: 'web'
  properties:{
    Application_Type: 'web'
    Request_Source:'rest'
    Flow_Type:'Bluefield'
  }
}
