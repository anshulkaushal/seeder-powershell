# Connect to Microsoft Graph using OIDC
# Option A: Uses az account get-access-token (after azure/login) when same app for Azure + Graph
# Option B: Exchanges GitHub OIDC token for Graph token when MSGRAPH_CLIENT_ID is a separate app
param()

$ErrorActionPreference = 'Stop'

$clientId = $env:MSGRAPH_CLIENT_ID ?? $env:AZURE_CLIENT_ID
$tenantId = $env:MSGRAPH_TENANT_ID ?? $env:AZURE_TENANT_ID

if (-not $clientId -or -not $tenantId) {
    throw 'MSGRAPH_CLIENT_ID/AZURE_CLIENT_ID and MSGRAPH_TENANT_ID/AZURE_TENANT_ID must be set'
}

$accessToken = $null

# Option A: Same app - use az (from azure/login) to get Graph token
if ($env:MSGRAPH_CLIENT_ID -eq $env:AZURE_CLIENT_ID -or -not $env:MSGRAPH_CLIENT_ID) {
    try {
        $tokenJson = az account get-access-token --resource https://graph.microsoft.com --query accessToken -o tsv 2>$null
        if ($tokenJson) {
            $accessToken = $tokenJson.Trim()
        }
    } catch {
        # Fall through to OIDC exchange
    }
}

# Option B or fallback: Exchange GitHub OIDC token for an Azure AD token (Graph audience)
if (-not $accessToken) {
    $idToken = $null
    if ($env:ACTIONS_ID_TOKEN_REQUEST_TOKEN -and $env:ACTIONS_ID_TOKEN_REQUEST_URL) {
        $headers = @{ Authorization = "Bearer $env:ACTIONS_ID_TOKEN_REQUEST_TOKEN" }
        $resp = Invoke-RestMethod -Uri $env:ACTIONS_ID_TOKEN_REQUEST_URL -Headers $headers -Method Get
        $idToken = $resp.value
    }
    if (-not $idToken) {
        throw 'Could not obtain OIDC token. Ensure id-token: write permission is set and workflow has access to id-token.'
    }

    $body = @{
        client_id             = $clientId
        client_assertion_type  = 'urn:ietf:params:oauth:client-assertion-type:jwt-bearer'
        client_assertion      = $idToken
        grant_type            = 'client_credentials'
        scope                 = 'https://graph.microsoft.com/.default'
    }
    $bodyStr = ($body.GetEnumerator() | ForEach-Object { "$($_.Key)=$([uri]::EscapeDataString($_.Value))" }) -join '&'
    $tokenUrl = "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token"
    $response = Invoke-RestMethod -Uri $tokenUrl -Method Post -Body $bodyStr -ContentType 'application/x-www-form-urlencoded'
    $accessToken = $response.access_token
}

if (-not $accessToken) {
    throw 'Could not obtain access token for Microsoft Graph.'
}

Import-Module Microsoft.Graph.Authentication -ErrorAction Stop
$secureToken = ConvertTo-SecureString $accessToken -AsPlainText -Force
Connect-MgGraph -AccessToken $secureToken -NoWelcome

Write-Host 'Connected to Microsoft Graph successfully.'
