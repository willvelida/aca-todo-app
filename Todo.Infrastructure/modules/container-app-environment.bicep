@description('Specifies the name of the container app environment')
param containerAppEnvName string

@description('The location to deploy all our container app environment')
param location string

@description('The Log Analytics Customer Id')
param logAnalyticsCustomerId string

@description('The Log Analytics Shared Key')
@secure()
param logAnalyticsSharedKey string

@description('Tags applied to the container app environment')
param tags object

resource env 'Microsoft.App/managedEnvironments@2022-10-01' = {
  name: containerAppEnvName
  location: location
  tags: tags
  properties: {
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: logAnalyticsCustomerId
        sharedKey: logAnalyticsSharedKey
      }
    }
  }
}
