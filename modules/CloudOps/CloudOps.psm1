# CloudOps.psm1 - Sample custom module
function Get-CloudOpsInfo {
    [CmdletBinding()]
    param()
    @{
        ModulePath = $env:MODULE_PATH
        Timestamp  = Get-Date -Format o
    }
}
