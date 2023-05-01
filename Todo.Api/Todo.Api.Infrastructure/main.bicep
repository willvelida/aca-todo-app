@description('The random suffix applied to all resources')
param appName string = uniqueString(resourceGroup().id)

@description('The location to deploy all our resources. Same location as resource group by default')
param location string = resourceGroup().location

@description('Specifies the name of the container app environment')
param containerAppEnvName string = 'env-${appName}'

@description('Specifies the name of the container registry.')
param containerRegistryName string = 'cr${appName}'

@description('Specifies the name of the application insights workspace')
param appInsightsName string = 'appins-${appName}'

@description('Specifies the name of the Key Vault')
param keyVaultName string = 'kv-${appName}'

@description('The name of the Cosmos DB account that will be deployed')
param cosmosDbAccountName string = 'db-${appName}'

@description('The last deployment timestamp')
param lastDeployed string = utcNow('d')

var tags = {
  ApplicationName: 'TodoAppApi'
  Environment: 'Production'
  LastDeployed: lastDeployed
}

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2022-02-01-preview' existing = {
  name: containerRegistryName
}

resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: keyVaultName
}

resource env 'Microsoft.App/managedEnvironments@2022-03-01' existing = {
  name: containerAppEnvName
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' existing = {
  name: appInsightsName
}

resource cosmos 'Microsoft.DocumentDB/databaseAccounts@2023-03-01-preview' existing = {
  name: cosmosDbAccountName
}
