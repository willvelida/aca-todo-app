@description('Specifies the name of the application insights workspace')
param appInsightsName string

@description('The location to deploy all our App Insights workspace.')
param location string

@description('The tags to apply to the app insights workspace')
param tags object

@description('The resource id of the Log Analytics workspace to connect this App Insights to.')
param logAnalyticsId string

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsightsName
  location: location
  tags: tags
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalyticsId
  }
}

