param(
    [Parameter(Mandatory = $true)]
    [string]$SubscriptionId,

    [Parameter(Mandatory = $true)]
    [string]$ResourceGroupName,

    [Parameter(Mandatory = $false)]
    [string]$Location = 'centralindia',

    [Parameter(Mandatory = $false)]
    [string]$ParametersFile = 'infra/main.parameters.json'
)

$ErrorActionPreference = 'Stop'

Write-Host "Setting Azure subscription to $SubscriptionId" -ForegroundColor Cyan
az account set --subscription $SubscriptionId | Out-Null

Write-Host "Ensuring resource group $ResourceGroupName exists in $Location" -ForegroundColor Cyan
az group create --name $ResourceGroupName --location $Location | Out-Null

Write-Host "Validating Bicep template" -ForegroundColor Cyan
az deployment group validate `
    --resource-group $ResourceGroupName `
    --template-file infra/main.bicep `
    --parameters @$ParametersFile | Out-Null

Write-Host "Deploying baseline Azure resources" -ForegroundColor Cyan
az deployment group create `
    --resource-group $ResourceGroupName `
    --template-file infra/main.bicep `
    --parameters @$ParametersFile `
    --query properties.outputs
