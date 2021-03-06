[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") 
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") 

$objForm = New-Object System.Windows.Forms.Form 
$objForm.Text = "Data Entry Form"
$objForm.Size = New-Object System.Drawing.Size(450,200) 
$objForm.StartPosition = "CenterScreen"
$objForm.SizeGripStyle = "Hide"
$objForm.ShowInTaskbar = $False
$objForm.MinimizeBox = $False
$objForm.MaximizeBox = $False
$objForm.Topmost = $true
$Icon = [system.drawing.icon]::ExtractAssociatedIcon($PSHOME + "\powershell.exe")
$objForm.Icon = $Icon

$objForm.KeyPreview = $True
$objForm.Add_KeyDown({if ($_.KeyCode -eq "Enter") 
    {$x=$objTextBox.Text;$objForm.Close()}})
$objForm.Add_KeyDown({if ($_.KeyCode -eq "Escape") 
    {$objForm.Close()}})


$CorpButton = New-Object System.Windows.Forms.Button
$CorpButton.Location = New-Object System.Drawing.Size(25,120)
$CorpButton.Size = New-Object System.Drawing.Size(75,23)
$CorpButton.Text = "Corp"
$CorpButton.Add_Click({$template="Corp";$objForm.Close()})
$objForm.Controls.Add($CorpButton)

$WestButton = New-Object System.Windows.Forms.Button
$WestButton.Location = New-Object System.Drawing.Size(100,120)
$WestButton.Size = New-Object System.Drawing.Size(75,23)
$WestButton.Text = "West"
$WestButton.Add_Click({$template="West";$objForm.Close()})
$objForm.Controls.Add($WestButton)

$EastButton = New-Object System.Windows.Forms.Button
$EastButton.Location = New-Object System.Drawing.Size(175,120)
$EastButton.Size = New-Object System.Drawing.Size(75,23)
$EastButton.Text = "East"
$EastButton.Add_Click({$template="East";$objForm.Close()})
$objForm.Controls.Add($EastButton)

$FrenchButton = New-Object System.Windows.Forms.Button
$FrenchButton.Location = New-Object System.Drawing.Size(250,120)
$FrenchButton.Size = New-Object System.Drawing.Size(75,23)
$FrenchButton.Text = "French"
$FrenchButton.Add_Click({$template="French";$objForm.Close()})
$objForm.Controls.Add($FrenchButton)

$SouthButton = New-Object System.Windows.Forms.Button
$SouthButton.Location = New-Object System.Drawing.Size(325,120)
$SouthButton.Size = New-Object System.Drawing.Size(75,23)
$SouthButton.Text = "South"
$SouthButton.Add_Click({$template="South";$objForm.Close()})
$objForm.Controls.Add($SouthButton)


$objLabel = New-Object System.Windows.Forms.Label
$objLabel.Location = New-Object System.Drawing.Size(10,20) 
$objLabel.Size = New-Object System.Drawing.Size(280,20) 
$objLabel.Text = "Please choose the location of the user"
$objForm.Controls.Add($objLabel) 

$objForm.Topmost = $True

$objForm.Add_Shown({$objForm.Activate()})
[void] $objForm.ShowDialog()

return $template