param functionAppName string
// param currentAppSettings object 
// param appSettings object

var testSettings = {
  appSettings:[
    {
      name: 'a'
      value: 'b'
    }
    {
      name: 'c'
      value: 'd'
    }
  ]
}

resource functionAppResource 'Microsoft.Web/sites@2021-03-01' existing = {
  scope:resourceGroup()  
  name:functionAppName
}

resource siteconfig 'Microsoft.Web/sites/config@2021-03-01' = {
  name: '${functionAppName}/appsettings'
  properties: union(functionAppResource.properties, {
    siteConfig:{
      appSettings:[
        {
          name: 'a'
          value: 'b'
        }
        {
          name: 'c'
          value: 'd'
        }
      ]
    }
  })
}
