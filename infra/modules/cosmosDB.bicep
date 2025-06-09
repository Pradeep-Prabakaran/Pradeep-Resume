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
resource rescosmosDbAccount 'Microsoft.DocumentDB/databaseAccounts@2023-04-15' = {
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
resource rescosmosDatabase 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2023-04-15' = {
  parent: rescosmosDbAccount
  name: '${parprojectName}-db'
  properties: {
    resource: {
      id: '${parprojectName}-db'
    }
  }
}

// Create Cosmos DB Container
resource rescosmosContainer 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2023-04-15' = {
  parent: rescosmosDatabase
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
output cosmosDbEndpoint string = rescosmosDbAccount.properties.documentEndpoint
output cosmosDbAccountName string = rescosmosDbAccount.name
output cosmosDatabaseName string = rescosmosDatabase.name
output cosmosContainerName string = rescosmosContainer.name
output cosmosDbId string = rescosmosDbAccount.id
output cosmosDatabaseId string = rescosmosDatabase.id
output cosmosContainerId string = rescosmosContainer.id
