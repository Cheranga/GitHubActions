param functionAppName string
// param currentAppSettings object 
param appSettings object

resource functionAppResource 'Microsoft.Web/sites@2021-03-01' existing = {
  scope:resourceGroup()  
  name:functionAppName
}

resource siteconfig 'Microsoft.Web/sites/config@2021-03-01' = {
  name: '${functionAppName}/appsettings'
  properties: union(appSettings, functionAppResource.properties.siteConfig)
}
