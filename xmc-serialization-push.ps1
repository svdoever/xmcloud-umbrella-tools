# Push serialization items based on the configuration.
#
# Author: Serge van den Oever [Macaw]
# Version: 1.0
param (
    [Parameter(Mandatory=$true)][string]$environment
)
$VerbosePreference = 'Continue' # change to Continue to see verbose output
$DebugPreference = 'SilentlyContinue' # change to Continue to see debug output
$ErrorActionPreference = 'Stop'

Push-Location -Path $PSScriptRoot\..

. "$PSScriptRoot\xmcloud-org-login.ps1" -environment $environment
dotnet sitecore serialization push --environment-name $environment

Pop-Location

# Ring the bell to indicate the script has completed
# In Visual Studio Code enable the setting terminal.integrated.enableBell
Write-Host "`a"