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

@description('The name of the container image that this container app will use')
param containerImage string = ''

@description('The last deployment timestamp')
param lastDeployed string = utcNow('d')

var databaseName = 'TodoDB'
var containerName = 'todos'
var containerAppName = 'todo-api'
var memorySize = '1'
var cpuSize = '0.5'

var tags = {
  ApplicationName: 'TodoAppApi'
  Environment: 'Production'
  LastDeployed: lastDeployed
}

var envVariables = [
  {
    name: 'APPINSIGHTS_CONNECTION_STRING'
    value: appInsights.properties.ConnectionString
  }
  {
    name: 'COSMOS_DB_ENDPOINT'
    value: cosmos.properties.documentEndpoint
  }
  {
    name: 'DATABASE_NAME'
    value: database.name
  }
  {
    name: 'CONTAINER_NAME'
    value: container.name
  }
]
var healthProbes = [
  {
    type: 'liveness'
    httpGet: {
      path: '/healthz/liveness'
      port: 80
    }
    initialDelaySeconds: 15
    periodSeconds: 30
    failureThreshold: 3
    timeoutSeconds: 1
  }
]

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

resource database 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2022-11-15' existing = {
  name: databaseName
}

resource container 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2022-11-15' = {
  name: containerName
  parent: database
  properties: {
    resource: {
      id: containerName
      partitionKey: {
        paths: [
          '/id'
        ]
        kind: 'Hash'
      }
      indexingPolicy: {
        indexingMode: 'consistent'
        includedPaths: [
          {
            path: '/*'
          }
        ]
      }
    }
  }
}

module api '../../Todo.Infrastructure/modules/http-container-app.bicep' = {
  name: 'api'
  params: {
    acrPasswordSecret: keyVault.getSecret('acr-primary-password')
    acrServerName: containerRegistry.properties.loginServer
    acrUsername: keyVault.getSecret('acr-username')
    containerAppName: containerAppName
    containerEnvId: env.id
    containerImage: containerImage
    cpuCore: cpuSize
    isExternal: true
    memorySize: memorySize
    tags: tags
    location: location
    healthProbes: healthProbes
    envVariables: envVariables
  }
}

module sqlRole 'modules/cosmos-sql-role-assignment.bicep' = {
  name: 'sqlRoleAssignment'
  params: {
    cosmosDbAccountName: cosmos.name
    principalId: api.outputs.principalId
  }
}
