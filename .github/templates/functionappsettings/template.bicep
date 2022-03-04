param functionAppName string
param location string

@secure()
param appSettings string

// var items = json(appSettings).items

// resource deploymentSlot 'Microsoft.Web/sites/slots@2021-01-15' = {
//   name: '${functionAppName}/Staging'
//   location: location
//   kind:'functionapp'  
//   properties: {    
//     siteConfig: {
//       appSettings: [for item in items: {
//         name: '${item.name}'
//         value: '${item.value}'
//       }]
//     }
//   }
// }

var sensitiveSettings = json(appSettings).sensitive
var nonSensitiveSettings = json(appSettings).nonsensitive

resource nonSensitiveSettingsInSlot 'Microsoft.Web/sites/slots@2021-01-15' = {
  name: '${functionAppName}/Staging'
  location: location
  kind:'functionapp'  
  properties: {    
    siteConfig: {
      appSettings: [for item in nonSensitiveSettings: {
        name: '${item.name}'
        value: '${item.value}'
      }]
    }
  }
}

resource sensitiveSettingsInSlot 'Microsoft.Web/sites/slots@2021-01-15' = {
  name: '${functionAppName}/Staging'
  location: location
  kind:'functionapp'  
  properties: {    
    siteConfig: {
      appSettings: [for item in sensitiveSettings: {
        name: '${item.name}'
        value: '@Microsoft.KeyVault(SecretUri=https://${item.kvName}.vault.azure.net/secrets/${item.secretName}/)'
      }]
    }
  }
  dependsOn:[
    nonSensitiveSettingsInSlot
  ]
}
