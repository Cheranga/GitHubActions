param functionAppName string
// param currentAppSettings object
// param appSettings object

param existingSettings object

// var existingArray = [for item in existingSettings.properties:{
//   name: item.name
//   value: item.value
// }]

resource functionAppResource 'Microsoft.Web/sites@2021-03-01' existing = {
  scope: resourceGroup()
  name: functionAppName
}

var additionalSettings = [
  {
    name: 'a'
    value: 'b'
  }
  {
    name: 'c'
    value: 'd'
  }  
]

// var combined = union(functionAppResource.properties.siteConfig.appSettings, [
//   {
//     name: 'a'
//     value: 'b'
//   }
//   {
//     name: 'c'
//     value: 'd'
//   }
// ])

var additionalSettingsObject = [for item in additionalSettings: {
  '${item.name}': item.value
}]

var settingsArray = [
  {
    name: 'HotelCancellationQueue'
    value: 'hotel-cancellations'
  }
  {
    name: 'QueueSource__queueServiceUri'
    value: 'https://sgccfunkyhotelsdev.queue.core.windows.net'
  }  
]

var objectArray = [for item in settingsArray:{
  '${item.name}': item.value
}]

resource settings 'Microsoft.Web/sites/config@2021-03-01' = [for item in objectArray:{
  name: '${functionAppName}/appsettings'
  properties:union(existingSettings, item)
}]


// resource settings 'Microsoft.Web/sites/config@2021-03-01' = {
//   name: '${functionAppName}/appsettings'
//   properties:union(existingSettings, {
//     a: 'b'
//     c: 'd'
//   })
// }

// resource aaa 'Microsoft.Web/sites/config@2021-03-01' = [for item in additionalSettingsObject:{
//   name: '${functionAppName}/appsettings'
//   properties: union(existingSettings, item)
// }]



// resource siteconfig 'Microsoft.Web/sites/config@2021-03-01' = [for item in union(functionAppResource.properties.siteConfig.appSettings, [
//   {
//     name: 'a'
//     value: 'b'
//   }
//   {
//     name: 'c'
//     value: 'd'
//   }
// ]):{
//   name: '${functionAppName}/appsettings'
//   properties:{
//     '${item.name}': item.value
//   }
// }]

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

