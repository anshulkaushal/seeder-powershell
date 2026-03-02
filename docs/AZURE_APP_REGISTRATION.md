# Azure App Registration Options

This document describes how to configure Azure App Registrations for OIDC-based authentication from GitHub Actions to Azure and Microsoft Graph.

## Overview

GitHub Actions uses OIDC to obtain short-lived tokens from Azure AD. You need one or more App Registrations with federated credentials configured for your GitHub repo.

---

## Option A: Single App Registration

Use **one** App Registration for both Azure Resource Manager and Microsoft Graph.

### When to Use

- Simpler setup and secret management
- Same identity for Azure and Graph operations
- Suitable when both scopes are needed for most workloads

### Setup Steps

1. **Create App Registration** in Azure Portal:
   - Name: e.g. `github-actions-seeder-prod`
   - Supported account types: Single tenant

2. **Add API Permissions**:
   - **Microsoft Graph**: `User.Read`, `Group.Read.All` (or other Graph scopes as needed)
   - **Azure Management**: `user_impersonation` (or `Contributor` at subscription/resource group level)

3. **Create Federated Credential**:
   - Certificates & secrets → Federated credentials → Add
   - Federated credential scenario: **GitHub Actions**
   - Organization: your org
   - Repository: `seeder-powershell`
   - Entity type: `Branch` (or `Environment` for environment-specific)
   - GitHub branch name: `main` (or `ref:refs/heads/main`)

4. **Grant Admin Consent** for the API permissions.

5. **Create a Service Principal** (if not auto-created):
   - App registrations → Your app → Overview → Application (client) ID
   - Create a service principal and assign RBAC roles in Azure

### GitHub Secrets (Option A)

| Secret | Description |
|--------|-------------|
| `AZURE_CLIENT_ID` | Application (client) ID of the app registration |
| `AZURE_TENANT_ID` | Directory (tenant) ID |
| `AZURE_SUBSCRIPTION_ID` | Target subscription ID |

For **MS Graph** with the same app: use the same `AZURE_CLIENT_ID` and `AZURE_TENANT_ID`. The workflow will request different audiences (Azure RM vs Graph) using the same credentials.

---

## Option B: Separate App Registrations

Use **two** App Registrations: one for Azure RM, one for Microsoft Graph.

### When to Use

- Different RBAC requirements for Azure vs Graph
- Compliance or audit needs for separation of duties
- Different teams managing Azure vs Graph access

### Setup Steps

**App Registration 1 – Azure RM**

1. Create App Registration: e.g. `github-actions-seeder-azure`
2. API Permissions: Azure Management → `user_impersonation`
3. Federated credential: GitHub Actions, repo, branch
4. Assign RBAC (Contributor, Reader, etc.) to the service principal

**App Registration 2 – MS Graph**

1. Create App Registration: e.g. `github-actions-seeder-graph`
2. API Permissions: Microsoft Graph → `User.Read`, `Group.Read.All`, etc.
3. Federated credential: GitHub Actions, repo, branch
4. Grant admin consent

### GitHub Secrets (Option B)

| Secret | Description |
|--------|-------------|
| `AZURE_CLIENT_ID` | Client ID for **Azure RM** app registration |
| `AZURE_TENANT_ID` | Directory (tenant) ID |
| `AZURE_SUBSCRIPTION_ID` | Target subscription ID |
| `MSGRAPH_CLIENT_ID` | Client ID for **MS Graph** app registration (optional; if not set, falls back to `AZURE_CLIENT_ID`) |
| `MSGRAPH_TENANT_ID` | Tenant ID for MS Graph (optional; defaults to `AZURE_TENANT_ID`) |

---

## Workflow Behaviour

| Configuration | Azure Auth | MS Graph Auth |
|---------------|------------|---------------|
| Option A | Uses `AZURE_CLIENT_ID` | Uses `AZURE_CLIENT_ID` (same app) |
| Option B | Uses `AZURE_CLIENT_ID` | Uses `MSGRAPH_CLIENT_ID` (or `AZURE_CLIENT_ID` if not set) |

The reusable workflow checks for `MSGRAPH_CLIENT_ID`. If present, it uses that for Graph; otherwise it uses `AZURE_CLIENT_ID` for both.

---

## Federated Credential Examples

**Branch-based (main):**

```
Issuer:    https://token.actions.githubusercontent.com
Subject:   repo:your-org/seeder-powershell:ref:refs/heads/main
Audience:  api://AzureADTokenExchange
```

**Environment-based (production):**

```
Subject:   repo:your-org/seeder-powershell:environment:production
```

Use environments when you need different credentials per environment (e.g. dev vs prod).
