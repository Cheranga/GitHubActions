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
var queue = 'https://${sanitizedStorageName}.queue.core.windows.net'
var timeZone = 'AUS Eastern Standard Time'

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

// Keyvault with secrets
resource keyVault 'Microsoft.KeyVault/vaults@2021-06-01-preview' = {
  name: 'kv-${sanitizedFuncAppName}'
  location: location
  properties: {
    enabledForDeployment: true
    enabledForTemplateDeployment: true
    enabledForDiskEncryption: true
    sku: {
      family: 'A'
      name: 'standard'
    }    
    tenantId: subscription().tenantId
    accessPolicies: [
      {
        tenantId: subscription().tenantId
        objectId: functionAppProductionSlot.identity.principalId
        permissions: {
          secrets: [
            'get'
            'list'
          ]
        }
      }
      {
        tenantId: subscription().tenantId
        objectId: functionAppStagingSlot.identity.principalId
        permissions: {
          secrets: [
            'get'
            'list'
          ]
        }
      }
    ]  
  }    
}


resource storageAccountConnectionStringSecret 'Microsoft.KeyVault/vaults/secrets@2021-06-01-preview'={
  name: '${keyVault.name}/storageAccountConnectionString'
  properties: {
    value:'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${listKeys(storageAccount.id, storageAccount.apiVersion).keys[0].value}'
  }  
}

resource appInsightsKeySecret 'Microsoft.KeyVault/vaults/secrets@2021-06-01-preview'={
  name: '${keyVault.name}/appInsightsKey'
  properties: {
    value:reference(appIns.id, appIns.apiVersion).InstrumentationKey
  }  
}

// Function app settings
resource productionSlotAppSettings 'Microsoft.Web/sites/config@2021-02-01' = {
  name: '${sanitizedFuncAppName}/appsettings'
  properties:{
    CustomerApiKey: 'This is the production setting'          
    FUNCTIONS_EXTENSION_VERSION: '~4'    
    FUNCTIONS_WORKER_RUNTIME: 'dotnet'    
  }
  dependsOn:[
    functionAppProductionSlot
  ]
}

resource stagingSlotAppSettings 'Microsoft.Web/sites/slots/config@2021-02-01'= {
  name: '${sanitizedFuncAppName}/Staging/appsettings'
  properties:{
    CustomerApiKey: 'This is the staging setting'  
    AzureWebJobsStorage__accountName: sgName
    HotelCancellationQueue: 'hotel-cancellations'
    QueueSource__queueServiceUri: queue
    WEBSITE_CONTENTAZUREFILECONNECTIONSTRING: '@Microsoft.KeyVault(SecretUri=https://${keyVault.name}.vault.azure.net/secrets/storageAccountConnectionString/)'
    WEBSITE_CONTENTSHARE: toLower(sanitizedFuncAppName)
    FUNCTIONS_EXTENSION_VERSION: '~4'
    APPINSIGHTS_INSTRUMENTATIONKEY: '@Microsoft.KeyVault(SecretUri=https://${keyVault.name}.vault.azure.net/secrets/appInsightsKey/)'
    FUNCTIONS_WORKER_RUNTIME: 'dotnet'
    WEBSITE_TIME_ZONE: timeZone
    WEBSITE_ADD_SITENAME_BINDINGS_IN_APPHOST_CONFIG: 1
  }
  dependsOn:[    
    functionAppStagingSlot    
  ]
}
