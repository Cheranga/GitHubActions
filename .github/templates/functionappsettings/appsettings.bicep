param functionAppName string
param currentAppSettings object 
param appSettings object

resource siteconfig 'Microsoft.Web/sites/config@2021-03-01' = {
  name: '${functionAppName}/appsettings'
  properties: union(currentAppSettings, appSettings)  
}
