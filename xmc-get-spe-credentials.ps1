# Get the SPE credentials for the given XM Cloud environment from the xmc-config.json
# configuration file.
#
# Author: Serge van den Oever [Macaw]
# Version: 1.0
param (
    [Parameter(Mandatory=$false)][string]$environment = $null
)

$VerbosePreference = 'SilentlyContinue' # change to Continue to see verbose output
$DebugPreference = 'SilentlyContinue' # change to Continue to see debug output
$ErrorActionPreference = 'Stop'

if (-not (Test-Path -Path $PSScriptRoot\xmc-config.json)) {
    Write-Error "File .\tools\xmc-config.json does not exist"
}
$xmcloudConfig = Get-Content -Raw -Path $PSScriptRoot\xmc-config.json | ConvertFrom-Json

if (-not ($xmcloudConfig.XMCloud_Environments)) {
    Write-Error "Environment configuration 'XMCloud_Environment' not found in file .\tools\xmc-config.json. See .\tools\xmc-config.md for an example of the required format."
}

if ($environment -eq $null -and $xmcloudConfig.XMCloud_DefaultEnvironment) {
    $environment = $xmcloudConfig.XMCloud_DefaultEnvironment
    Write-Host "No environment specified, using default environment '$environment'"
}   

if ($null -eq $environment) {
    Write-Error "No environment specified and no default environment found in file .\tools\xmc-config.json. See .\tools\xmc-config.md for an example of the required format."
}   

$environmentInfo = $xmcloudConfig.XMCloud_Environments.$environment
if (-not ($environmentInfo.cm -and $environmentInfo.spe_username -and $environmentInfo.spe_sharedsecret)) {
    Write-Error "Environment '$environment' missing field 'cm', or 'spe_username', or 'spe_sharedsecret' in file .\tools\xmc-config.json. See .\tools\xmc-config.md for an example of the required format."
}

Write-Host "Username    : $($environmentInfo.spe_username)"
Write-Host "SharedSecret: $($environmentInfo.spe_sharedsecret)"
Write-Host "Server      : $($environmentInfo.cm)"

@{
    cm = $environmentInfo.cm
    spe_username = $environmentInfo.spe_username
    spe_sharedsecret = $environmentInfo.spe_sharedsecret
}