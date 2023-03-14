# Process the raw deploment log file retrieved for a specific deployment to XM CLoud into
# the folder deployment-logs, split into separate log files per stage.
#
# Author: Serge van den Oever [Macaw]
# Version: 1.0
param (
    [Parameter(Mandatory=$true)][string]$deploymentId
)

$VerbosePreference = 'SilentlyContinue' # change to Continue to see verbose output
$DebugPreference = 'SilentlyContinue' # change to Continue to see debug output
$ErrorActionPreference = 'Stop'

function Convert-DateToCustomFormat {
    param(
        [string]$InputDate
    )

    $parsedDate = [DateTime]::Parse($InputDate)
    $outputDate = $parsedDate.ToString("yyyyMMdd-HHmm")

    return $outputDate
}

Push-Location -Path $PSScriptRoot\..

$deploymentId = $deploymentId.Trim()
if ($deploymentId -eq '') {
    Write-Error "Deployment id is empty"
}

$deploymentInfo = dotnet sitecore cloud deployment info --deployment-id $deploymentId --json | ConvertFrom-Json
if ($deploymentInfo.Status -eq 'Operation failed') {
    Write-Error $deploymentInfo.Message
}

$date = Convert-DateToCustomFormat -InputDate $deploymentInfo.createdAt
$logBasename = "Deployment_$($date)_$($deploymentId)"

$currentLocation = (Get-Location).Path
$logFilePath = "$currentLocation\deployment-logs\Deployment_$($deploymentId)_logs.json"
if (Test-Path -Path $logFilePath) {
    Write-Host "Removing existing raw deployment log file..." -NoNewline
    Remove-Item -Path $logFilePath -Force
    Write-Host " done."
}
Write-Host "Retrieving deployment logs..." -NoNewline
dotnet sitecore cloud deployment log --deployment-id $deploymentId --path deployment-logs
$rawLogfilePath = "$PSScriptRoot\..\deployment-logs\$($logBasename)_rawlogs.json"
if (Test-Path -Path $rawLogfilePath) {
    Write-Host "Removing existing raw deployment log file..." -NoNewline
    Remove-Item -Path $rawLogfilePath -Force
    Write-Host " done."
}
Rename-Item -Path $logFilePath -NewName "$($logBasename)_rawlogs.json" -Force
$rawLogfilePath = (Resolve-Path -Path $rawLogfilePath).Path

if (-not (Test-Path -Path $rawLogfilePath)) {
    Write-Error "Deployment log file with deployment id '$deploymentId' not found at $rawLogfilePath"
}
$rawLogfilePath = Resolve-Path -Path $rawLogfilePath
$rawLogfilePath = $rawLogfilePath.Path
Write-Host "Deployment raw log file path: $rawLogfilePath"
$logData = Get-Content -Raw -Path $rawLogfilePath | ConvertFrom-Json
$stages = $logData.Stage
$logs = $logData.Logs
$stages | ForEach-Object {
    $stageName = $_.Name
    $stageLogs = $logs | Where-Object { $_.Stage -eq $stageName }
    $lines = ''
    $stageLogs | ForEach-Object {
        $logTime = $_.LogTime.SubString(0,19) # only date and time
        $logLevel = $_.LogLevel.ToUpper()
        $logMessage = $_.LogMessage
        $lines += "$logTime $logLevel $logMessage`n"
    }
    $stageLogFilePath = "$PSScriptRoot\..\deployment-logs\$($logBasename)_$($stageName).log"
    Set-Content -Force -Path $stageLogFilePath -Value $lines
    $_ | Add-Member -NotePropertyName LogFile -NotePropertyValue (Resolve-Path -Path $stageLogFilePath).Path
}
$stagesResult = $stages | Format-Table -Property Name, State, LogFile -AutoSize | Out-String -Width 512
$stagesLogFilePath = "$PSScriptRoot\..\deployment-logs\$($logBasename)_StagesOverview.log"
Set-Content -Path $stagesLogFilePath -Value $stagesResult
$stagesLogFilePath = (Resolve-Path -Path $stagesLogFilePath).Path
Write-Host "Deployment stages overview log file path: $stagesLogFilePath"
Write-Host $stagesResult
