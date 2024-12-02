<#
.SYNOPSIS
Reads and parses an INI file dynamically.
 
.DESCRIPTION
Parses an INI file and returns the values as a hash table, organized by section. Automatically handles file checks.
 
.PARAMETER FilePath
The full path to the INI file.
 
.EXAMPLE
$Config = Read-Config -FilePath "$PSScriptRoot\Config.ini"
$MainIcon = $Config["Icons"]["MainIcon"]
#>

function Read-Config {
    param (
        [Parameter(Mandatory = $false)]
        [string]$FilePath
    )

    # Default location in the module folder
    if (-not $FilePath) {
        $FilePath = Join-Path -Path (Get-Module -Name "PSProfileMigrationAssistant" -ListAvailable).ModuleBase -ChildPath "Public\Config\Config.ini"
        
    }

    if (-not (Test-Path -Path $FilePath)) {
        throw "Config file not found: $FilePath"
    }

    $config = @{}
    $currentSection = $null

    Get-Content -Path $FilePath | ForEach-Object {
        $line = $_.Trim()
        if ($line -match '^\[(.+?)\]$') {
            $currentSection = $matches[1]
            $config[$currentSection] = @{}
        } elseif ($line -match '^(.*?)=(.*)$' -and $currentSection) {
            $key = $matches[1].Trim()
            $value = $matches[2].Trim()
            $config[$currentSection][$key] = $value
        }
    }

    # Dynamically resolve paths for the Images section
    if ($config.ContainsKey("Images")) {
        $moduleBase = (Get-Module -Name "PSProfileMigrationAssistant" -ListAvailable).ModuleBase
        $resolvedImages = @{}

        foreach ($key in $config["Images"].Keys) {
            $fileName = $config["Images"][$key]
            $resolvedPath = Join-Path -Path (Join-Path -Path $moduleBase -ChildPath "Public\Config") -ChildPath $fileName

            if (Test-Path -Path $resolvedPath) {
                $resolvedImages[$key] = $resolvedPath
            } else {
                Write-Warning "Image file not found: $resolvedPath"
                $resolvedImages[$key] = $fileName # Retain original file name
            }
        }

        # Replace the original Images section with resolved paths
        $config["Images"] = $resolvedImages
    }

    return $config
}