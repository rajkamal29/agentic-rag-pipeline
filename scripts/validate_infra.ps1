$ErrorActionPreference = 'Stop'

Write-Host 'Building Bicep template locally' -ForegroundColor Cyan
az bicep build --file infra/main.bicep

Write-Host 'Template build completed successfully' -ForegroundColor Green
