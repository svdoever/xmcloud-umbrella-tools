# Execute a build and deploy of you project to an XM Cloud environment from the CLI.
# Configuration is done in the file tools\xmc-config.json.
# Documentation on configuration can be found in the file tools\xmc-config.json.
#
# When the build is completed the raw log file is retrieved and split into separate log files per stage
# using the script tools\xmc-buildanddeploy-getlogs.ps1.
# Log files are storted in the folder deployment-logs.
#
# To check if too many files are packaged in the deployment package, execute:
# dotnet sitecore cloud deployment create --environment-id $environmentId --working-dir . --upload --no-watch --no-start --verbose
# Note that files excluded in .gitignore are not uploaded for a deployment.
#
# Author: Serge van den Oever [Macaw]
# Version: 1.0
param (
    [Parameter(Mandatory=$false)][string]$environment = $null
)
$VerbosePreference = 'SilentlyContinue' # change to Continue to see verbose output
$DebugPreference = 'SilentlyContinue' # change to Continue to see debug output
$ErrorActionPreference = 'Stop'

Push-Location -Path $PSScriptRoot\..

. "$PSScriptRoot\xmc-org-login.ps1" -environment $environment

$xmcloudConfig = Get-Content -Raw -Path .\tools\xmc-config.json | ConvertFrom-Json
$environmentInfo = $xmcloudConfig.XMCloud_Environments.$environment
$environmentId =$environmentInfo.id

$environment = dotnet sitecore cloud environment info --environment-id $environmentId --json | ConvertFrom-Json

Write-Host "Environment name: $environment"
Write-Host "Environment id: $environmentId"
Write-Host "Environment host: $($environment.host)"
Write-Host "Environment tenant type: $($environment.tenantType)"
Write-Host "Environment last updated at: $($environment.lastUpdatedAt)"
Write-Host "Environment last updated by: $($environment.lastUpdatedBy)"
Write-Host "Environment provisioning status: $($environment.provisioningStatus)"

Write-Host "Project path used to create a deployment package: $(Get-Location)"
Write-Host "Do a build of the project before creating and uploading a deployment package..."
. "$PSScriptRoot\local-buildall.ps1"
if ($LASTEXITCODE -ne 0) {
    Write-Error "Build was not successful - fix the build errors, validate with .\tools\local-buildall.ps1, and try again."
}
Write-Host "Build completed succesfully"

Write-Host "Creating and uploading a deployment package..." -NoNewline
$deployment = dotnet sitecore cloud deployment create --environment-id $environmentId --working-dir . --upload --no-watch --no-start --json | ConvertFrom-Json
if ($deployment.Status -eq "Operation failed") {
    Write-Host ""
    Write-Error "Creation of deployment failed: $($deployment.Message)"
}
Write-Host " done."
$deploymentId = $deployment.id
Write-Host "Deployment is provisioned and queued. Deployment id: $deploymentId"
Write-Host "See deployment status at https://deploy.sitecorecloud.io/deployment/$deploymentId/details"
Write-Host "Deployment starting with deployment id: $deploymentId"
dotnet sitecore cloud deployment start --deployment-id $deploymentId
Write-Host "Build and deploy completed."

# Process the deployment log to create sensible information
if (-not (Test-Path -Path "$PSScriptRoot\xmc-buildanddeploy-getlogs.ps1")) {
    Write-Error "Expected file '$PSScriptRoot\xmc-buildanddeploy-getlogs.ps1' does not exist."
}
. "$PSScriptRoot\xmc-buildanddeploy-getlogs.ps1" -deploymentId $deploymentId
Pop-Location

# Ring the bell to indicate the script has completed
# In Visual Studio Code enable the setting terminal.integrated.enableBell
Write-Host "`a"