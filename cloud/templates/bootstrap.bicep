targetScope = 'subscription'

@minLength(1)
@maxLength(64)
@description('Name of the the environment which is used to generate a short unique hash used in all resources.')
param environmentName string = 'dev'

@minLength(1)
@description('Primary location for all resources')
param location string = 'uksouth'

@minLength(1)
@description('GitHub branch name to grant deployment identity access from.')
param branchName string = 'azure'

var abbrs = loadJsonContent('./abbreviations.json')
var resourceToken = toLower(uniqueString(subscription().id, environmentName, location))

// Role Assignment ID's
var ownerRoleId = '8e3af657-a8ff-443c-a75c-2fe8c4bcb635'
var userAccessAdministratorRoleId = '18d7d88d-d35e-4fb5-a5c3-7773c20a72d9'
var rbacAdministratorRoleId = 'f58310d9-a9f6-439a-9e8d-f62e7b41a168'

// Create a project resource group
var rgName = 'k8s-homelab-${environmentName}'
resource rg 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  name: '${abbrs.resourcesResourceGroups}${rgName}'
  location: location
}

// CI/CD deployment managed identity 
module deploymentIdentity 'br/public:avm/res/managed-identity/user-assigned-identity:0.5.0' = {
  name: 'deployment-identity'
  scope: rg
  params: {
    name: '${abbrs.managedIdentityUserAssignedIdentities}deployment-${resourceToken}'
    location: location
    federatedIdentityCredentials: [
      {
        name: 'github-actions'
        issuer: 'https://token.actions.githubusercontent.com'
        subject: 'repo:cturner8/k8s-homelab:ref:refs/heads/${branchName}'
        audiences: [
          'api://AzureADTokenExchange'
        ]
      }
    ]
  }
}

// Deployment storage account
module storage 'br/public:avm/res/storage/storage-account:0.31.1' = {
  scope: rg
  name: 'storage'
  params: {
    name: '${abbrs.storageStorageAccounts}deploy${resourceToken}'
    location: location
    allowBlobPublicAccess: false
    dnsEndpointType: 'Standard'
    publicNetworkAccess: 'Enabled'
    networkAcls: { defaultAction: 'Allow' }
    allowSharedKeyAccess: false
    isLocalUserEnabled: false
    defaultToOAuthAuthentication: true
    skuName: 'Standard_LRS'
    supportsHttpsTrafficOnly: true
    minimumTlsVersion: 'TLS1_2'
    blobServices: {
      containers: [
        {
          name: 'tfstate'
        }
      ]
    }
    lock: {
      kind: 'CanNotDelete'
    }
    roleAssignments: [
      {
        principalId: deploymentIdentity.outputs.principalId
        roleDefinitionIdOrName: 'Storage Blob Data Owner'
        principalType: 'ServicePrincipal'
      }
      {
        principalId: deployer().objectId
        roleDefinitionIdOrName: 'Storage Blob Data Owner'
      }
    ]
  }
}

// Grant the MI restricted RG access
var denyPrivilegedRoleDelegationCondition = '((!(ActionMatches{\'Microsoft.Authorization/roleAssignments/write\'})) OR (@Request[Microsoft.Authorization/roleAssignments:RoleDefinitionId] ForAnyOfAllValues:GuidNotEquals {${ownerRoleId}, ${rbacAdministratorRoleId}, ${userAccessAdministratorRoleId}})) AND ((!(ActionMatches{\'Microsoft.Authorization/roleAssignments/delete\'})) OR (@Resource[Microsoft.Authorization/roleAssignments:RoleDefinitionId] ForAnyOfAllValues:GuidNotEquals {${ownerRoleId}, ${rbacAdministratorRoleId}, ${userAccessAdministratorRoleId}}))'
module deploymentRoleAssignment 'br/public:avm/res/authorization/role-assignment/rg-scope:0.1.1' = {
  scope: rg
  params: { 
    principalId: deploymentIdentity.outputs.principalId
    roleDefinitionIdOrName: ownerRoleId
    principalType: 'ServicePrincipal'
    condition: denyPrivilegedRoleDelegationCondition
    conditionVersion: '2.0'
  }
}

// Outputs
output DEPLOYMENT_IDENTITY_CLIENT_ID string = deploymentIdentity.outputs.clientId
output DEPLOYMENT_IDENTITY_PRINCIPAL_ID string = deploymentIdentity.outputs.principalId
