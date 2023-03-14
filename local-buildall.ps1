# Do a build of the Visual Studio solution and the frontend projects.
# Author: Serge van den Oever [Macaw]
# Version: 1.0


Push-Location -Path $PSScriptRoot\..

try {
    Import-Module -Name $PSScriptRoot\modules\ModuleManagement.psm1 -Force
    Install-ModuleIfNotInstalled -moduleName VSSetup
    Install-ModuleIfNotInstalled -moduleName BuildUtils

    $msbuildLocation = Get-LatestMsbuildLocation
    Set-Alias -Name msbuild -Value $msbuildLocation

    Get-Item -Path "*.sln" | ForEach-Object {
        Write-Host "Building solution '$($_.BaseName)' ($($_.FullName))..."
        msbuild $_.FullName /t:Clean,Build /nologo /verbosity:quiet /consoleloggerparameters:summary
        if ($LASTEXITCODE -ne 0) {
            Write-Error "Visual Studio build of solution '$($_.BaseName)' failed."
        }
    }

    Push-Location -Path src
    try {
        if (Test-Path -Path "package.json") {
            # Assume usage of npm workspaces
            if (-not (Test-Path -Path "node_modules")) {
                npm install 
            }

            npm run lint
            if ($LASTEXITCODE -ne 0) {
                Write-Error "Front-end solution lint through npm workspaces failed."
            }
        } else {
            Write-Warning "Preferred file 'src\package.json' with configuration for npm workspaces and a 'build' script that build all workspaces does not exist."
            Write-Warning "Falling back to linting each src\* directory containing a package.json individually."

            # Go through each src\* folder containing a package.json file and run npm install and npm run lint
            Get-ChildItem -Path . -Recurse -Depth 1 -Filter "package.json" | ForEach-Object {
                $packageJsonPath = $_.FullName
                $packageJsonFolder = Split-Path -Path $packageJsonPath -Parent
                Write-Host "- Linting front-end solution '$($packageJsonFolder)..."
                Push-Location -Path $packageJsonFolder
                try {
                    if (-not (Test-Path -Path "node_modules")) {
                        npm install 
                    }

                    npm run lint
                    if ($LASTEXITCODE -ne 0) {
                        Write-Error "Front-end solution lint failed."
                    }
                } finally {
                    Pop-Location
                }
            }
        }
    } finally {
        Pop-Location
    }
} finally {
    Pop-Location
}