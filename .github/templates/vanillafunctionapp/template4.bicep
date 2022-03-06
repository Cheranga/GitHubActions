param envName string
param funcAppName string
param sgName string
param location string = resourceGroup().location

@allowed([
  'nonprod'
  'prod'
])
param category string = 'nonprod'

var storageSku = {
  nonprod: 'Standard_LRS'
  prod: 'Standard_GRS'
}

var planSku = {
  nonprod: 'Y1'
  prod: 'Y1'
}

var planTier = {
  nonprod: 'Dynamic'
  prod: 'Dynamic'
}

var sanitizedFuncAppName = '${toLower(replace(funcAppName, '-', ''))}${envName}'
var sanitizedStorageName = '${toLower(replace(sgName, '-', ''))}${envName}'
var kvName = 'kv-${sanitizedFuncAppName}'
var timeZone = 'AUS Eastern Standard Time'

// Storage Account
resource storageAccount 'Microsoft.Storage/storageAccounts@2021-02-01' = {
  name: 'sg${sanitizedStorageName}'
  location: location
  kind: 'StorageV2'
  sku: {
    name: storageSku[category]
  }
}

// Application Insights
resource appIns 'Microsoft.Insights/components@2020-02-02' = {
  name: 'ins-${sanitizedFuncAppName}-${envName}'
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    Request_Source: 'rest'
    Flow_Type: 'Bluefield'
  }
}

// App Service Plan
resource asp 'Microsoft.Web/serverfarms@2021-02-01' = {
  name: 'plan-${sanitizedFuncAppName}'
  location: location
  sku: {
    name: planSku[category]
    tier: planTier[category]
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
    siteConfig:{
      appSettings:[
        {
          name:'AzureWebJobsStorage__accountName'
          value:storageAccount.name
        }
        {
          name:'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value:'@Microsoft.KeyVault(SecretUri=https://${kvName}.vault.azure.net/secrets/storageAccountConnectionString/)'
        }
        {
          name:'WEBSITE_CONTENTSHARE'
          value:toLower(sanitizedFuncAppName)
        }
        {
          name:'FUNCTIONS_EXTENSION_VERSION'
          value:'~4'
        }
        {
          name:'APPINSIGHTS_INSTRUMENTATIONKEY'
          value:'@Microsoft.KeyVault(SecretUri=https://${kvName}.vault.azure.net/secrets/appInsightsKey/)'
        }
        {
          name:'FUNCTIONS_WORKER_RUNTIME'
          value:'dotnet'
        }
        {
          name:'WEBSITE_TIME_ZONE'
          value:timeZone
        }
        {
          name:'WEBSITE_ADD_SITENAME_BINDINGS_IN_APPHOST_CONFIG'
          value:'1'
        }
      ]
    }          
  } 
}

// Function app settings
resource productionSlotAppSettings 'Microsoft.Web/sites/config@2021-02-01' = {
  name: 'appsettings'
  parent: functionAppProductionSlot
  properties: {
    AzureWebJobsStorage__accountName: storageAccount.name
    WEBSITE_CONTENTAZUREFILECONNECTIONSTRING: '@Microsoft.KeyVault(SecretUri=https://${keyVault.name}.vault.azure.net/secrets/storageAccountConnectionString/)'
    WEBSITE_CONTENTSHARE: toLower(sanitizedFuncAppName)
    FUNCTIONS_EXTENSION_VERSION: '~4'
    APPINSIGHTS_INSTRUMENTATIONKEY: '@Microsoft.KeyVault(SecretUri=https://${keyVault.name}.vault.azure.net/secrets/appInsightsKey/)'
    FUNCTIONS_WORKER_RUNTIME: 'dotnet'
    WEBSITE_TIME_ZONE: timeZone
    WEBSITE_ADD_SITENAME_BINDINGS_IN_APPHOST_CONFIG: 1
  }
}

// Keyvault with access policies to the function app
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
    ]
  }
}

// Keyvault secrets - storage account connection string
resource storageAccountConnectionStringSecret 'Microsoft.KeyVault/vaults/secrets@2021-06-01-preview' = {
  name: '${keyVault.name}/storageAccountConnectionString'
  properties: {
    value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${listKeys(storageAccount.id, storageAccount.apiVersion).keys[0].value}'
  }
}

// Keyvault secrets - app insights key
resource appInsightsKeySecret 'Microsoft.KeyVault/vaults/secrets@2021-06-01-preview' = {
  name: '${keyVault.name}/appInsightsKey'
  properties: {
    value: reference(appIns.id, appIns.apiVersion).InstrumentationKey
  }
}

// Getting the `Storage BLOB Data Owner` role in AAD
resource storageBlobDataOwnerDefinition 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = {
  scope: subscription()
  name: 'b7e6dc6d-f1e8-4753-8033-0f276bb0955b'
}

// Assigning the `Storage BLOB Data Owner` role to the function app
resource storageBlobDataOwnerProductionAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(resourceGroup().id, 'productionSlot', storageBlobDataOwnerDefinition.id)
  scope: storageAccount
  properties: {
    roleDefinitionId: storageBlobDataOwnerDefinition.id
    principalId: functionAppProductionSlot.identity.principalId
    principalType: 'ServicePrincipal'
  }
  // dependsOn:[
  //   storageAccount
  //   functionAppProductionSlot
  // ]
}
