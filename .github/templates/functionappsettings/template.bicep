param functionAppName string

@secure()
param appSettings string

var items = json(appSettings)

resource slotSpecificSettings 'Microsoft.Web/sites/slots/config@2021-02-01'= {
  name: '${functionAppName}/Staging/appsettings'
  properties:items
}
