<#
.SYNOPSIS
Get a bearer token for making XM Cloud API calls.

.DESCRIPTION
This script retrieves a bearer token from the XM Cloud API using a client ID and client secret. 
The bearer token can be used to make authenticated API calls to XM Cloud services. 
Example of XM Cloud API where bearer token can be used: https://xmclouddeploy-api.sitecorecloud.io/swagger/index.html
On the swagger page, click Authorize and enter the bearer token in the value field.

.PARAMETER environment
The name of the environment to get the bearer token for. This parameter is mandatory.

.NOTES
Author: Serge van den Oever [Macaw]
Version: 1.0

.EXAMPLE
PS C:\> .\get-xmc-bearer-token.ps1 -environment "dev"

This example retrieves a bearer token for the "dev" environment and outputs the token type, 
access token, expiration time, and scope of the bearer token to the console.

.INPUTS
None.

.OUTPUTS
System.String. The bearer token retrieved from the XM Cloud API.

#>

# Get the bearer-token used for the XM Cloud API calls.
# 
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

$info = . "$PSScriptRoot\xmc-org-login.ps1" -environment $environment

# web request to get the bearer token
$clientId = $info.clientId
$clientSecret = $info.clientSecret
$token = Invoke-RestMethod -Method Post -Uri "https://auth.sitecorecloud.io/oauth/token" -Body @{ audience="https://api.sitecorecloud.io"; grant_type="client_credentials"; client_id=$clientId; client_secret=$clientSecret } -ContentType "application/x-www-form-urlencoded" -Headers @{ Accept="application/json" } -ErrorAction Stop
Write-Host "Token type  : $($token.token_type)"
Write-Host "Access token: $($token.access_token)"
Write-Host "Expires in  : $($token.expires_in)"
Write-Host "Scope       : $($token.scope)"
$token.access_token