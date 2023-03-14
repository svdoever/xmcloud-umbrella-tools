# Create a new rendering project for a tenant.
# Author: Serge van den Oever [Macaw]
# Version: 1.0
param (
    [string][Parameter(Mandatory=$true)]$tenant,
    [switch]$force = $false
)

$VerbosePreference = 'SilentlyContinue' # change to Continue to see verbose output
$DebugPreference = 'SilentlyContinue' # change to Continue to see debug output
$ErrorActionPreference = 'Stop'

if ([regex]::Match($tenant, '^\d').Success -eq $true) {
    Write-Error "Tenant name cannot start with a number."
}

$normalizedTenant = $tenant.ToLowerInvariant()
$normalizedTenant = [regex]::Replace($normalizedTenant, '[^a-z0-9-_]+', '')
if ($normalizedTenant -eq '') {
    Write-Error "Tenant name '$tenant' is not allowed, it can not be resolved to a useful name."
}
if ($normalizedTenant -ne $tenant) {
    Write-Warning "Tenant name '$tenant' is not allowed. Using '$normalizedTenant' instead."
    $tenant = $normalizedTenant
}

Push-Location -Path "$PSScriptRoot\..\src"

$projectName = "rendering-$tenant"

if (Test-Path -Path $projectName) {
    if ($force) {
        Remove-Item -Path $projectName -Recurse -Force
    }
    else {
        Pop-Location
        Write-Error "Tenant project '$projectName' already exists. Use -force to overwrite."
    }
}

Write-Host "Creating tenant project '$projectName'..."
npx create-sitecore-jss --templates nextjs,nextjs-sxa --appName $projectName --destination $projectName --fetchWith GraphQL --prerender SSR --hostName "$($projectName).dev.local" 
Write-Host "Tenant project '$projectName' created."
Pop-Location
