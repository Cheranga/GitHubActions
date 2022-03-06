param functionAppName string

@secure()
param appSettings string

var settings = json(appSettings)

// Get the existing function app
resource functionAppResource 'Microsoft.Web/sites@2021-03-01' existing = {
  scope:resourceGroup()  
  name:functionAppName
}

module mergeAppSettings 'appsettings.bicep' = {
  name: '${functionAppName}-merge-settings'
  params: {    
    existingSettings: list('${functionAppResource.id}/config/appsettings','2020-12-01').properties
    additionalSettings: settings
    functionAppName: functionAppName
  }
}
