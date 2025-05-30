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

// Create Static Web App
resource resstaticWebApp 'Microsoft.Web/staticSites@2023-01-01' = {
  name: parstaticWebAppName
  location: parlocation
  sku: {
    name: 'Free'
    tier: 'Free'
  }
  properties: {
    provider: parrepositoryProvider
    repositoryUrl: parrepositoryUrl
    branch: parrepositoryBranch
    stagingEnvironmentPolicy: 'Enabled'
    buildProperties: {
      skipGithubActionWorkflowGeneration: true
    }
  }
}

//Outputs
output staticWebAppHost string = resstaticWebApp.properties.defaultHostname
output staticWebAppName string = resstaticWebApp.name
output staticWebAppurl string = 'https://${resstaticWebApp.properties.defaultHostname}'
output staticWebAppId string = resstaticWebApp.id
