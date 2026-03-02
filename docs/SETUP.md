# Setup Guide

## Prerequisites

- GitHub repository with Actions enabled
- Azure subscription and permissions to create App Registrations
- PowerShell 7+ (recommended; workflows use `pwsh`)

## Quick Start

### 1. Configure Azure App Registration

Choose **Option A** (single app) or **Option B** (separate apps) from [AZURE_APP_REGISTRATION.md](./AZURE_APP_REGISTRATION.md) and complete the setup.

### 2. Add GitHub Secrets

In your repo: **Settings → Secrets and variables → Actions**

| Secret | Required | Description |
|--------|----------|-------------|
| `AZURE_CLIENT_ID` | Yes | Application (client) ID |
| `AZURE_TENANT_ID` | Yes | Directory (tenant) ID |
| `AZURE_SUBSCRIPTION_ID` | Yes | Target Azure subscription ID |
| `MSGRAPH_CLIENT_ID` | No | Only for Option B; MS Graph app client ID |
| `MSGRAPH_TENANT_ID` | No | Only if Graph uses a different tenant |

### 3. Run the Test Workflow

1. Go to **Actions** tab
2. Select **Test Connectivity**
3. Click **Run workflow**
4. Choose options and run

This runs `Test-AzureConnectivity.ps1` and `Test-MsGraphConnectivity.ps1` to verify auth.

### 4. Call the Reusable Workflow from Your Own Workflow

```yaml
jobs:
  run-workload:
    uses: ./.github/workflows/run-powershell-workload.yml
    with:
      authenticate_to_azure: true
      authenticate_to_ms_graph: false
      script_location: scripts/YourScript.ps1
    secrets: inherit
```

## Adding a New Workload Script

1. Create your script in `scripts/`, e.g. `scripts/MyWorkload.ps1`
2. Create a workflow that calls the reusable workflow:

```yaml
# .github/workflows/my-workload.yml
name: My Workload
on:
  workflow_dispatch:
  schedule:
    - cron: '0 * * * *'  # Every hour
jobs:
  run:
    uses: ./.github/workflows/run-powershell-workload.yml
    with:
      authenticate_to_azure: true
      authenticate_to_ms_graph: true
      script_location: scripts/MyWorkload.ps1
    secrets: inherit
```

## Custom Modules

Place custom modules under `modules/`:

```
modules/
└── CloudOps/
    ├── CloudOps.psm1
    └── CloudOps.psd1
```

Import in your script:

```powershell
Import-Module (Join-Path $PSScriptRoot '..' 'modules' 'CloudOps' 'CloudOps.psm1') -Force
```

Or use the `$env:MODULE_PATH` set by the workflow (see run-powershell-workload.yml).

## Troubleshooting

| Issue | Check |
|-------|-------|
| OIDC token request fails | Federated credential subject matches repo/branch; issuer is correct |
| Azure login fails | `AZURE_CLIENT_ID`, `AZURE_TENANT_ID`, `AZURE_SUBSCRIPTION_ID` are correct; SP has RBAC |
| MS Graph login fails | Graph API permissions granted; admin consent applied; `MSGRAPH_CLIENT_ID` correct if using Option B |
| Module not found | Script path; `Import-Module` path; module manifest |
