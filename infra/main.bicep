@description('Name of the Azure region for all resources.')
param location string = resourceGroup().location

@description('Short environment name such as dev, test, or prod.')
@allowed([
  'dev'
  'test'
  'prod'
])
param environmentName string = 'dev'

@description('Prefix used to build resource names. Use lowercase alphanumeric only.')
@minLength(3)
@maxLength(12)
param namePrefix string

@description('SKU for Azure AI Search.')
@allowed([
  'basic'
  'standard'
  'standard2'
  'standard3'
])
param searchSku string = 'basic'

@description('SKU for the Azure Container Registry.')
@allowed([
  'Basic'
  'Standard'
  'Premium'
])
param acrSku string = 'Basic'

var uniqueSuffix = toLower(uniqueString(subscription().id, resourceGroup().id, namePrefix, environmentName))
var shortSuffix = substring(uniqueSuffix, 0, 6)
var storageName = substring(toLower('st${namePrefix}${environmentName}${uniqueSuffix}'), 0, 24)
var keyVaultName = 'kv-${namePrefix}-${shortSuffix}'
var searchName = 'srch-${namePrefix}-${environmentName}-${shortSuffix}'
var registryName = substring(toLower(replace('acr${namePrefix}${environmentName}${shortSuffix}', '-', '')), 0, 50)
var containerEnvName = 'cae-${namePrefix}-${environmentName}-${shortSuffix}'
var workspaceName = 'law-${namePrefix}-${environmentName}-${shortSuffix}'
var appInsightsName = 'appi-${namePrefix}-${environmentName}-${shortSuffix}'
var identityName = 'id-agentic-rag-${environmentName}'

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: workspaceName
  location: location
  properties: {
    retentionInDays: 30
    sku: {
      name: 'PerGB2018'
    }
  }
}

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsightsName
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalytics.id
  }
}

resource registry 'Microsoft.ContainerRegistry/registries@2023-07-01' = {
  name: registryName
  location: location
  sku: {
    name: acrSku
  }
  properties: {
    adminUserEnabled: false
    publicNetworkAccess: 'Enabled'
  }
}

resource storage 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: storageName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
    allowBlobPublicAccess: false
    minimumTlsVersion: 'TLS1_2'
    supportsHttpsTrafficOnly: true
  }
}

resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2023-05-01' = {
  parent: storage
  name: 'default'
}

resource documentsContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-05-01' = {
  parent: blobService
  name: 'documents'
  properties: {
    publicAccess: 'None'
  }
}

resource promptsContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-05-01' = {
  parent: blobService
  name: 'prompts'
  properties: {
    publicAccess: 'None'
  }
}

resource search 'Microsoft.Search/searchServices@2023-11-01' = {
  name: searchName
  location: location
  sku: {
    name: searchSku
  }
  properties: {
    publicNetworkAccess: 'enabled'
    hostingMode: 'default'
    semanticSearch: 'free'
    disableLocalAuth: false
    replicaCount: 1
    partitionCount: 1
  }
}

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: keyVaultName
  location: location
  properties: {
    tenantId: tenant().tenantId
    sku: {
      family: 'A'
      name: 'standard'
    }
    enableRbacAuthorization: true
    enabledForDeployment: false
    enabledForDiskEncryption: false
    enabledForTemplateDeployment: false
    publicNetworkAccess: 'Enabled'
    softDeleteRetentionInDays: 90
  }
}

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: identityName
  location: location
}

resource containerAppsEnvironment 'Microsoft.App/managedEnvironments@2024-03-01' = {
  name: containerEnvName
  location: location
  properties: {
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: logAnalytics.properties.customerId
        sharedKey: logAnalytics.listKeys().primarySharedKey
      }
    }
  }
}

output acrLoginServer string = registry.properties.loginServer
output storageAccountName string = storage.name
output documentsContainerName string = documentsContainer.name
output promptsContainerName string = promptsContainer.name
output keyVaultName string = keyVault.name
output searchServiceName string = search.name
output managedIdentityClientId string = managedIdentity.properties.clientId
output managedIdentityPrincipalId string = managedIdentity.properties.principalId
output managedEnvironmentId string = containerAppsEnvironment.id
output applicationInsightsConnectionString string = applicationInsights.properties.ConnectionString
