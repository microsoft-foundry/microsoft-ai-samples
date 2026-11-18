// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

// Microsoft Foundry resource + project for the MAI multimodal product launch workshop.
// Deploy with infra/setup.sh, which also checks the region and writes ../.env.

targetScope = 'resourceGroup'

@description('Azure region. eastus supports every MAI model this workshop uses (image, voice, transcribe).')
param location string = resourceGroup().location

@description('Prefix for resource names.')
@maxLength(12)
param namePrefix string = 'mai-launch'

@description('Object ID of the user or service principal that runs the notebooks. Gets the Foundry User role.')
param principalId string

@allowed(['User', 'ServicePrincipal'])
param principalType string = 'User'

@description('Deploy the MAI image models. setup.sh turns this off if the region does not offer them.')
param deployImageModels bool = true

@description('Image model deployments. Capacity is requests per minute for these models.')
param imageModels array = [
  { name: 'MAI-Image-2.6', version: '2026-07-31', capacity: 5 }
  { name: 'MAI-Image-2.6-Flash', version: '2026-07-31', capacity: 5 }
]

var suffix = uniqueString(resourceGroup().id, namePrefix)
var accountName = toLower('${namePrefix}-${suffix}')
var projectName = 'product-launch'
var tags = { workshop: 'mai-multimodal-product-launch' }
// Built-in "Foundry User" role: data-plane access to models, speech and agents.
var foundryUserRoleId = '53ca6127-db72-4b80-b1b0-d745d6d5456d'

resource account 'Microsoft.CognitiveServices/accounts@2025-06-01' = {
  name: accountName
  location: location
  tags: tags
  kind: 'AIServices'
  sku: { name: 'S0' }
  identity: { type: 'SystemAssigned' }
  properties: {
    // The notebooks derive the speech endpoint from this subdomain.
    customSubDomainName: accountName
    allowProjectManagement: true
    publicNetworkAccess: 'Enabled'
    disableLocalAuth: true
  }
}

resource project 'Microsoft.CognitiveServices/accounts/projects@2025-06-01' = {
  parent: account
  name: projectName
  location: location
  tags: tags
  identity: { type: 'SystemAssigned' }
  properties: {
    displayName: 'MAI multimodal product launch'
    description: 'Workshop project for MAI image, voice and transcription models.'
  }
}

@batchSize(1)
resource deployments 'Microsoft.CognitiveServices/accounts/deployments@2025-06-01' = [
  for model in (deployImageModels ? imageModels : []): {
    parent: account
    name: model.name
    sku: { name: 'GlobalStandard', capacity: model.capacity }
    properties: {
      model: { format: 'Microsoft', name: model.name, version: model.version }
      versionUpgradeOption: 'OnceNewDefaultVersionAvailable'
    }
    dependsOn: [project]
  }
]

resource foundryUser 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: account
  name: guid(account.id, principalId, foundryUserRoleId)
  properties: {
    principalId: principalId
    principalType: principalType
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', foundryUserRoleId)
  }
}

output accountName string = account.name
output projectEndpoint string = 'https://${accountName}.services.ai.azure.com/api/projects/${projectName}'
output imageDeployments array = [for (model, i) in (deployImageModels ? imageModels : []): deployments[i].name]
