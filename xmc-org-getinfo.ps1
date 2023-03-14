# Get information on the current XM Cloud organization.
#
# Author: Serge van den Oever [Macaw]
# Version: 1.0

$VerbosePreference = 'SilentlyContinue' # change to Continue to see verbose output
$DebugPreference = 'SilentlyContinue' # change to Continue to see debug output
$ErrorActionPreference = 'Stop'

Push-Location -Path $PSScriptRoot\..
if (-not (Test-Path -Path .\tools\xmc-config.json)) {
    Write-Error "File .\tools\xmc-config.json does not exist"
}
$xmcloudConfig = Get-Content -Raw -Path .\tools\xmc-config.json | ConvertFrom-Json

$clientId = $xmcloudConfig.XMCloud_AutomationClient_ClientId
$clientSecret = $xmcloudConfig.XMCloud_AutomationClient_ClientSecret
if (-not ($clientId -and $clientSecret)) {
    Write-Verbose "XM Cloud organization client id and client secret not found in file .\tools\xmc-config.json."
}

# Login into XM Cloud using the organization client id and client secret as configured
# Note that login has no --json flag available, check error code results
dotnet sitecore cloud login --client-id $clientId --client-secret $clientSecret --client-credentials
if ($LASTEXITCODE -ne 0) {
    Write-Error "Failed to login to XM Cloud using client id and client secret."
}

$projectList = dotnet sitecore cloud project list --json | ConvertFrom-Json
$projectList | ForEach-Object {
    $project = $_
    Write-Host "Project: $($project.name)"
    Write-Host "- Created at: $($project.createdAt)"
    Write-Host "- Created by: $($project.createdBy)"
    Write-Host "- Last updated at: $($project.lastUpdatedAt)"
    Write-Host "- Last updated by: $($project.lastUpdatedBy)"
    Write-Host "- Project id: $($project.id)"
    Write-Host "- Organization id: $($project.organizationId)"
    Write-Host "- Organization name: $($project.organizationName)"
    Write-Host "- Environments: $($project.environments)"

    $environmentList = dotnet sitecore cloud environment list --project-id $project.id --json | ConvertFrom-Json
    $environmentList | ForEach-Object { 
        $environment = $_
        Write-Host "-- Environment: $($environment.name)"
        Write-Host "--- Created at: $($environment.createdAt)"
        Write-Host "--- Created by: $($environment.createdBy)"
        Write-Host "--- Last updated at: $($environment.lastUpdatedAt)"
        Write-Host "--- Last updated by: $($environment.lastUpdatedBy)"
        Write-Host "--- Environment id: $($environment.id)"
        Write-Host "--- Environment host: $($environment.host)"
        Write-Host "--- Environment last updated at: $($environment.lastUpdatedAt)"
        Write-Host "--- Environment last updated by: $($environment.lastUpdatedBy)"
        Write-Host "--- Environment provisioning status: $($environment.provisioningStatus)"
    }
}
