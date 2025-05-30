@description('Environment name')
@allowed(['dev', 'stage', 'prod'])
param parenvironment string

@description('The name of the project')
param parprojectName string

@description('Location for all resources')
param parlocation string = resourceGroup().location

@description('The name of the Cosmos DB account')
param parcosmosDbAccountName string = '${parprojectName}-${parenvironment}-cosmosdb'

@description('The name of the Cosmos DB Container account')
param parcosmosContainername string

// Create Cosmos DB Account
resource cosmosDbAccount 'Microsoft.DocumentDB/databaseAccounts@2023-04-15' = {
  name: parcosmosDbAccountName
  location: parlocation
  kind: 'GlobalDocumentDB'
  properties: {
    consistencyPolicy: {
      defaultConsistencyLevel: 'Session'
    }
    locations: [
      {
        locationName: parlocation
        failoverPriority: 0
        isZoneRedundant: false
      }
    ]
    databaseAccountOfferType: 'Standard'
    enableAutomaticFailover: false
    enableMultipleWriteLocations: false
    capabilities: [
      {
        name: 'EnableServerless'
      }
    ]
  }
}

// Create Cosmos DB Database
resource cosmosDatabase 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2023-04-15' = {
  parent: cosmosDbAccount
  name: '${parprojectName}-db'
  properties: {
    resource: {
      id: '${parprojectName}-db'
    }
  }
}

// Create Cosmos DB Container
resource cosmosContainer 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2023-04-15' = {
  parent: cosmosDatabase
  name: parcosmosContainername
  properties: {
    resource: {
      id: parcosmosContainername
      partitionKey: {
        paths: ['/id']
        kind: 'Hash'
      }
    }
  }
}

//Outputs
output cosmosDbEndpoint string = cosmosDbAccount.properties.documentEndpoint
output cosmosDbAccountName string = cosmosDbAccount.name
output cosmosDatabaseName string = cosmosDatabase.name
output cosmosContainerName string = cosmosContainer.name
output cosmosDbId string = cosmosDbAccount.id
output cosmosDatabaseId string = cosmosDatabase.id
output cosmosContainerId string = cosmosContainer.id
