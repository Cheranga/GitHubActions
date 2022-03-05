param name string
param location string = resourceGroup().location
param queues string
param blobContainers string

var queueArray = split(queues, ',')
var containerArray = split(blobContainers, ',')

@allowed([
  'nonprod'
  'prod'
])
param storageType string = 'nonprod'

var storageSku = {
  nonprod: 'Standard_LRS'
  prod: 'Standard_GRS'
}

resource stg 'Microsoft.Storage/storageAccounts@2021-02-01' = {
  name: name
  location: location
  kind: 'StorageV2'
  sku: {
    name: storageSku[storageType]
  }
}

// resource queueService 'Microsoft.Storage/storageAccounts/queueServices@2021-08-01' = if (!empty(queueArray)) {
//   name:'default'    
//   parent:stg
//   resource queue 'queues' = [for q in queueArray: {
//     name:q
//   }]
// }

resource queueService 'Microsoft.Storage/storageAccounts/queueServices@2021-08-01' = if (!empty(queueArray)) {
  name: '${name}/default'
  dependsOn: [
    stg
  ]
  resource aaa 'queues' = [for q in queueArray: {
    name: q
  }]
}

resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2021-08-01' = if (!empty(containerArray)) {
  name: '${name}/default'
  dependsOn: [
    stg
  ]
  resource aaa 'containers' = [for c in containerArray: {
    name: c
  }]
}

// resource queueServices 'Microsoft.Storage/storageAccounts/queueServices@2021-08-01' = if(!empty(queues)){
//   name:'default'  
//   parent:stg
// }

// resource queue 'Microsoft.Storage/storageAccounts/queueServices/queues@2021-08-01' = if(!empty(queues)) = [for q in queues: {

// }]
