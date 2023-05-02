@description('The name of the Cosmos DB account that we will use for SQL Role Assignments')
param cosmosDbAccountName string

@description('The Principal Id of the App that we will grant the role assignment to.')
param principalId string

var roleDefinitionId = guid('sql-role-definition-', principalId, cosmosDbAccount.id)
var roleAssignmentId = guid(roleDefinitionId, principalId, cosmosDbAccount.id)
var roleDefinitionName = 'Todo API Cosmos Role'
var dataActions = [
  'Microsoft.DocumentDB/databaseAccounts/readMetadata'
  'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/*'
  'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/items/*'
]

resource cosmosDbAccount 'Microsoft.DocumentDB/databaseAccounts@2021-11-15-preview' existing = {
  name: cosmosDbAccountName
}

resource sqlRoleDefinition 'Microsoft.DocumentDB/databaseAccounts/sqlRoleDefinitions@2021-11-15-preview' = {
  name: roleDefinitionId
  parent: cosmosDbAccount
  properties: {
    roleName: roleDefinitionName
    type: 'CustomRole'
    assignableScopes: [
      cosmosDbAccount.id
    ]
    permissions: [
      {
        dataActions: dataActions
      }
    ]
  }
}

resource sqlRoleAssignment 'Microsoft.DocumentDB/databaseAccounts/sqlRoleAssignments@2021-11-15-preview' = {
  name: roleAssignmentId
  parent: cosmosDbAccount
  properties: {
    roleDefinitionId: sqlRoleDefinition.id
    principalId: principalId
    scope: cosmosDbAccount.id
  }
}
