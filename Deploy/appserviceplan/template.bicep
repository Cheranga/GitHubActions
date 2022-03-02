@description('Application service plan name')
param name string

@description('Application service plan SKU')
param sku string

@description('Application service plan tier')
param tier string

param location string = resourceGroup().location

resource asp 'Microsoft.Web/serverfarms@2021-02-01' = {
  name: name
  location: location
  sku:{
    name:sku
    tier:tier
  }
}

output planId string = asp.id
