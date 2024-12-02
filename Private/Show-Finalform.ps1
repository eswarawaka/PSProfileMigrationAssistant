function Show-Finalform {

    $FilePath = Join-Path -Path (Get-Module -Name "PSProfileMigrationAssistant" -ListAvailable).ModuleBase -ChildPath "Public\Config\Config.ini"
    $Config = Read-Config -FilePath $FilePath

    # Extract configuration values
    $AppName     = $Config.Variables.AppName
    $SupportURL  = $Config.Variables.SupportURL
    $ImagePaths  = $Config.Images.Paths
    $IconBase64  = $Config.Images.ApplicationIcon
    $ImagePath   = $Config.Images.BackgroundImage
    $LogoffPath  = $Config.Images.LogoffButtonImage

    $LogFilePath = Start-Log
    Write-Log -Message "Migration completed Successfully,do find the log here: $LogFilePath" -LogFilePath $LogFilePath

    # Initialize form
    [void][System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
    [void][System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
    [System.Windows.Forms.Application]::EnableVisualStyles()

    # Create Form
    $form3 = New-Object System.Windows.Forms.Form
    $form3.Text = $AppName
    $form3.Size = New-Object System.Drawing.Size(600, 400)
    $form3.StartPosition = "CenterScreen"
    $form3.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog
    $form3.MaximizeBox = $false
    if (Test-Path $IconBase64) {
        $form3.Icon = New-Object System.Drawing.Icon($IconBase64)
    }

    # Left-side Image
    $pictureBox = New-Object System.Windows.Forms.PictureBox
    $pictureBox.ImageLocation = $ImagePath
    $pictureBox.SizeMode = [System.Windows.Forms.PictureBoxSizeMode]::StretchImage
    $pictureBox.Size = New-Object System.Drawing.Size(200, 400)
    $pictureBox.Location = New-Object System.Drawing.Point(0, 0)
    $form3.Controls.Add($pictureBox)

    # RichTextBox for Description
    $richTextBoxDescription = New-Object System.Windows.Forms.RichTextBox
    $richTextBoxDescription.Location = New-Object System.Drawing.Point(220, 10)
    $richTextBoxDescription.Size = New-Object System.Drawing.Size(350, 170)
    $richTextBoxDescription.ReadOnly = $true
    $richTextBoxDescription.BorderStyle = [System.Windows.Forms.BorderStyle]::None
    $richTextBoxDescription.BackColor = $form3.BackColor

    $richTextBoxDescription.SelectionFont = New-Object System.Drawing.Font("Arial", 12, [System.Drawing.FontStyle]::Bold)
    $richTextBoxDescription.SelectionColor = [System.Drawing.Color]::Green
    $richTextBoxDescription.AppendText("Your Data is successfully Migrated`n`n")

    $richTextBoxDescription.SelectionFont = New-Object System.Drawing.Font("Arial", 10, [System.Drawing.FontStyle]::Regular)
    $richTextBoxDescription.SelectionColor = [System.Drawing.Color]::Black
    $richTextBoxDescription.AppendText("Do make sure to sign out from the VDI and sign in back to access your data.`n`n")
    $richTextBoxDescription.AppendText("- If you have selected the Full Profile Migration, sign out from the VDI and sign in back.`n`n")
    $richTextBoxDescription.AppendText("- If you encounter issues, please contact Citrix Support.")

    $linkText = "Citrix Support"
    $startIndex = $richTextBoxDescription.Text.IndexOf($linkText)
    $richTextBoxDescription.Select($startIndex, $linkText.Length)
    $richTextBoxDescription.SelectionColor = [System.Drawing.Color]::Blue
    $richTextBoxDescription.SelectionFont = New-Object System.Drawing.Font($richTextBoxDescription.Font, [System.Drawing.FontStyle]::Underline)
    $richTextBoxDescription.Select(0, 0)

    $form3.Controls.Add($richTextBoxDescription)

    # Log Off Button
    $buttonLogOff = New-Object System.Windows.Forms.Button
    $buttonLogOff.Location = New-Object System.Drawing.Point(450, 175)
    $buttonLogOff.Size = New-Object System.Drawing.Size(45, 45)
    if (Test-Path $LogoffPath) {
        $icon = [System.Drawing.Image]::FromFile($LogoffPath)
        $resizedIcon = New-Object System.Drawing.Bitmap($icon, 40, 40)
        $buttonLogOff.Image = $resizedIcon
        $buttonLogOff.ImageAlign = [System.Drawing.ContentAlignment]::MiddleCenter
    }
    $buttonLogOff.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $buttonLogOff.FlatAppearance.BorderSize = 0
    $buttonLogOff.FlatAppearance.MouseOverBackColor = $buttonLogOff.BackColor
    $buttonLogOff.FlatAppearance.MouseDownBackColor = $buttonLogOff.BackColor
    $buttonLogOff.BackColor = [System.Drawing.SystemColors]::Control

    $buttonLogOff.Add_Click({
        $result = [System.Windows.Forms.MessageBox]::Show("Are you sure you want to log off?", "Confirm Log Off", [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Question)
        if ($result -eq [System.Windows.Forms.DialogResult]::Yes) {
            Start-Process -FilePath "C:\Windows\System32\shutdown.exe" -ArgumentList "/l"
        }
    })

    $form3.Controls.Add($buttonLogOff)

    # Logoff Label
    $logoffbuttonlabel = New-Object System.Windows.Forms.Label
    $logoffbuttonlabel.Text = "Click here to Sign out from the VDI: "
    $logoffbuttonlabel.Location = New-Object System.Drawing.Point(225, 190)
    $logoffbuttonlabel.Size = New-Object System.Drawing.Size(250, 34)
    $logoffbuttonlabel.Font = New-Object System.Drawing.Font("Arial", 10, [System.Drawing.FontStyle]::Bold)
    $form3.Controls.Add($logoffbuttonlabel)

    #Logfile
    $hyperlink = New-Object System.Windows.Forms.LinkLabel
    $hyperlink.Text = "Click here to view the Logs"
    $hyperlink.Location = New-Object System.Drawing.Point(225, 240)
    $hyperlink.AutoSize = $true
    $hyperlink.LinkColor = [System.Drawing.Color]::Blue
    $hyperlink.ActiveLinkColor = [System.Drawing.Color]::Red
    $hyperlink.VisitedLinkColor = [System.Drawing.Color]::Purple
    $hyperlink.Font = New-Object System.Drawing.Font("Arial", 10, [System.Drawing.FontStyle]::Underline)

    # Add Click Event to Open the Log File
    $hyperlink.Add_LinkClicked({
        if (Test-Path $logFilePath) {
            Start-Process notepad.exe $logFilePath
        } else {
            [System.Windows.Forms.MessageBox]::Show("Log file not found at $logFilePath", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        }
    })
    
    # Add Hyperlink to the Form
    $form3.Controls.Add($hyperlink)


    # Close Button
    $buttonNext = New-Object System.Windows.Forms.Button
    $buttonNext.Text = "Close"
    $buttonNext.Location = New-Object System.Drawing.Point(475, 310)
    $buttonNext.Size = New-Object System.Drawing.Size(80, 30)
    $buttonNext.BackColor = [System.Drawing.Color]::SteelBlue
    $buttonNext.ForeColor = [System.Drawing.Color]::White
    $buttonNext.Font = New-Object System.Drawing.Font("Arial", 10, [System.Drawing.FontStyle]::Bold)
    $buttonNext.Add_Click({
        $form3.Close()
        $form3.Dispose()
    })



    $form3.Controls.Add($buttonNext)

    # Show the form
    $form3.ShowDialog()
}
