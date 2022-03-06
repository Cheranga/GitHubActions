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

// resource additionalAppSettings 'Microsoft.Web/sites@2021-03-01' = if (!empty(settings)) {  
//   name: functionAppName
//   location: location
//   kind:'functionapp'  
//   properties: {        
//     siteConfig: {
//       appSettings: [for item in settings: {
//         name: '${item.name}'
//         value: item.kvName == ''? item.value : '@Microsoft.KeyVault(SecretUri=https://${item.kvName}.vault.azure.net/secrets/${item.secretName}/)'
//       }]
//     }
//   }
// }

module mergeAppSettings 'appsettings.bicep' = {
  name: '${functionAppName}-merge-settings'
  params: {    
    existingSettings: list('${functionAppResource.id}/config/appsettings','2020-12-01').properties
    // currentAppSettings: [for item in functionAppResource.properties.siteConfig.appSettings:{
    //   name: item.name
    //   value: item.value
    //     }]
    functionAppName: functionAppName
  }
}
