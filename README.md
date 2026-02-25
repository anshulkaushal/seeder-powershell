# seeder-powershell

PowerShell-based utilities for the migration of Azure Automation (Hybrid Worker) workloads to GitHub Actions.

## Overview

This repo supports the transition of Cloud Ops automation from **ACC-VMAutomation-Prod** (Azure Automation Account with Hybrid Workers) to **GitHub Actions**. It provides the PowerShell and structural pieces needed so workloads can run in Actions with consistent auth, module handling, and scheduling.

See **data.txt** in this repo for the full feature-requirements outline (background, issues/risks, target state, and detailed requirements).

## Background

- **Current**: Automation runs on a Hybrid Worker group (e.g. AZUWHW0002 / AZUWHW1002). This has led to CAF/multi-subscription context issues, VM state inconsistency, and long-lived legacy infra.
- **Target**: Run automation as GitHub Actions workflows, with OIDC-based Azure (and MS Graph) auth, reusable workflows for scheduling, and no Hybrid Worker dependency.

## Requirements (summary)

| Area | Requirement |
|------|-------------|
| **Authentication** | Azure and MS Graph auth via OIDC (no cert rotation); auth performed before workload scripts run. |
| **Modules** | Cache commonly used modules between workflow runs. Support custom modules in a clear folder structure, separate from workload scripts, easy to import. |
| **Scheduling** | Reusable/callable workflows for scheduled and manual runs; options at minimum: authenticate to Azure?, authenticate to MS Graph?, script location. |
| **Monitoring** | Workflow failures → ServiceNow incidents; e-mail alerting as an option. |
| **RBAC** | Standard GitHub pattern: team access to Git + Actions; repo settings (secrets, environments) restricted to team admins. |

## Repo requirements

- PowerShell (version TBD)

## Usage

(Add usage instructions as workflows and scripts are added.)

## License

(Add license info if applicable.)
