param functionAppName string
param location string

@secure()
param appSettings string

var items = json(appSettings).items

resource deploymentSlot 'Microsoft.Web/sites/slots@2021-01-15' = {
  name: '${functionAppName}/Staging'
  location: location
  kind:'functionapp'  
  properties: {    
    siteConfig: {
      appSettings: [for item in items: {
        name: '${item.name}'
        value: '${item.value}'
      }]
    }
  }
}
