@description('Name of the user-assigned managed identity')
param paridentityName string

@description('Location for all resources')
param parlocation string = resourceGroup().location

// Create User-Assigned Managed Identity
resource resuserAssignedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: paridentityName
  location: parlocation
}

output identityId string = resuserAssignedIdentity.id
output principalId string = resuserAssignedIdentity.properties.principalId
output clientId string = resuserAssignedIdentity.properties.clientId
output identityName string = resuserAssignedIdentity.name
