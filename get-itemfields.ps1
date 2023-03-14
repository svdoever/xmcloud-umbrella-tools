# Display fields of Sitecore item
# https://www.sergevandenoever.nl
param(
    [Parameter(Mandatory=$true)][string]$environment,
    [string]$itemPath = "/sitecore/content/Home"
)

$spe = . "$PSScriptRoot\xmc-get-spe-credentials.ps1" -environment $environment

Write-Output "Get item fields of '$itemPath'..."
Import-Module -Name SPE 
$session = New-ScriptSession -Username $spe.spe_username -SharedSecret $spe.spe_sharedsecret -ConnectionUri $spe.cm
$result = Invoke-RemoteScript -Session $session -ScriptBlock {
    Get-Item $Using:itemPath | Get-ItemField -IncludeStandardFields -ReturnType Field -Name "*" | Format-Table Name, DisplayName, SectionDisplayName, Description -auto
}
Stop-ScriptSession -Session $session
Write-Output $result

