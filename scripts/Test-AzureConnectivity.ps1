# Test-AzureConnectivity.ps1
# Verifies Azure authentication and basic connectivity
# Run after azure/login in a workflow
param()

$ErrorActionPreference = 'Stop'

Write-Host 'Testing Azure connectivity...'

# Ensure Az module is loaded
if (-not (Get-Module Az.Accounts)) {
    Import-Module Az.Accounts -ErrorAction Stop
}

$context = Get-AzContext
if (-not $context) {
    throw 'Not authenticated to Azure. Run azure/login step first.'
}

Write-Host "  Subscription: $($context.Subscription.Name) ($($context.Subscription.Id))"
Write-Host "  Tenant:       $($context.Tenant.Id)"
Write-Host "  Account:      $($context.Account.Id)"

# Basic connectivity: list resource groups (read-only, low impact)
$rgCount = (Get-AzResourceGroup -ErrorAction SilentlyContinue | Measure-Object).Count
Write-Host "  Resource groups visible: $rgCount"

Write-Host 'Azure connectivity test passed.' -ForegroundColor Green
