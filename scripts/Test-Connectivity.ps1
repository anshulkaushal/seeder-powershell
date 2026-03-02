# Test-Connectivity.ps1
# Orchestrates Azure and MS Graph connectivity tests
# Called by the test-connectivity workflow
param()

$ErrorActionPreference = 'Stop'

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# Run Azure test if we have an Azure context (authenticate_to_azure was true)
if (Get-Module Az.Accounts -ErrorAction SilentlyContinue) {
    $azContext = Get-AzContext -ErrorAction SilentlyContinue
    if ($azContext) {
        Write-Host "`n=== Running Azure test ===" -ForegroundColor Cyan
        & (Join-Path $scriptDir 'Test-AzureConnectivity.ps1')
        Write-Host "=== Azure test passed ===" -ForegroundColor Green
    }
}

# Run MS Graph test if we have a Graph context (authenticate_to_ms_graph was true)
if (Get-Module Microsoft.Graph.Authentication -ErrorAction SilentlyContinue) {
    $mgContext = Get-MgContext -ErrorAction SilentlyContinue
    if ($mgContext) {
        Write-Host "`n=== Running MS Graph test ===" -ForegroundColor Cyan
        & (Join-Path $scriptDir 'Test-MsGraphConnectivity.ps1')
        Write-Host "=== MS Graph test passed ===" -ForegroundColor Green
    }
}

Write-Host "`nAll connectivity tests passed." -ForegroundColor Green
