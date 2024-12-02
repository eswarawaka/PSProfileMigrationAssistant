function Show-MainForm {
    # Load configuration
    $FilePath = Join-Path -Path (Get-Module -Name "PSProfileMigrationAssistant" -ListAvailable).ModuleBase -ChildPath "Public\Config\Config.ini"
    $Config = Read-Config -FilePath $FilePath

    # Extract values from the configuration
    $AppName     = $Config.Variables.AppName
    $SupportURL  = $Config.Variables.SupportURL
    $IconBase64  = $Config.Images.ApplicationIcon
    $ImagePath   = $Config.Images.BackgroundImage

    $Description = @(
        $Config.Description.Text1,
        $Config.Description.Text2,
        $Config.Description.Text3,
        $Config.Description.Text4,
        $Config.Description.Text5,
        $Config.Description.Text6
    )

    # Load assemblies and enable visual styles
    [void][System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
    [void][System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
    [System.Windows.Forms.Application]::EnableVisualStyles()

    # Create form
    $form1 = New-Object System.Windows.Forms.Form
    $form1.Text = $AppName
    $form1.Size = New-Object System.Drawing.Size(600, 400)
    $form1.StartPosition = "CenterScreen"
    $form1.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog
    $form1.MaximizeBox = $false
    if (Test-Path $IconBase64) {
        $form1.Icon = New-Object System.Drawing.Icon($IconBase64)
    }

    # Add image to form
    $pictureBox = New-Object System.Windows.Forms.PictureBox
    $pictureBox.ImageLocation = $ImagePath
    $pictureBox.SizeMode = [System.Windows.Forms.PictureBoxSizeMode]::StretchImage
    $pictureBox.Size = New-Object System.Drawing.Size(200, 400)
    $pictureBox.Location = New-Object System.Drawing.Point(0, 0)
    $form1.Controls.Add($pictureBox)

    # Add description box
    $richTextBoxDescription = New-Object System.Windows.Forms.RichTextBox
    $richTextBoxDescription.Location = New-Object System.Drawing.Point(220, 10)
    $richTextBoxDescription.Size = New-Object System.Drawing.Size(360, 250)
    $richTextBoxDescription.ReadOnly = $true
    $richTextBoxDescription.BorderStyle = [System.Windows.Forms.BorderStyle]::None
    $richTextBoxDescription.BackColor = $form1.BackColor
    $richTextBoxDescription.ScrollBars = [System.Windows.Forms.RichTextBoxScrollBars]::None # Remove slider

    # Populate description
    $richTextBoxDescription.SelectionFont = New-Object System.Drawing.Font("Arial", 12, [System.Drawing.FontStyle]::Bold)
    $richTextBoxDescription.SelectionColor = [System.Drawing.Color]::Green
    $richTextBoxDescription.AppendText("Welcome to the $AppName`n`n")

    $richTextBoxDescription.SelectionFont = New-Object System.Drawing.Font("Arial", 10, [System.Drawing.FontStyle]::Regular)
    $richTextBoxDescription.SelectionColor = [System.Drawing.Color]::Black
    $Description | ForEach-Object { $richTextBoxDescription.AppendText("$_`n`n") }

    # Make support link clickable
    $linkText = "Citrix Support"
    $startIndex = $richTextBoxDescription.Text.IndexOf($linkText)
    $richTextBoxDescription.Select($startIndex, $linkText.Length)
    $richTextBoxDescription.SelectionColor = [System.Drawing.Color]::Blue
    $richTextBoxDescription.SelectionFont = New-Object System.Drawing.Font($richTextBoxDescription.Font, [System.Drawing.FontStyle]::Underline)
    $richTextBoxDescription.Select(0, 0)

    # Add mouse click event for the support link
    $richTextBoxDescription.Add_MouseClick({
        param ($sender, $e)
        $position = $richTextBoxDescription.GetPositionFromCharIndex($startIndex)
        $clickableWidth = $richTextBoxDescription.CreateGraphics().MeasureString($linkText, $richTextBoxDescription.SelectionFont).Width
        $clickableHeight = $richTextBoxDescription.SelectionFont.Height
        $clickableRectangle = New-Object System.Drawing.Rectangle($position.X, $position.Y, [int]$clickableWidth, [int]$clickableHeight)

        if ($clickableRectangle.Contains($e.Location)) {
            [System.Diagnostics.Process]::Start($SupportURL)
        }
    })

    $form1.Controls.Add($richTextBoxDescription)

    # Add Next button
    $buttonNext = New-Object System.Windows.Forms.Button
    $buttonNext.Text = "Next"
    $buttonNext.Location = New-Object System.Drawing.Point(450, 310)
    $buttonNext.Size = New-Object System.Drawing.Size(100, 30)
    $buttonNext.BackColor = [System.Drawing.Color]::SteelBlue
    $buttonNext.ForeColor = [System.Drawing.Color]::White
    $buttonNext.Font = New-Object System.Drawing.Font("Arial", 10, [System.Drawing.FontStyle]::Bold)
    $buttonNext.Add_Click({
        $form1.Hide()
        Show-MigrationForm
        $form1.Dispose()
    })
    $form1.Controls.Add($buttonNext)

    # Add an event handler for the X button (top-right corner)
    $form1.Add_FormClosing({
        param($sender, $e)
        # Allow the form to close when the X button is clicked
        $form1.Dispose() # Ensure resources are disposed properly
    })


    # Show the form
    $form1.ShowDialog()
}