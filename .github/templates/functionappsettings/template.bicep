param functionAppName string

@secure()
param appSettings string

var settings = json(appSettings)

resource slotSpecificSettings 'Microsoft.Web/sites/config@2021-03-01' = {
  name: '${functionAppName}/Staging'
  properties:{
    siteConfig: settings.appSettings
  }
}
