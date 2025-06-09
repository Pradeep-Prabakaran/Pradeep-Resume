
@description('The name of the Key Vault')
param parkeyVaultName string

@description('Cosmos DB account name')
param parcosmosDbAccountName string


// Reference existing Key Vault
resource reskeyVault 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: parkeyVaultName
}

// Reference existing Cosmos DB account
resource rescosmosDbAccount 'Microsoft.DocumentDB/databaseAccounts@2023-04-15' existing = {
  name: parcosmosDbAccountName
}


// Store Cosmos DB primary key in Key Vault
resource rescosmosPrimaryKeySecret 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  parent: reskeyVault
  name: 'CosmosDB-PrimaryKey'
  properties: {
    value: rescosmosDbAccount.listKeys().primaryMasterKey
    attributes: {
      enabled: true
    }
  }
}


// Outputs
output cosmosPrimaryKeySecretUri string = rescosmosPrimaryKeySecret.properties.secretUri
