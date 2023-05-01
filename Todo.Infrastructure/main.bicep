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

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: logAnalyticsName
  location: location
  tags: tags
  properties: {
    sku: {
      name: 'PerGB2018'
    }
  }
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsightsName
  location: location
  tags: tags
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalytics.id
  }
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

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2022-12-01' = {
  name: containerRegistryName
  location: location
  tags: tags
  sku: {
    name: 'Basic'
  }
  properties: {
    adminUserEnabled: true
  }
  identity: {
    type: 'SystemAssigned'
  }
}

resource env 'Microsoft.App/managedEnvironments@2022-10-01' = {
  name: containerAppEnvName
  location: location
  tags: tags
  properties: {
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: logAnalytics.properties.customerId
        sharedKey: logAnalytics.listKeys().primarySharedKey
      }
    }
  }
}

resource cosmos 'Microsoft.DocumentDB/databaseAccounts@2022-11-15' = {
  name: cosmosDbAccountName
  kind: 'GlobalDocumentDB'
  location: location
  tags: tags
  properties: {
    databaseAccountOfferType: 'Standard'
    consistencyPolicy: {
      defaultConsistencyLevel: 'Session'
    }
    locations: [
      {
        locationName: location
        failoverPriority: 0
        isZoneRedundant: false
      }
    ]
    capabilities: [
      {
        name: 'EnableServerless'
      }
    ]
  }
  identity: {
    type: 'SystemAssigned' 
  }
}
