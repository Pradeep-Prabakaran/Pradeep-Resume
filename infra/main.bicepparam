using 'main.bicep'

@description('Environment name')
@allowed(['dev', 'stage', 'prod'])
param parenvironment = 'dev'

@description('The name of the project')
param parprojectName = 'myportfolio'

@description('The name of the Static Web App')
param parstaticWebAppName = '${parprojectName}-${parenvironment}-swa'

@description('Location for all resources')
param parlocation = 'east asia'

@description('Repository URL for the Static Web App')
param parrepositoryUrl = 'https://github.com/Pradeep-Prabakaran/Pradeep-Resume.git'

@description('Branch name for the repository')
param parrepositoryBranch = 'dev'

@description('GitHub or DevOps provider')
@allowed(['GitHub', 'DevOps'])
param parrepositoryProvider = 'DevOps'

@description('The name of the Azure Front Door profile')
param parfrontDoorProfileName = '${parprojectName}-${parenvironment}-fd'

@description('The name of the Cosmos DB account')
param parcosmosDbAccountName = '${parprojectName}-${parenvironment}-cosmosdb'

@description('The name of the Cosmos DB Container account')
param parcosmosContainername = 'visitorscounter'

@description('Custom domain name for the Front Door')
param parcustomDomainName = 'www.pradeepprabakaran.me'
