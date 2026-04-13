param(
    [Parameter(Mandatory = $true)]
    [string]$Owner,

    [Parameter(Mandatory = $true)]
    [string]$Repo,

    [Parameter(Mandatory = $false)]
    [string]$Branch = 'main',

    [Parameter(Mandatory = $false)]
    [string[]]$RequiredChecks = @('quality', 'dependency-audit', 'codeql'),

    [switch]$Apply
)

$ErrorActionPreference = 'Stop'

$protectionBody = @{
    required_status_checks = @{
        strict = $true
        contexts = $RequiredChecks
    }
    enforce_admins = $true
    required_pull_request_reviews = @{
        dismiss_stale_reviews = $true
        require_code_owner_reviews = $true
        required_approving_review_count = 1
        require_last_push_approval = $true
    }
    restrictions = $null
    allow_force_pushes = $false
    allow_deletions = $false
    required_linear_history = $true
    block_creations = $false
    required_conversation_resolution = $true
    lock_branch = $false
    allow_fork_syncing = $true
}

$payload = $protectionBody | ConvertTo-Json -Depth 10
$endpoint = "repos/$Owner/$Repo/branches/$Branch/protection"

if (-not $Apply) {
    Write-Host 'Dry run mode (no changes applied).' -ForegroundColor Yellow
    Write-Host "Target endpoint: $endpoint" -ForegroundColor Cyan
    Write-Host 'Payload preview:' -ForegroundColor Cyan
    Write-Host $payload
    Write-Host ''
    Write-Host 'To apply branch protection, run:' -ForegroundColor Green
    Write-Host "./scripts/set_branch_protection.ps1 -Owner $Owner -Repo $Repo -Branch $Branch -Apply"
    exit 0
}

$payloadFile = Join-Path $env:TEMP "branch-protection-$Repo-$Branch.json"
Set-Content -Path $payloadFile -Value $payload -Encoding utf8

Write-Host "Applying branch protection to $Owner/$Repo ($Branch)" -ForegroundColor Cyan
$ghArgs = @(
    'api'
    '--method'
    'PUT'
    '-H'
    'Accept: application/vnd.github+json'
    '-H'
    'X-GitHub-Api-Version: 2022-11-28'
    $endpoint
    '--input'
    $payloadFile
)

& gh @ghArgs | Out-Null

Write-Host 'Branch protection has been applied.' -ForegroundColor Green
Remove-Item $payloadFile -ErrorAction SilentlyContinue
