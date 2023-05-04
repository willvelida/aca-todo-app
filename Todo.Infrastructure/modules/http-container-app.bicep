@description('The name given to this Container App')
param containerAppName string

@description('The location to deploy all our resources. Same location as resource group by default')
param location string = resourceGroup().location

@description('Specifies the Id of the container app environment that this container app will be deployed to')
param containerEnvId string

@description('The name of the container image that this container app will use')
param containerImage string

@description('The ACR server name')
param acrServerName string

@description('The ACR username')
@secure()
param acrUsername string

@description('The ACR password secret')
@secure()
param acrPasswordSecret string

@description('Is this app external')
param isExternal bool

@description('The environment variables for this container app')
param envVariables array = []

@description('The amount of CPU cores the container can use. Can be with a maximum of two decimals')
param cpuCore string

@description('The amount of memory (in gibibytes, GiB) allocated to the container app')
param memorySize string

@description('The probes to apply in this Container App')
param healthProbes array = []

@description('The tags to apply to this Container App')
param tags object

resource containerApp 'Microsoft.App/containerApps@2022-10-01' = {
  name: containerAppName
  location: location
  tags: tags
  properties: {
    managedEnvironmentId: containerEnvId
    configuration: {
      activeRevisionsMode: 'Multiple'
      ingress: {
        external: isExternal
        transport: 'http'
        allowInsecure: false
        targetPort: 80
        traffic: [
          {
            latestRevision: true
            weight: 100
          }
        ]
      }
      secrets: [
        {
          name: 'container-registry-password'
          value: acrPasswordSecret
        }
      ]
      registries: [
        {
          server: acrServerName
          username: acrUsername
          passwordSecretRef: 'container-registry-password'
        }
      ]
    }
    template: {
      containers: [
        {
          name: containerAppName
          image: containerImage
          env: envVariables
          probes: healthProbes
          resources: {
            cpu: json(cpuCore)
            memory: '${memorySize}Gi'
          }
        }
      ]
      scale: {
        minReplicas: 0
        maxReplicas: 5
        rules: [
          {
            name: 'http-scale-rule'
            http: {
              metadata: {
                concurrentRequests: '100'
              }
            }
          }
        ]
      }
    }
  }
  identity: {
    type: 'SystemAssigned'
  }
}

output fqdn string = containerApp.properties.configuration.ingress.fqdn
output principalId string = containerApp.identity.principalId
