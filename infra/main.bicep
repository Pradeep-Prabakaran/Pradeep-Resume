
@description('Environment name')
@allowed(['dev', 'stage', 'prod'])
param parenvironment string

@description('The name of the project')
param parprojectName string

@description('The name of the Static Web App')
param parstaticWebAppName string = '${parprojectName}-${parenvironment}-swa'

@description('Location for all resources')
param parlocation string = resourceGroup().location

@description('Repository URL for the Static Web App')
param parrepositoryUrl string

@description('Branch name for the repository')
param parrepositoryBranch string = 'main'

@description('GitHub or DevOps provider')
@allowed(['GitHub', 'DevOps'])
param parrepositoryProvider string = 'DevOps'

@description('The name of the Azure Front Door profile')
param parfrontDoorProfileName string = '${parprojectName}-${parenvironment}-fd'

@description('The name of the Cosmos DB account')
param parcosmosDbAccountName string = '${parprojectName}-${parenvironment}-cosmosdb'

@description('The name of the Cosmos DB Container account')
param parcosmosContainername string

@description('Custom domain name for the Front Door')
param parcustomDomainName string

@description('Object ID of the user who needs admin access')
param parobjectId string

// Module for User-Assigned Managed Identity
module moduserAssignedIdentity 'modules/user-assign-mg-identity.bicep' = {
  name: 'userAssignedIdentity-${parenvironment}'
  params: {
    paridentityName: '${parprojectName}-${parenvironment}-swa-identity'
    parlocation: parlocation
  }
}

// Create Key Vault with RBAC enabled
module modKeyVault 'modules/keyvault.bicep' = {
  name: 'keyVault-${parenvironment}'
  params: {
    parkvName: '${parprojectName}-${parenvironment}-kv'
    parlocation: parlocation
    parobjectId: parobjectId
    paruserAssignedIdentityPrincipalId: moduserAssignedIdentity.outputs.principalId
    parprojectName: parprojectName
    parenvironment: parenvironment
  }
}

module modcosmosDB 'modules/cosmosDB.bicep' = {
  name: 'cosmosDB-${parenvironment}'
  params: {
    parenvironment: parenvironment
    parprojectName: parprojectName
    parlocation: parlocation
    parcosmosDbAccountName: parcosmosDbAccountName
    parcosmosContainername: parcosmosContainername
  }
  dependsOn: [
    modKeyVault
    moduserAssignedIdentity
  ]
}

module modcosmosDBKeyVault 'modules/cosmosDB-secrets-store.bicep' = {
  name: 'cosmosDBKeyVault-${parenvironment}'
  params: {
    parcosmosDbAccountName: parcosmosDbAccountName
    parkeyVaultName: modKeyVault.outputs.keyVaultName
  }
  dependsOn: [
    modcosmosDB
  ]
}
module modstaticWebApp 'modules/static-web-app.bicep' = {
  name: 'staticWebApp-${parenvironment}'
  params: {
    parenvironment: parenvironment
    parprojectName: parprojectName
    parstaticWebAppName: parstaticWebAppName
    parlocation: parlocation
    parrepositoryUrl: parrepositoryUrl
    parrepositoryBranch: parrepositoryBranch
    parrepositoryProvider: parrepositoryProvider
    userAssignedIdentityId: moduserAssignedIdentity.outputs.identityId
  }
  dependsOn: [
    modcosmosDB
    modcosmosDBKeyVault
    modKeyVault
  ]
}

// Reference to the deployed static web app resource for use as parent
resource resstaticWebApp 'Microsoft.Web/staticSites@2022-09-01' existing = {
  name: parstaticWebAppName
}

// Configure Static Web App with Cosmos DB connection
resource resstaticWebAppConfig 'Microsoft.Web/staticSites/config@2023-01-01' = {
  parent: resstaticWebApp
  name: 'appsettings'  
  properties: {
    COSMOS_DB_KEY: '@Microsoft.KeyVault(VaultName=${modcosmosDBKeyVault};SecretName=CosmosDB-PrimaryKey)'
    COSMOS_DB_ENDPOINT: modcosmosDB.outputs.cosmosDbEndpoint
    COSMOS_DB_DATABASE_NAME: modcosmosDB.outputs.cosmosDatabaseName
    COSMOS_DB_CONTAINER_NAME: modcosmosDB.outputs.cosmosContainerName
  }
  dependsOn: [
    modstaticWebApp
  ]
}

module modfrontDoor 'modules/frontdoor.bicep' = {
  name: 'frontDoor-${parenvironment}'
  params: {
    parenvironment: parenvironment
    parprojectName: parprojectName
    parfrontDoorProfileName: parfrontDoorProfileName
    parstaticWebAppHostname: modstaticWebApp.outputs.staticWebAppHost
    parcustomDomainName: parcustomDomainName
  }
  dependsOn: [
    resstaticWebAppConfig
  ]
}


// Outputs
output staticWebAppUrl string = modstaticWebApp.outputs.staticWebAppurl
output cosmosDbEndpoint string = modcosmosDB.outputs.cosmosDbEndpoint
output frontDoorEndpointUrl string = modfrontDoor.outputs.frontDoorEndpointUrl
