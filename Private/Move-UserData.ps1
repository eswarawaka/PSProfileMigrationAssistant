<#
.SYNOPSIS
Handles the migration of user data, optionally for a specific folder.

.DESCRIPTION
Uses Robocopy to copy data from the source to the destination, excluding specific file types.
Supports migrating a specific folder if specified.

.PARAMETER SourcePath
The full path to the source directory.

.PARAMETER DestinationPath
The full path to the destination directory.

.PARAMETER LogFilePath
The full path to the log file.

.PARAMETER Folder
The specific folder to migrate (e.g., "Desktop"). Optional. If not provided, the entire source directory is migrated.

.PARAMETER DryRun
Optional switch to test the migration process without copying files.

.EXAMPLE
Move-UserData -SourcePath "\\testing\w10-home\testu" -DestinationPath "\\testing\w10-home\test.user" -LogFilePath "C:\Logs\MigrationLog.log"

.EXAMPLE
Move-UserData -SourcePath "\\testing\w10-home\testu" -DestinationPath "\\testing\w10-home\test.user" -LogFilePath "C:\Logs\MigrationLog.log" -Folder "Desktop"
#>
function Move-UserData {
    param (
        [Parameter(Mandatory = $True)]
        [string]$SourcePath,

        [Parameter(Mandatory = $True)]
        [string]$DestinationPath,

        [Parameter(Mandatory = $True)]
        [string]$LogFilePath,

        [Parameter(Mandatory = $False)]
        [string]$Folder, # Optional parameter for a specific folder to migrate

        [switch]$DryRun # Optional switch to test without actually copying files
    )

    # Define file exclusions
    $excludedFiles = '*.pst', '*.ost', '*password*'

    # Validate source and destination paths
    if (-not (Test-Path -Path $SourcePath)) {
        Write-Log -Message "ERROR: Source path does not exist: $SourcePath" -LogFilePath $LogFilePath
        throw "Source path does not exist: $SourcePath"
    }
    if (-not (Test-Path -Path $DestinationPath)) {
        New-Item -ItemType Directory -Path $DestinationPath | Out-Null
        Write-Log -Message "INFO: Destination path created: $DestinationPath" -LogFilePath $LogFilePath
    }

    # Adjust source and destination paths if a specific folder is provided
    if ($PSBoundParameters.ContainsKey('Folder')) {
        $SourcePath = Join-Path -Path $SourcePath -ChildPath $Folder
        $DestinationPath = Join-Path -Path $DestinationPath -ChildPath $Folder

        # Validate the specific folder
        if (-not (Test-Path -Path $SourcePath)) {
            Write-Log -Message "ERROR: Specified folder does not exist in the source path: $SourcePath" -LogFilePath $LogFilePath
            throw "Specified folder does not exist: $SourcePath"
        }
    }

    # Log start of migration
    Write-Log -Message "INFO: Starting migration" -LogFilePath $LogFilePath
    Write-Log -Message "SOURCE: $SourcePath" -LogFilePath $LogFilePath
    Write-Log -Message "DESTINATION: $DestinationPath" -LogFilePath $LogFilePath
    Write-Log -Message "EXCLUDED FILE TYPES: $($excludedFiles -join ', ')" -LogFilePath $LogFilePath

    # Define Robocopy command with detailed logging
    $tempLogPath = [System.IO.Path]::GetTempFileName()
    $robocopyParams = @(
        '/E',            # Copy all subdirectories, including empty ones
        '/Z',            # Restartable mode
        '/COPY:DAT',     # Copy data, attributes, and timestamps
        '/R:2',          # Retry twice on failed files
        '/W:1',          # Wait 1 second between retries
        '/MT:16',        # Multithreaded copy
        '/V',            # Verbose logging (detailed file and folder info)
        '/XF',           # Exclude files
        $excludedFiles   # List of excluded files
    )

    $robocopyCommand = "robocopy.exe `"$SourcePath`" `"$DestinationPath`" *.* $($robocopyParams -join ' ') /LOG:`"$tempLogPath`""

    # Dry run mode
    if ($DryRun) {
        Write-Log -Message "DRY-RUN MODE ENABLED: No files will be copied." -LogFilePath $LogFilePath
        Write-Log -Message "DRY-RUN COMMAND: $robocopyCommand" -LogFilePath $LogFilePath
        return
    }

    # Execute Robocopy
    Write-Log -Message "INFO: Executing Robocopy..." -LogFilePath $LogFilePath
    Invoke-Expression -Command $robocopyCommand

    # Check for success
    if ($LASTEXITCODE -le 7) {
        Write-Log -Message "SUCCESS: Migration completed successfully." -LogFilePath $LogFilePath
    } else {
        Write-Log -Message "ERROR: Migration encountered issues. Exit code: $LASTEXITCODE" -LogFilePath $LogFilePath
    }

    # Parse detailed log from temporary Robocopy log
    Write-Log -Message "DETAILS: Files copied during the migration:" -LogFilePath $LogFilePath
    Write-Log -Message "-----------------------------------------------------" -LogFilePath $LogFilePath
    Get-Content -Path $tempLogPath | ForEach-Object {
        if ($_ -match "New File") {
            # Extract the file name only and clean the log format
            $fileName = ($_ -split "New File")[1].Trim() -replace '.*\\', '' # Extract only the file name
            $destinationFilePath = Join-Path -Path $DestinationPath -ChildPath $fileName
            Write-Log -Message "File '$fileName' copied to '$destinationFilePath'" -LogFilePath $LogFilePath
        }
    }
    Write-Log -Message "-----------------------------------------------------" -LogFilePath $LogFilePath

    # Clean up temporary log file
    Remove-Item -Path $tempLogPath -Force
}