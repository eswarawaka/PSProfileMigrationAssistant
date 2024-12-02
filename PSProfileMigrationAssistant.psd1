@{
    # Script module or binary module file associated with this manifest.
    RootModule = 'PSProfileMigrationAssistant.psm1'

    # Version number of this module.
    ModuleVersion = '2.0.6'

    # ID used to uniquely identify this module
    GUID = '53ecaa23-a0d9-476b-b535-0f1bcb33f380'

    # Author of this module
    Author = 'eswaras'

    # Company or vendor of this module
    CompanyName = ''

    # Copyright statement for this module
    Copyright = '(c) 2024 eswaras. All rights reserved.'

    # Description of the functionality provided by this module
    Description = 'This PowerShell module is designed to migrate profile data from one location to another'

    # Minimum version of the Windows PowerShell engine required by this module
    PowerShellVersion = '5.1'

    # Functions to export from this module
    FunctionsToExport = 'Show-Finalform','Show-MigrationForm','Get-UserSamAccountNameByEmail','Move-UserData','Start-Log','Write-Log','Read-Config','Show-MainForm','Start-Migration','Get-ProfileMigrationShortcut'

    # Cmdlets to export from this module
    CmdletsToExport = @()  # Explicitly empty if none are exported

    # Variables to export from this module
    VariablesToExport = @()  # Explicitly empty if none are exported

    # Aliases to export from this module
    AliasesToExport = @()  # Explicitly empty if none are exported

    # List of all files packaged with this module
    FileList = 'PSProfileMigrationAssistant.psm1', 
               'Private/Show-Finalform.ps1', 
               'Private/Show-MigrationForm.ps1', 
               'Private/Get-UserSamAccountNameByEmail.ps1',  
               'Private/Move-UserData.ps1', 
               'Private/Read-Config.ps1', 
               'Private/Start-Log.ps1', 
               'Private/Write-Log.ps1',  
               'Public/Show-MainForm.ps1',
	           'Public/Get-ProfileMigrationShortcut.ps1', 
               'Public/Start-Migration.ps1',
               'Public/Config/Config.ini'

    # Private data to pass to the module specified in RootModule/ModuleToProcess.
    PrivateData = @{
        PSData = @{
            # Tags applied to this module. These help with module discovery in online galleries.
            Tags = @('ProfileMigration', 'PowerShell', 'Assistant')

            # A URL to the main website for this project.
            ProjectUri = 'https://github.com/eswarawaka/PSProfileMigrationAssistant'

            # A URL to an icon representing this module.
            IconUri = 'https://github.com/eswarawaka/PSProfileMigrationAssistant/icon.png'

            # ReleaseNotes of this module
            ReleaseNotes = 'Initial release of the profile migration assistant.'
        }
    }
}
