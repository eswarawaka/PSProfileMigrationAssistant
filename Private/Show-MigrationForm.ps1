function Show-MigrationForm {
    
    $FilePath = Join-Path -Path (Get-Module -Name "PSProfileMigrationAssistant" -ListAvailable).ModuleBase -ChildPath "Public\Config\Config.ini"
    $Config = Read-Config -FilePath $FilePath

    # Extract configuration values
    $AppName     = $Config.Variables.AppName
    $IconBase64  = $Config.Images.ApplicationIcon
    $ImagePath   = $Config.Images.BackgroundImage
    $NextPath     = $Config.Images.NextButtonImage
    $rightImage   = $Config.Images.TickMarkImage
    $crossImage   = $Config.Images.CloseButtonImage
    $Domain1      = $Config.Domain.Domain1
    $Domain2      = $Config.Domain.Domain2
    $FileServer1  = $Config.FileShares.FileserverTest
    $FileServer2  = $Config.FileShares.FileServerProd
    $PrimaryCatalog = $Config.Variables.PrimaryCatalog
    $radiovalue1 = $Config.RadioButtons.Option1
    $radiovalue2 = $Config.RadioButtons.Option2

    # Dynamically Create and Add Radio Buttons
    $radioButtons = @()

    # Initialize form
    [void][System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
    [void][System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
    [System.Windows.Forms.Application]::EnableVisualStyles()

    $LogFilePath = Start-Log
    Write-Log -Message "Log file initialized at: $LogFilePath" -LogFilePath $LogFilePath


    $form2 = New-Object System.Windows.Forms.Form
    $form2.Text = $AppName
    $form2.Size = New-Object System.Drawing.Size(600, 400)
    $form2.StartPosition = "CenterScreen"
    $form2.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog
    $form2.MaximizeBox = $false
    if (Test-Path $IconBase64) {
        $form2.Icon = New-Object System.Drawing.Icon($IconBase64)
    }


    # Add left-side image
    $pictureBox = New-Object System.Windows.Forms.PictureBox
    $pictureBox.ImageLocation = $ImagePath
    $pictureBox.SizeMode = [System.Windows.Forms.PictureBoxSizeMode]::StretchImage
    $pictureBox.Size = New-Object System.Drawing.Size(200, 400)
    $pictureBox.Location = New-Object System.Drawing.Point(0, 0)
    $form2.Controls.Add($pictureBox)

    # Add panel for controls
    $panel = New-Object System.Windows.Forms.Panel
    $panel.Location = New-Object System.Drawing.Point(220, 10)
    $panel.Size = New-Object System.Drawing.Size(360, 350)
    $form2.Controls.Add($panel)

    # Create PictureBox inside the panel for the icon
    $iconBox = New-Object System.Windows.Forms.PictureBox
    $iconBox.Size = New-Object System.Drawing.Size(20, 20)
    $iconBox.Location = New-Object System.Drawing.Point(320, 35) # Position next to the TextBox
    $iconBox.SizeMode = [System.Windows.Forms.PictureBoxSizeMode]::StretchImage
    $panel.Controls.Add($iconBox)

    # Email input
    $labelEmail = New-Object System.Windows.Forms.Label
    $labelEmail.Text = "Enter your email address:"
    $labelEmail.Location = New-Object System.Drawing.Point(10, 10)
    $labelEmail.Size = New-Object System.Drawing.Size(200, 20)
    $panel.Controls.Add($labelEmail)

    $textBoxEmail = New-Object System.Windows.Forms.TextBox
    $textBoxEmail.Location = New-Object System.Drawing.Point(10, 35)
    $textBoxEmail.Size = New-Object System.Drawing.Size(300, 20)
    $panel.Controls.Add($textBoxEmail)

    # Migration dropdown
    $labelMigrateProfile = New-Object System.Windows.Forms.Label
    $labelMigrateProfile.Text = "Do you want your profile to be migrated?"
    $labelMigrateProfile.Location = New-Object System.Drawing.Point(10, 70)
    $labelMigrateProfile.Size = New-Object System.Drawing.Size(300, 20)
    $labelMigrateProfile.Visible = $false
    $panel.Controls.Add($labelMigrateProfile)

    $comboBoxMigrateProfile = New-Object System.Windows.Forms.ComboBox
    $comboBoxMigrateProfile.Items.AddRange(@("Yes", "No"))
    $comboBoxMigrateProfile.Location = New-Object System.Drawing.Point(10, 95)
    $comboBoxMigrateProfile.Size = New-Object System.Drawing.Size(300, 20)
    $comboBoxMigrateProfile.DropDownStyle = "DropDownList"
    $comboBoxMigrateProfile.Visible = $false
    $panel.Controls.Add($comboBoxMigrateProfile)

    # VDI profile selection
    $labelVDIProfile = New-Object System.Windows.Forms.Label
    $labelVDIProfile.Text = "Select the VDI Profile you want to migrate:"
    $labelVDIProfile.Location = New-Object System.Drawing.Point(10, 130)
    $labelVDIProfile.Size = New-Object System.Drawing.Size(300, 20)
    $labelVDIProfile.Visible = $false
    $panel.Controls.Add($labelVDIProfile)

    # Dynamically Create and Add Radio Buttons
    $radioButton = New-Object System.Windows.Forms.RadioButton
    $radioButton.Text = $radiovalue1
    $radioButton.Location = New-Object System.Drawing.Point(10, 155)
    $radioButton.Size = New-Object System.Drawing.Size(50, 20)
    $radioButton.Visible = $false
    if ([string]::IsNullOrWhiteSpace($radioButton.Text)) {
        $panel.Controls.Remove($radioButton)
    } else {
        $panel.Controls.Add($radioButton)
        $radioButtons += $radioButton
    }


    # Add CheckedChanged Event for Option1
    $radioButton.Add_CheckedChanged({
        if ($radioButton.Checked) {
            if ($radioButton.Text -match "Test") {
                Set-Variable -Name networkpathvariable -Scope Global -Value $FileServer1
                Write-Host "Test selected: Connecting to Test server at $FileServer1"
            } elseif ($radioButton.Text -match "Prod") {
                Set-Variable -Name networkpathvariable -Scope Global -Value $FileServer2
                Write-Host "Prod selected: Connecting to Prod server at $FileServer2"
            } else {
                Write-Host "Unknown option selected: $($radioButton.Text)"
            }
        }
    })


    $radioButtonProd = New-Object System.Windows.Forms.RadioButton
    $radioButtonProd.Text = $radiovalue2
    $radioButtonProd.Tag = "Prod" # Store the key for later use
    $radioButtonProd.Location = New-Object System.Drawing.Point(70, 155)
    $radioButtonProd.Size = New-Object System.Drawing.Size(50, 20)
    $radioButtonProd.Visible = $false
    
    #$panel.Controls.Add($radioButtonProd)

    if ([string]::IsNullOrWhiteSpace($radioButtonProd.Text)) {
        $panel.Controls.Remove($radioButtonProd)
    } else {
        $panel.Controls.Add($radioButtonProd)
        $radioButtons += $radioButtonProd
    }

    # Add CheckedChanged Event for Option2
    $radioButtonProd.Add_CheckedChanged({
        if ($radioButtonProd.Checked) {
            if ($radioButtonProd.Text -match "Test") {
                Set-Variable -Name networkpathvariable -Scope Global -Value $FileServer1
                Write-Host "Test selected: Connecting to Test server at $FileServer1"
            } elseif ($radioButtonProd.Text -match "Prod") {
                Set-Variable -Name networkpathvariable -Scope Global -Value $FileServer2
                Write-Host "Prod selected: Connecting to Prod server at $FileServer2"
            } else {
                Write-Host "Unknown option selected: $($radioButton.Text)"
            }
        }
    })

# Auto-select if only one radio button exists
if ($radioButtons.Count -eq 1) {
    $radioButtons[0].Checked = $true
    Write-Host "Auto-selected: $($radioButtons[0].Text)"
}


    # Data migration options
    $labelDataMigration = New-Object System.Windows.Forms.Label
    $labelDataMigration.Text = "Select the Data you want to migrate:"
    $labelDataMigration.Location = New-Object System.Drawing.Point(10, 190)
    $labelDataMigration.Size = New-Object System.Drawing.Size(300, 20)
    $labelDataMigration.Visible = $false
    $panel.Controls.Add($labelDataMigration)

    $checkDesktop = New-Object System.Windows.Forms.CheckBox
    $checkDesktop.Text = "Desktop"
    $checkDesktop.Location = New-Object System.Drawing.Point(10, 215)
    $checkDesktop.Size = New-Object System.Drawing.Size(100, 20)
    $checkDesktop.Visible = $false
    $panel.Controls.Add($checkDesktop)

    $checkDocuments = New-Object System.Windows.Forms.CheckBox
    $checkDocuments.Text = "Documents"
    $checkDocuments.Location = New-Object System.Drawing.Point(120, 215)
    $checkDocuments.Size = New-Object System.Drawing.Size(100, 20)
    $checkDocuments.Visible = $false
    $panel.Controls.Add($checkDocuments)

    $checkDownloads = New-Object System.Windows.Forms.CheckBox
    $checkDownloads.Text = "Downloads"
    $checkDownloads.Location = New-Object System.Drawing.Point(10, 240)
    $checkDownloads.Size = New-Object System.Drawing.Size(100, 20)
    $checkDownloads.Visible = $false
    $panel.Controls.Add($checkDownloads)

    $checkCompleteProfile = New-Object System.Windows.Forms.CheckBox
    $checkCompleteProfile.Text = "Complete Profile"
    $checkCompleteProfile.Location = New-Object System.Drawing.Point(120, 240)
    $checkCompleteProfile.Size = New-Object System.Drawing.Size(150, 20)
    $checkCompleteProfile.Visible = $false
    $panel.Controls.Add($checkCompleteProfile)

    # Add buttons
    $buttonMigrate = New-Object System.Windows.Forms.Button
    $buttonMigrate.Text = "Migrate Now"
    $buttonMigrate.Location = New-Object System.Drawing.Point(10, 275)
    $buttonMigrate.Size = New-Object System.Drawing.Size(200, 30)
    $buttonMigrate.BackColor = [System.Drawing.Color]::SteelBlue
    $buttonMigrate.ForeColor = [System.Drawing.Color]::White
    $buttonMigrate.Font = New-Object System.Drawing.Font("Arial", 10, [System.Drawing.FontStyle]::Bold)
    $buttonMigrate.Visible = $false
    $panel.Controls.Add($buttonMigrate)

    $buttonFinish = New-Object System.Windows.Forms.Button
    $buttonFinish.Location = New-Object System.Drawing.Point(320, 300)
    $buttonFinish.Size = New-Object System.Drawing.Size(40, 40)
    $buttonFinish.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $buttonFinish.FlatAppearance.BorderSize = 0   # Remove border
    $buttonFinish.FlatAppearance.MouseDownBackColor = [System.Drawing.Color]::Transparent # Remove click background
    $buttonFinish.FlatAppearance.MouseOverBackColor = [System.Drawing.Color]::Transparent # Remove hover background
    $buttonFinish.BackColor = [System.Drawing.Color]::Transparent # Transparent background
    $buttonFinish.TabStop = $false  # Prevent focus on click
    $buttonFinish.Visible = $false
    if (Test-Path $NextPath) {
        $icon = [System.Drawing.Image]::FromFile($NextPath)
        $resizedIcon = New-Object System.Drawing.Bitmap($icon, 40, 40)
        $buttonFinish.Image = $resizedIcon
        $buttonFinish.ImageAlign = [System.Drawing.ContentAlignment]::MiddleCenter
    }
    $buttonFinish.FlatAppearance.BorderSize = 0 
    $panel.Controls.Add($buttonFinish)

    # Add progress bar
    $progressBar = New-Object System.Windows.Forms.ProgressBar
    $progressBar.Location = New-Object System.Drawing.Point(10, 310)
    $progressBar.Size = New-Object System.Drawing.Size(300, 25)
    $progressBar.Minimum = 0
    $progressBar.Maximum = 100
    $progressBar.Value = 0
    $progressBar.Visible = $false
    $panel.Controls.Add($progressBar)


    # Migrate button click event
    $buttonMigrate.Add_Click({
        # Disable buttons and reset progress
        $buttonMigrate.Enabled = $false
        $checkDesktop.Enabled = $false
        $checkDocuments.Enabled = $false
        $checkDownloads.Enabled = $false
        $checkCompleteProfile.Enabled = $false
        $progressBar.Value = 0
    
        # Retrieve the source username from the email
        $sAMAccountName = Get-UserSamAccountNameByEmail -EmailAddress $($textBoxEmail.Text) -PrimaryCatalog $PrimaryCatalog
    
        # Ensure username is retrieved before proceeding
        if (-not $sAMAccountName) {
            [System.Windows.Forms.MessageBox]::Show("Failed to retrieve the source username. Please verify the email address.", "Error")
            $buttonMigrate.Enabled = $true
            return
        }
    
        # Display progress bar
        $progressBar.Visible = $true
    
        if ($checkCompleteProfile.Checked) {
            # Full Profile Migration
            $progressBar.Maximum = 100
            Start-Migration -SourceUsername $sAMAccountName -DestinationUsername $env:USERNAME -SharePath $networkpathvariable -LogFilePath $LogFilePath
            $progressBar.Value = 100
            $buttonFinish.Visible = $true
        } else {
            # Partial Migration for selected folders
            $foldersToMigrate = @()
            if ($checkDesktop.Checked) { $foldersToMigrate += "Desktop" }
            if ($checkDocuments.Checked) { $foldersToMigrate += "Documents" }
            if ($checkDownloads.Checked) { $foldersToMigrate += "Downloads" }
    
            if ($foldersToMigrate.Count -gt 0) {
                $progressBar.Maximum = $foldersToMigrate.Count * 10
                $progressBar.Value = 0
    
                foreach ($folder in $foldersToMigrate) {
                    try {
                        Start-Migration -SourceUsername $sAMAccountName -DestinationUsername $env:USERNAME -SharePath $networkpathvariable -LogFilePath $LogFilePath -Folder $folder
                        $progressBar.Value += 10
                        Start-Sleep -Milliseconds 500
                    } catch {
                        Write-Host "Failed to migrate folder: $folder"
                        [System.Windows.Forms.MessageBox]::Show("Migration failed for folder: $folder", "Error")
                    }
                }
    
                $progressBar.Value = $progressBar.Maximum
                $buttonFinish.Visible = $true
            } else {
                [System.Windows.Forms.MessageBox]::Show("Please select either 'Full Profile' or individual folders to migrate.", "No Migration Selected")
            }
        }
    
        # Re-enable the Migrate button
        $buttonMigrate.Enabled = $true
    })


    # Helper function to set visibility for migration controls
    function Set-MigrationControlsVisibility {
        param (
            [bool]$Visible
        )
        $labelVDIProfile.Visible = $Visible
        $radioButton.Visible = $Visible
        $radioButtonProd.Visible = $Visible
        $labelDataMigration.Visible = $Visible
        $checkDesktop.Visible = $Visible
        $checkDocuments.Visible = $Visible
        $checkDownloads.Visible = $Visible
        $checkCompleteProfile.Visible = $Visible
        $buttonMigrate.Visible = $Visible
    }
    
    # ComboBox SelectedIndexChanged Event
    $comboBoxMigrateProfile.Add_SelectedIndexChanged({
        if ($comboBoxMigrateProfile.SelectedItem -eq "Yes") {
            Set-MigrationControlsVisibility -Visible $true
        } elseif ($comboBoxMigrateProfile.SelectedItem -eq "No") {
            [System.Windows.Forms.MessageBox]::Show("Migration Cancelled")
            $form2.Close()
        }
    })

     
     #Textbox text changeevent
     $textBoxEmail.Add_TextChanged({
         $email = $textBoxEmail.Text.Trim()
     
         if (-not [string]::IsNullOrWhiteSpace($email)) {
             if ($email -like "*$Domain1" -or $email -like "*$Domain2") {
                 $isValid = Get-UserSamAccountNameByEmail -EmailAddress $email -PrimaryCatalog $PrimaryCatalog
                 
                 if ($isValid -ne $null) {
                     Write-Log -Message "The SamAccountname of the user with email Adrress $email : $isValid" -LogFilePath $LogFilePath
                     $iconBox.ImageLocation = $rightImage
                     $labelMigrateProfile.Visible = $true
                     $comboBoxMigrateProfile.Visible = $true
                     $textBoxEmail.ReadOnly = $true
                 } else {
                     Write-Log -Message "The Email Adrress $email entered is incorrect" -LogFilePath $LogFilePath
                     $iconBox.ImageLocation = $crossImage
                     $labelMigrateProfile.Visible = $false
                     $comboBoxMigrateProfile.Visible = $false
                 }
             } else {
                 $iconBox.ImageLocation = $crossImage
                 $labelMigrateProfile.Visible = $false
                 $comboBoxMigrateProfile.Visible = $false
             }
         } else {
             $iconBox.Image = $null
             $labelMigrateProfile.Visible = $false
             $comboBoxMigrateProfile.Visible = $false
         }
     })

     # Helper function to handle mutually exclusive checkbox selection
     function Update-Checkboxes {
         param (
             [System.Windows.Forms.CheckBox]$Current,
             [System.Windows.Forms.CheckBox[]]$Others
         )
     
         # If the current checkbox is checked, uncheck the others
         if ($Current.Checked) {
             foreach ($checkbox in $Others) {
                 $checkbox.Checked = $false
             }
         }
     }
     
     # Full Profile Migration Select Event
     $checkCompleteProfile.Add_CheckedChanged({
         Update-Checkboxes -Current $checkCompleteProfile -Others @($checkDesktop, $checkDocuments, $checkDownloads)
     })
     
     # Individual Folders Migration Select Events
     $checkDesktop.Add_CheckedChanged({
         Update-Checkboxes -Current $checkDesktop -Others @($checkCompleteProfile)
     })
     
     $checkDocuments.Add_CheckedChanged({
         Update-Checkboxes -Current $checkDocuments -Others @($checkCompleteProfile)
     })
     
     $checkDownloads.Add_CheckedChanged({
         Update-Checkboxes -Current $checkDownloads -Others @($checkCompleteProfile)
     })


     $buttonFinish.Add_Click({
         $form2.Hide()
         Show-FinalForm
         $form2.Dispose()
     })


    $form2.ShowDialog()
}
