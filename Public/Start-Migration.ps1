<#
.SYNOPSIS
Starts the migration process for user data.

.DESCRIPTION
Constructs the source and destination paths and initiates the migration process.
Supports migrating a specific folder if specified.

.PARAMETER SourceUsername
The source username (e.g., "testu").

.PARAMETER DestinationUsername
The destination username (e.g., "test.user").

.PARAMETER SharePath
The shared path containing the user data (e.g., "\\testing\w10-home").

.PARAMETER LogFilePath
The full path to the log file.

.PARAMETER Folder
The specific folder to migrate (e.g., "Desktop"). Optional. If not provided, the entire source directory is migrated.

.PARAMETER DryRun
Optional switch to test the migration process without copying files.

.EXAMPLE
Start-Migration -SourceUsername "testu" -DestinationUsername "test.user" -SharePath "\\testing\w10-home" -LogFilePath "C:\Logs\MigrationLog.log"

.EXAMPLE
Start-Migration -SourceUsername "testu" -DestinationUsername "test.user" -SharePath "\\testing\w10-home" -LogFilePath "C:\Logs\MigrationLog.log" -Folder "Desktop"
#>
function Start-Migration {
    param (
        [Parameter(Mandatory = $True)]
        [string]$SourceUsername,

        [Parameter(Mandatory = $True)]
        [string]$DestinationUsername,

        [Parameter(Mandatory = $True)]
        [string]$SharePath,

        [Parameter(Mandatory = $True)]
        [string]$LogFilePath,

        [Parameter(Mandatory = $False)]
        [string]$Folder, # Optional parameter for a specific folder to migrate

        [switch]$DryRun
    )

    # Construct source and destination base paths
    $sourcePath = Join-Path -Path $SharePath -ChildPath $SourceUsername
    $destinationPath = Join-Path -Path $SharePath -ChildPath $DestinationUsername

    # Initialize the log
    $LogFilePath = Start-Log

    # Call Migrate-UserData with or without the Folder parameter
    if ($PSBoundParameters.ContainsKey('Folder')) {
        Write-Log -Message "INFO: Initiating migration of specific folder: $Folder" -LogFilePath $LogFilePath
        Move-UserData -SourcePath $sourcePath -DestinationPath $destinationPath -LogFilePath $LogFilePath -Folder $Folder
    } else {
        Write-Log -Message "INFO: Initiating full user data migration" -LogFilePath $LogFilePath
        Move-UserData -SourcePath $sourcePath -DestinationPath $destinationPath -LogFilePath $LogFilePath
    }
}