<#
.SYNOPSIS
Initializes a log file by ensuring the directory exists and creating the file if needed.

.DESCRIPTION
The `Start-Log` function checks if the specified log directory exists. If it does not exist, 
it attempts to create the directory. If the directory cannot be created (e.g., due to insufficient 
permissions), the function falls back to the user's profile directory. It then creates a log file 
named `Migration_YYYY_MM_DD.log` with the current date in the format `2024_10_24`. The log file is 
initialized with a timestamp entry.

.PARAMETER LogDirectory
(Optional) The path to the directory where the log file should be created. Defaults to `C:\Logs`. 
If the directory cannot be created, the user's profile directory (`$env:USERPROFILE`) is used instead.

.OUTPUTS
The function returns the full path to the initialized log file.

.EXAMPLES
# Example 1: Default directory (C:\Logs)
$LogFilePath = Start-Log
Write-Host "Log file initialized at: $LogFilePath"

# Example 2: Specify a custom directory
$LogFilePath = Start-Log -LogDirectory "D:\CustomLogs"
Write-Host "Log file initialized at: $LogFilePath"

# Example 3: Handle fallback to the user profile directory
$LogFilePath = Start-Log
Write-Host "Log file initialized at: $LogFilePath"

.NOTES
Author: Your Name
Date: YYYY-MM-DD
Version: 1.0

#>
function Start-Log {
    param (
        [Parameter(Mandatory = $false)]
        [string]$LogDirectory = "C:\Logs"
    )

    # Check if the provided directory exists
    if (-not (Test-Path -Path $LogDirectory)) {
        try {
            # Attempt to create the directory
            New-Item -ItemType Directory -Path $LogDirectory -ErrorAction Stop | Out-Null
        } catch {
            # If unable to create, fall back to the user's profile directory
            $LogDirectory = "$env:USERPROFILE"
        }
    }

    # Define log file name with current date
    $LogFileName = "Migration_$(Get-Date -Format 'yyyy_MM_dd').log"
    $LogFilePath = Join-Path -Path $LogDirectory -ChildPath $LogFileName

    # Check if the log file exists, create if not
    if (-not (Test-Path -Path $LogFilePath)) {
        New-Item -ItemType File -Path $LogFilePath | Out-Null
    }

    # Return the log file path
    return $LogFilePath
}
