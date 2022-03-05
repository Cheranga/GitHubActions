param functionAppName string
param location string = resourceGroup().location

@secure()
param appSettings string

var settings = json(appSettings).settings

// Get the existing function app
resource functionAppResource 'Microsoft.Web/sites@2021-03-01' existing = {
  scope:resourceGroup()  
  name:functionAppName
}

resource additionalAppSettings 'Microsoft.Web/sites@2021-03-01' = if (!empty(settings)) {
  name: functionAppName
  location: location
  kind:'functionapp'  
  properties: {    
    siteConfig: {
      appSettings: [for item in settings: {
        name: '${item.name}'
        value: item.kvName == ''? item.value : '@Microsoft.KeyVault(SecretUri=https://${item.kvName}.vault.azure.net/secrets/${item.secretName}/)'
      }]
    }
  }
}

module mergeAppSettings 'appsettings.bicep' = {
  name: '${functionAppName}-merge-settings'
  params: {
    appSettings: additionalAppSettings.properties.siteConfig
    currentAppSettings: functionAppResource.properties
    functionAppName: functionAppName
  }
}
