# Test-MsGraphConnectivity.ps1
# Verifies Microsoft Graph authentication and basic connectivity
# Run after Connect-MsGraphOIDC in a workflow
param()

$ErrorActionPreference = 'Stop'

Write-Host 'Testing Microsoft Graph connectivity...'

# Ensure Microsoft.Graph is loaded
if (-not (Get-Module Microsoft.Graph.Authentication)) {
    Import-Module Microsoft.Graph.Authentication -ErrorAction Stop
}

$context = Get-MgContext
if (-not $context) {
    throw 'Not authenticated to Microsoft Graph. Run Connect-MsGraphOIDC step first.'
}

Write-Host "  App:    $($context.AppName)"
Write-Host "  Tenant: $($context.TenantId)"

# Basic connectivity: get current user (requires User.Read)
try {
    $me = Get-MgUser -UserId 'me' -ErrorAction Stop
    Write-Host "  User:   $($me.DisplayName) ($($me.UserPrincipalName))"
} catch {
    Write-Host "  User:   (User.Read not available or limited - check API permissions)"
}

Write-Host 'Microsoft Graph connectivity test passed.' -ForegroundColor Green
