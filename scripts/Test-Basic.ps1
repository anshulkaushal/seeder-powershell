# Test-Basic.ps1
# Minimal test script - no Azure or Graph auth required
# Use for validating workflow structure, module path, and PowerShell execution
param()

$ErrorActionPreference = 'Stop'

Write-Host '=== Basic Test ==='
Write-Host "PowerShell: $($PSVersionTable.PSVersion)"
Write-Host "OS: $($PSVersionTable.OS)"
Write-Host "Working dir: $(Get-Location)"

if ($env:MODULE_PATH) {
    Write-Host "Module path: $env:MODULE_PATH"
    if (Test-Path $env:MODULE_PATH) {
        Write-Host "  Custom modules folder exists: $(Get-ChildItem $env:MODULE_PATH -ErrorAction SilentlyContinue | Measure-Object).Count modules"
    }
}

Write-Host 'Basic test passed.' -ForegroundColor Green
