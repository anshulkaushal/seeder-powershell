# seeder-powershell

PowerShell-based utilities for the migration of Azure Automation (Hybrid Worker) workloads to GitHub Actions.

## Overview

This repo supports the transition of Cloud Ops automation from **ACC-VMAutomation-Prod** (Azure Automation Account with Hybrid Workers) to **GitHub Actions**. It provides the PowerShell and structural pieces needed so workloads can run in Actions with consistent auth, module handling, and scheduling.

See **data.txt** in this repo for the full feature-requirements outline (background, issues/risks, target state, and detailed requirements).

## Quick Start

1. **Configure Azure App Registration** – See [docs/AZURE_APP_REGISTRATION.md](docs/AZURE_APP_REGISTRATION.md) for Option A (single app) or Option B (separate apps).
2. **Add GitHub Secrets** – `AZURE_CLIENT_ID`, `AZURE_TENANT_ID`, `AZURE_SUBSCRIPTION_ID` (and optionally `MSGRAPH_CLIENT_ID`, `MSGRAPH_TENANT_ID` for Option B).
3. **Run Test Connectivity** – Actions → Test Connectivity → Run workflow.

## Documentation

| Document | Description |
|----------|-------------|
| [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) | Architecture, folder structure, workflow parameters |
| [docs/AZURE_APP_REGISTRATION.md](docs/AZURE_APP_REGISTRATION.md) | Option A (single app) vs Option B (separate apps) for Azure + MS Graph |
| [docs/SETUP.md](docs/SETUP.md) | Setup guide, troubleshooting |

## Azure App Registration Options

| Option | Use Case | Secrets |
|--------|----------|---------|
| **A: Single** | One app for Azure RM + MS Graph | `AZURE_CLIENT_ID`, `AZURE_TENANT_ID`, `AZURE_SUBSCRIPTION_ID` |
| **B: Separate** | Different RBAC for Azure vs Graph | Same + `MSGRAPH_CLIENT_ID` (optional `MSGRAPH_TENANT_ID`) |

## Folder Structure

```
├── .github/workflows/
│   ├── run-powershell-workload.yml   # Reusable workflow
│   ├── test-connectivity.yml        # Test Azure + Graph auth
│   └── example-scheduled.yml       # Example: scheduled/manual run
├── .github/scripts/
│   └── Connect-MsGraphOIDC.ps1      # MS Graph OIDC auth helper
├── docs/
├── modules/                         # Custom PowerShell modules
│   └── CloudOps/
├── scripts/                         # Workload scripts
│   ├── Test-AzureConnectivity.ps1
│   ├── Test-MsGraphConnectivity.ps1
│   ├── Test-Basic.ps1
│   └── Test-Connectivity.ps1
└── requirements.psd1
```

## Test Scripts

| Script | Purpose |
|--------|---------|
| `Test-Basic.ps1` | No auth; validates workflow, PowerShell, module path |
| `Test-AzureConnectivity.ps1` | Verifies Azure OIDC auth and basic API access |
| `Test-MsGraphConnectivity.ps1` | Verifies MS Graph OIDC auth and basic API access |
| `Test-Connectivity.ps1` | Runs Azure + Graph tests (used by test-connectivity workflow) |

## Usage

**Call the reusable workflow from your own workflow:**

```yaml
jobs:
  run:
    uses: ./.github/workflows/run-powershell-workload.yml
    with:
      authenticate_to_azure: true
      authenticate_to_ms_graph: false
      script_location: scripts/YourScript.ps1
    secrets: inherit
```

**Import custom modules in your script:**

```powershell
Import-Module (Join-Path $env:MODULE_PATH 'CloudOps' 'CloudOps.psm1') -Force
```

## Requirements (summary)

| Area | Requirement |
|------|-------------|
| **Authentication** | Azure and MS Graph auth via OIDC (no cert rotation); auth performed before workload scripts run. |
| **Modules** | Cache commonly used modules between workflow runs. Support custom modules in `./modules`, easy to import. |
| **Scheduling** | Reusable workflow; supports schedule + manual trigger; parameters: authenticate to Azure?, authenticate to MS Graph?, script location. |
| **Monitoring** | Workflow failures → ServiceNow incidents; e-mail alerting (planned). |
| **RBAC** | Standard GitHub pattern: team access to Git + Actions; repo settings restricted to team admins. |

## Checklist / Backlog

- [x] **Authentication**: OIDC-based Azure auth; MS Graph auth; auth before workload script.
- [x] **Modules**: Cache common modules; folder structure for custom modules.
- [x] **Scheduling**: Reusable workflow; schedule + manual; parameters for auth and script.
- [ ] **Monitoring**: Workflow failures → ServiceNow incident; optional e-mail alerting.
- [ ] **RBAC**: Team Git + Actions; team admins own repo settings.

## Repo requirements

- PowerShell 7+ (workflows use `pwsh`)

## License

(Add license info if applicable.)
