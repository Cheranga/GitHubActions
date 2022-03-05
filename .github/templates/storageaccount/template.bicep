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
  nonprod:'Standard_LRS'
  prod: 'Standard_GRS'
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
  resource blobService 'blobServices' = if (!empty(containerArray)) {
    name:'default'    
    resource blob 'containers' = [for container in containerArray:{
      name: trim(container)
    }]
  }
}


// resource queueServices 'Microsoft.Storage/storageAccounts/queueServices@2021-08-01' = if(!empty(queues)){
//   name:'default'  
//   parent:stg
// }

// resource queue 'Microsoft.Storage/storageAccounts/queueServices/queues@2021-08-01' = if(!empty(queues)) = [for q in queues: {

// }]

