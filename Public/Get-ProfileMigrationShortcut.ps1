function Get-ProfileMigrationShortcut {
    param (
        [string]$DefaultShortcutName = "Profile Migration",
        [string]$TargetPath = "powershell.exe",
        [string]$Arguments = "-ExecutionPolicy Bypass -NoProfile -WindowStyle Hidden -Command Show-MainForm"
    )

    try {

        # Step 3: Load and parse the JSON configuration
        $Config = Read-Config

        # Step 4: Resolve shortcut icon
        $ShortcutIconPath =  $Config.Images.Shortcuticon
        if (-not (Test-Path $ShortcutIconPath)) {
            throw "Shortcut icon file not found: $ShortcutIconPath"
        }

        # Step 5: Resolve shortcut name
        $ShortcutNameConfig = $Config.Variables.ShortcutName
        if (-not $ShortcutNameConfig) {
            Write-Warning "Shortcut name not found in configuration. Using default name: $DefaultShortcutName"
            $ShortcutNameConfig = $DefaultShortcutName
        }

        # Step 6: Build the shortcut path
        $ShortcutPath = [System.IO.Path]::Combine([Environment]::GetFolderPath("Desktop"), "$ShortcutNameConfig.lnk")

        # Step 7: Create a COM object for WScript.Shell
        $WScriptShell = New-Object -ComObject WScript.Shell

        # Step 8: Create and configure the shortcut
        $Shortcut = $WScriptShell.CreateShortcut($ShortcutPath)
        $Shortcut.TargetPath = $TargetPath
        $Shortcut.Arguments = $Arguments
        $Shortcut.WorkingDirectory = [Environment]::GetFolderPath("Desktop") # Optional working directory
        $Shortcut.Description = "Shortcut to MainForm"
        $Shortcut.IconLocation = $ShortcutIconPath
        $Shortcut.Save()

        # Step 9: Success message
        Write-Output "Shortcut created successfully: $ShortcutPath"
    }
    catch {
        Write-Error "An error occurred while creating the shortcut: $_"
    }
}