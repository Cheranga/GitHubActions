param functionAppName string

@secure()
param appSettings string

var settings = json(appSettings).siteConfig

var items = [for item in settings.appSettings:{
  name: '${item.name}'
  value: '${item.value}'
}]

resource slotSpecificSettings 'Microsoft.Web/sites/config@2021-03-01' = {
  name: '${functionAppName}/Staging'
  properties:{
    siteConfig: {
      appSettings:items
    }
  }
}
