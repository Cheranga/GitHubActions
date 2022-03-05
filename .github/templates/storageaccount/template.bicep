param name string
param location string = resourceGroup().location
param queues string

var queueArray = split(queues, ',')

@allowed([
  'nonprod'
  'prod'
])
param storageType string = 'nonprod'

var storageSku = {
  nonprod:'Standard_LRS'
  prod: 'Standard_GRS'
}

var storageTier = {
  nonprod: 'Standard'
  prod: 'Premium'
}

resource stg 'Microsoft.Storage/storageAccounts@2021-02-01' = {
  name: name  
  location: location
  kind: 'StorageV2'
  sku: {
    name: storageSku[storageType]
  }  
  resource queueService 'queueServices' = if (!empty(queueArray)) {
    name:'default'    
    resource queue 'queues' = [for q in queueArray:{
      name: trim(q)
    }]
  }
}


// resource queueServices 'Microsoft.Storage/storageAccounts/queueServices@2021-08-01' = if(!empty(queues)){
//   name:'default'  
//   parent:stg
// }

// resource queue 'Microsoft.Storage/storageAccounts/queueServices/queues@2021-08-01' = if(!empty(queues)) = [for q in queues: {

// }]

