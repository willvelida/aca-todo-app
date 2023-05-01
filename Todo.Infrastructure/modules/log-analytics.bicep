@description('Specifies the name of the log analytics workspace')
param logAnalyticsName string

@description('The location to deploy all our log analytics workspace')
param location string

@description('The tags to apply to the log analytics workspace')
param tags object

@description('Specifies the name of the key vault that will be used to store log analytics secrets')
param keyVaultName string

var sharedKeySecretName = 'log-analytics-shared-key'

resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: keyVaultName
}

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: logAnalyticsName
  location: location
  tags: tags
  properties: {
    retentionInDays: 30
    features: {
      searchVersion: 1
    }
    sku: {
      name: 'PerGB2018'
    }
  }
}

resource sharedKeySecret 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  name: sharedKeySecretName
  parent: keyVault
  properties: {
    value: logAnalytics.listKeys().primarySharedKey
  }
}

output logAnalyticsId string = logAnalytics.id
output customerId string = logAnalytics.properties.customerId
