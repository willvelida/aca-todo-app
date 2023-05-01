@description('The random suffix applied to all resources')
param appName string = uniqueString(resourceGroup().id)

@description('The location to deploy all our resources. Same location as resource group by default')
param location string = resourceGroup().location

@description('Specifies the name of the container app environment')
param containerAppEnvName string = 'env-${appName}'

@description('Specifies the name of the container registry.')
param containerRegistryName string = 'cr${appName}'

@description('Specifies the name of the log analytics workspace')
param logAnalyticsName string = 'law-${appName}'

@description('Specifies the name of the application insights workspace')
param appInsightsName string = 'appins-${appName}'

@description('Specifies the name of the Key Vault')
param keyVaultName string = 'kv-${appName}'

@description('The name of the Cosmos DB account that will be deployed')
param cosmosDbAccountName string = 'db-${appName}'

@description('The last deployment timestamp')
param lastDeployed string = utcNow('d')

var tags = {
  ApplicationName: 'TodoApp'
  Environment: 'Production'
  LastDeployed: lastDeployed
}

resource keyVault 'Microsoft.KeyVault/vaults@2023-02-01' = {
  name: keyVaultName
  location: location
  tags: tags
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: tenant().tenantId
    enabledForDeployment: true
    enabledForTemplateDeployment: true
    enableSoftDelete: false
    accessPolicies: []
  }
}

module containerRegistry 'modules/container-registry.bicep' = {
  name: 'acr'
  params: {
    containerRegistryName: containerRegistryName
    keyVaultName: keyVault.name
    location: location
    tags: tags
  }
}

module logAnalytics 'modules/log-analytics.bicep' = {
  name: 'law'
  params: {
    keyVaultName: keyVault.name 
    location: location
    logAnalyticsName: logAnalyticsName
    tags: tags
  }
}

module appInsights 'modules/app-insights.bicep' = {
  name: 'appins'
  params: {
    appInsightsName: appInsightsName 
    location: location
    logAnalyticsId: logAnalytics.outputs.logAnalyticsId
    tags: tags
  }
}

module env 'modules/container-app-environment.bicep' = {
  name: 'env'
  params: {
    containerAppEnvName: containerAppEnvName
    location: location
    logAnalyticsCustomerId: logAnalytics.outputs.customerId 
    logAnalyticsSharedKey: keyVault.getSecret('log-analytics-shared-key')
    tags: tags
  }
}

module cosmos 'modules/cosmos-db-account.bicep' = {
  name: 'cosmos'
  params: {
    cosmosDbAccountName: cosmosDbAccountName
    keyVaultName: keyVault.name
    location: location
    tags: tags
  }
}
