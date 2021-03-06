[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") 
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") 

$objForm = New-Object System.Windows.Forms.Form 
$objForm.Text = "Line Entry Form"

$objForm.Size = New-Object System.Drawing.Size(450,280) 
$objForm.StartPosition = "CenterScreen"
$objForm.SizeGripStyle = "Hide"
$objForm.ShowInTaskbar = $False
$objForm.MinimizeBox = $False
$objForm.MaximizeBox = $False
$objForm.Topmost = $true
$font = New-Object System.Drawing.Font("Times New Roman",13,[system.drawing.fontstyle]::regular)
$objForm.Font = $font

$Icon = [system.drawing.icon]::ExtractAssociatedIcon($PSHOME + "\powershell.exe")
$objForm.Icon = $Icon

$objForm.KeyPreview = $True
$objForm.Add_KeyDown({if ($_.KeyCode -eq "Enter") 
    {$x=$objTextBox.Text;$objForm.Close()}})
$objForm.Add_KeyDown({if ($_.KeyCode -eq "Escape") 
    {$objForm.Close()}})

$objTextBox = New-Object System.Windows.Forms.TextBox 
$objTextBox.Location = New-Object System.Drawing.Size(192,85) 
$objTextBox.Size = New-Object System.Drawing.Size(65,20) 
$objForm.Controls.Add($objTextBox) 

$YesButton = New-Object System.Windows.Forms.Button
$YesButton.Location = New-Object System.Drawing.Size(110,220)
$YesButton.Size = New-Object System.Drawing.Size(100,23)
$YesButton.Text = "SUBMIT"
$YesButton.Add_Click({$choice=$objTextBox.Text;$objForm.Close()})
$objForm.Controls.Add($YesButton)

$CancelButton = New-Object System.Windows.Forms.Button
$CancelButton.Location = New-Object System.Drawing.Size(240,220)
$CancelButton.Size = New-Object System.Drawing.Size(100,23)
$CancelButton.Text = "CANCEL"
$CancelButton.Add_Click({$choice="Exit"; $objForm.Close()})
$objForm.Controls.Add($CancelButton)

$objLabel = New-Object System.Windows.Forms.Label
$objLabel.Location = New-Object System.Drawing.Size(100,20) 
$objLabel.Size = New-Object System.Drawing.Size(425,200) 
$objLabel.Text = "Enter the line of the user to process"
$objForm.Controls.Add($objLabel) 

$objForm.Topmost = $True

$objForm.Add_Shown({$objForm.Activate()})
[void] $objForm.ShowDialog()

$exit = $choice
return $objTextBox.Text