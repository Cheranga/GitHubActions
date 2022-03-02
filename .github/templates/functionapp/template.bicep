param envName string
param funcAppName string
param sgName string
param location string = resourceGroup().location
param storageSku string = 'Standard_LRS'
param storageSkuTier string = 'Standard'
param planSku string
param planTier string

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

// App Service Plan
resource asp 'Microsoft.Web/serverfarms@2021-02-01' = {
  name: 'plan-${sanitizedFuncAppName}'
  location: location
  sku:{
    name:planSku
    tier:planTier
  }
}

// Function app without settings
resource functionAppProductionSlot 'Microsoft.Web/sites@2021-03-01' = {
  name: sanitizedFuncAppName
  location: location
  kind:'functionapp'
  identity:{
    type:'SystemAssigned'
  }    
  properties:{
    serverFarmId:asp.name            
  }  
}

resource functionAppStagingSlot 'Microsoft.Web/sites/slots@2021-03-01' = {
  name: '${functionAppProductionSlot.name}/Staging'
  location: location
  kind:'functionapp'
  identity:{
    type:'SystemAssigned'
  }  
  properties:{
    serverFarmId:asp.name
    siteConfig:{
      autoSwapSlotName:'Production'
    }         
  }  
}
