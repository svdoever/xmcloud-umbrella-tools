# A simple menu to do a WinMerge based comparison of parts of the current XM Cloud project 
# against the headstart project provided by Sitecore used to scaffold an XM Cloud project. 
# Assumption: WinMerge in installed in the folder tools\WinMerge.
# Extend depending on your project needs.
# Author: Serge van den Oever [Macaw]
# Version: 1.0

$VerbosePreference = 'SilentlyContinue' # change to Continue to see verbose output
$DebugPreference = 'SilentlyContinue' # change to Continue to see debug output
$ErrorActionPreference = 'Stop'

$coreFilter="!.vs\;!deployment-logs\;!tools\;!src\;"
$itemsFilter=".scindex"
$platformFilter="!bin\;!obj\;!Platform.csproj.user"
$renderingFilter="!.next\;!.next-container\;!node_modules\;"

$xmcloudFoundationHeadPath = "$PSScriptRoot\..\..\xmcloud-foundation-head" 
if (!(Test-Path $xmcloudFoundationHeadPath)) {
    Write-Error "xmcloud-foundation-head not found at $xmcloudFoundationHeadPath"
}

$h = (Resolve-Path -Path $xmcloudFoundationHeadPath).Path
$p = (Resolve-Path -Path "$PSScriptRoot\..").Path

while ($true) {
    Clear-Host

    Write-Host "Compare Sitecore XM Cloud headstart to Project:"
    Write-Host "1. Core (config / docker stuff)"
    Write-Host "2. src\items"
    Write-Host "3. src\platform"
    Write-Host "4. src\sxastarter -> src\rendering (renamed in project)"
    Write-Host "Q. Quit"

    $choice = Read-Host "Enter your choice"

    switch ($choice) {
        "1" { 
            . "$p\tools\WinMerge\WinMergeU.exe" $h $p /f $coreFilter
        }
        "2" { 
            . "$p\tools\WinMerge\WinMergeU.exe" $h\src\items $p\src\items /f $itemsFilter
        }
        "3" { 
            . "$p\tools\WinMerge\WinMergeU.exe" $h\src\platform $p\src\platform /f $platformFilter
        }
        "4" { 
            . "$p\tools\WinMerge\WinMergeU.exe" $h\src\sxastarter $p\src\rendering /f $renderingFilter
        }
        "Q" { exit }
        "q" { exit }
        default { Write-Host "Invalid choice. Try again." }
    }
}