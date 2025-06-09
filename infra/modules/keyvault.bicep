param parprojectName string

param parenvironment string

param parlocation string = resourceGroup().location

@description('The name of the Key Vault')
param parkvName string = '${parprojectName}-${parenvironment}-kv'

@description('Object ID of the user who needs admin access')
param parobjectId string

@description('Principal ID of the user-assigned managed identity')
param paruserAssignedIdentityPrincipalId string

resource reskeyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: parkvName
  location: parlocation
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    enableRbacAuthorization: true
    enabledForTemplateDeployment: true
    enableSoftDelete: true
    softDeleteRetentionInDays: 7
    enablePurgeProtection: true
    publicNetworkAccess: 'Enabled'
    networkAcls: {
      defaultAction: 'Allow'
      bypass: 'AzureServices'
    }
  }
}

// RBAC Role Assignment: Key Vault Administrator for deployment user
resource keyVaultAdminRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(reskeyVault.id, parobjectId, 'Key Vault Administrator')
  scope: reskeyVault
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '00482a5a-887f-4fb3-b363-3b7fe8e74483') // Key Vault Administrator
    principalId: parobjectId
    principalType: 'User'
  }
}

// RBAC Role Assignment: Key Vault Secrets User for managed identity
resource keyVaultSecretsUserRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(reskeyVault.id, paruserAssignedIdentityPrincipalId, 'Key Vault Secrets User')
  scope: reskeyVault
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '4633458b-17de-408a-b874-0445c86b69e6') // Key Vault Secrets User
    principalId: paruserAssignedIdentityPrincipalId
    principalType: 'ServicePrincipal'
  }
}

// Outputs
output keyVaultName string = reskeyVault.name
output keyVaultUri string = reskeyVault.properties.vaultUri
output keyVaultId string = reskeyVault.id
