param functionAppName string
// param currentAppSettings object
// param appSettings object

param existingSettings array

var testSettings = {
  appSettings: [
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
  scope: resourceGroup()
  name: functionAppName
}

var test = {
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
}

// var test = {
//   a: 'a'
//   b: 'b'
//   c: 'c'
// }

var combined = union(existingSettings, test.siteConfig.appSettings)




resource siteconfig 'Microsoft.Web/sites/config@2021-03-01' = [for item in combined:{
  name: '${functionAppName}/appsettings'
  properties:{
    '${item.name}': item.value
  }
}]

// resource siteconfig 'Microsoft.Web/sites/config@2021-03-01' = {
//   name: '${functionAppName}/appsettings'
//   properties: [for item in combined:{
//     '${item.name}': ${item.value}
//   }]
// }


// resource testSite 'Microsoft.Web/sites@2021-03-01' = {
//   name: functionAppName
//   location: resourceGroup().location
//   properties:{
//     siteConfig:{
//       appSettings:[
//         {
//           name:'a'
//           value:'b'
//         }
//         {
//           name:'c'
//           value:'d'
//         }
//       ]
//     }
//   }
// }

