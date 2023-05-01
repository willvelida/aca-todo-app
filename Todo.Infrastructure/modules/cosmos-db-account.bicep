@description('The name of the Cosmos DB account that will be deployed')
param cosmosDbAccountName string

@description('The location to deploy all our Cosmos DB account')
param location string

@description('The tags to apply to the Cosmos DB account')
param tags object

@description('Specifies the name of the key vault that will be used to store Cosmos DB secrets')
param keyVaultName string

var primaryConnectionStringSecretName = 'db-primary-connectionstring'
var secondaryConnectionStringSecretName = 'db-secondary-connectionstring'
var primaryMasterKeySecretName = 'db-primary-masterkey'
var primaryReadonlyKeySecretName = 'db-primary-readonly'
var secondaryMasterKeySecretName = 'db-secondary-masterkey'
var secondaryReadonlyKeySecretName = 'db-secondary-readonly'

resource keyVault 'Microsoft.KeyVault/vaults@2023-02-01' existing = {
  name: keyVaultName
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

resource primaryConnectionStringSecret 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  name: primaryConnectionStringSecretName
  parent: keyVault
  properties: {
    value: cosmos.listConnectionStrings().connectionStrings[0].connectionString
  }
}

resource secondaryConnectionStringSecret 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  name: secondaryConnectionStringSecretName
  parent: keyVault
  properties: {
    value: cosmos.listConnectionStrings().connectionStrings[1].connectionString
  }
}

resource primaryMasterKeySecret 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  name: primaryMasterKeySecretName
  parent: keyVault
  properties: {
    value: cosmos.listKeys().primaryMasterKey
  }
}

resource primaryReadonlySecret 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  name: primaryReadonlyKeySecretName
  parent: keyVault
  properties: {
    value: cosmos.listKeys().primaryReadonlyMasterKey
  }
}

resource secondaryMasterKeySecret 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  name: secondaryMasterKeySecretName
  parent: keyVault
  properties: {
    value: cosmos.listKeys().secondaryMasterKey
  }
}

resource secondaryReadonlySecret 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  name: secondaryReadonlyKeySecretName
  parent: keyVault
  properties: {
    value: cosmos.listKeys().secondaryReadonlyMasterKey
  }
}
