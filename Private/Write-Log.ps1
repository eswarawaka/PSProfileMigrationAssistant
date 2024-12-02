<#
.SYNOPSIS
Writes a log entry with a timestamp.

.DESCRIPTION
Adds a timestamped message to the specified log file.

.PARAMETER Message
The message to log.

.PARAMETER LogFilePath
The full path to the log file.

.EXAMPLE
Write-Log -Message "Migration started" -LogFilePath "C:\Logs\MigrationLog.log"
#>
function Write-Log {
    param (
        [Parameter(Mandatory = $True)]
        [string]$Message,

        [Parameter(Mandatory = $True)]
        [string]$LogFilePath
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content -Path $LogFilePath -Value "[$timestamp] $Message"
}
