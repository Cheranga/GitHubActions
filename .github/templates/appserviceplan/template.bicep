@description('Application service plan name')
param name string

@allowed([
  'nonprod'
  'prod'
])
param planType string ='nonprod'

var sku = {
  nonprod: 'Y1'
  prod:'Y1'
}

var tier = {
  nonprod:'Dynamic'
  prod:'Dynamic'
}

param location string = resourceGroup().location

resource asp 'Microsoft.Web/serverfarms@2021-02-01' = {
  name: name
  location: location
  sku:{
    name:sku[planType]
    tier:tier[planType]
  }
}
