@description('Specifies the name of the container registry.')
param containerRegistryName string

@description('The location to deploy all our container registry.')
param location string

@description('The tags to apply to the container registry')
param tags object

@description('Specifies the name of the key vault that will be used to store container registry secrets')
param keyVaultName string

var primaryPasswordSecret = 'acr-primary-password'
var secondaryPasswordSecret = 'acr-secondary-password'
var usernameSecret = 'acr-username'

resource keyVault 'Microsoft.KeyVault/vaults@2023-02-01' existing = {
  name: keyVaultName
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

resource acrPasswordSecret1 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  name: primaryPasswordSecret
  parent: keyVault
  properties: {
    value: containerRegistry.listCredentials().passwords[0].value
  }
}

resource acrPasswordSecret2 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  name: secondaryPasswordSecret
  parent: keyVault
  properties: {
    value: containerRegistry.listCredentials().passwords[1].value
  }
}

resource acrUsername 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  name: usernameSecret
  parent: keyVault
  properties: {
    value: containerRegistry.listCredentials().username
  }
}

output loginServer string = containerRegistry.properties.loginServer
output containerRegistryPrincipalId string = containerRegistry.identity.principalId
