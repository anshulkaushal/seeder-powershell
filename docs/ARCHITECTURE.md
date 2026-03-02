# Architecture

## Overview

This document describes the architecture for running PowerShell workloads in GitHub Actions, replacing Azure Automation Hybrid Workers.

## High-Level Flow

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         GitHub Actions Workflow                              │
├─────────────────────────────────────────────────────────────────────────────┤
│  1. Checkout repo                                                            │
│  2. Cache PowerShell modules (Az, Microsoft.Graph)                           │
│  3. Authenticate to Azure (OIDC) ──────────────────► Azure App Registration   │
│  4. Authenticate to MS Graph (OIDC) ──────────────► Azure App Registration   │
│  5. Import custom modules from ./modules                                      │
│  6. Run workload script from ./scripts                                        │
└─────────────────────────────────────────────────────────────────────────────┘
```

## Folder Structure

```
seeder-powershell/
├── .github/
│   └── workflows/
│       ├── run-powershell-workload.yml    # Reusable workflow
│       ├── test-connectivity.yml         # Test workflow (manual/scheduled)
│       └── example-scheduled.yml         # Example: scheduled job
├── docs/
│   ├── ARCHITECTURE.md
│   ├── AZURE_APP_REGISTRATION.md
│   └── SETUP.md
├── modules/                               # Custom PowerShell modules
│   └── CloudOps/                          # Example module
│       └── CloudOps.psm1
├── scripts/                               # Workload scripts
│   ├── Test-AzureConnectivity.ps1
│   ├── Test-MsGraphConnectivity.ps1
│   └── Test-Basic.ps1
├── data.txt
└── README.md
```

## Authentication Model

- **OIDC (OpenID Connect)**: No certificates or long-lived secrets. GitHub requests a short-lived token from Azure AD.
- **App Registration Options**:
  - **Option A (Single)**: One app registration with both Azure RM and MS Graph API permissions.
  - **Option B (Separate)**: Two app registrations—one for Azure RM, one for MS Graph—for finer RBAC separation.

See [AZURE_APP_REGISTRATION.md](./AZURE_APP_REGISTRATION.md) for details.

## Reusable Workflow Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `authenticate_to_azure` | boolean | `true` | Request Azure OIDC token and connect to Azure |
| `authenticate_to_ms_graph` | boolean | `false` | Request MS Graph OIDC token and connect to Microsoft Graph |
| `script_location` | string | required | Path to the PowerShell script to run (relative to repo root) |
| `subscription_id` | string | optional | Azure subscription ID (for single-subscription context) |

## Module Caching

- Common modules (`Az`, `Microsoft.Graph`) are cached using `actions/cache`.
- Cache key includes runner OS and module versions.
- Custom modules live in `./modules` and are imported at runtime (no caching needed).

## Monitoring & Alerting (Planned)

- Workflow failures → ServiceNow incident (integration TBD)
- Optional e-mail alerting
- GitHub Actions native notifications for workflow status
