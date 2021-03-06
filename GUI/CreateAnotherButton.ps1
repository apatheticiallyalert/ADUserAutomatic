[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") 
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") 

$objForm = New-Object System.Windows.Forms.Form 
if($WindowName -ne $null)
{
    $objForm.Text = $WindowName
}
else
{
    $objForm.Text = "Data Entry Form"
}
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

$YesButton = New-Object System.Windows.Forms.Button
$YesButton.Location = New-Object System.Drawing.Size(125,220)
$YesButton.Size = New-Object System.Drawing.Size(75,23)
$YesButton.Text = "YES"
$YesButton.Add_Click({$choice="Y";$objForm.Close()})
$objForm.Controls.Add($YesButton)

$NoButton = New-Object System.Windows.Forms.Button
$NoButton.Location = New-Object System.Drawing.Size(225,220)
$NoButton.Size = New-Object System.Drawing.Size(75,23)
$NoButton.Text = "NO"
$NoButton.Add_Click({$choice="N";$objForm.Close()})
$objForm.Controls.Add($NoButton)

$objLabel = New-Object System.Windows.Forms.Label
$objLabel.Location = New-Object System.Drawing.Size(10,20) 
$objLabel.Size = New-Object System.Drawing.Size(425,200) 
$objLabel.Text = $ButtonLabel
$objForm.Controls.Add($objLabel) 

$objForm.Topmost = $True

$objForm.Add_Shown({$objForm.Activate()})
[void] $objForm.ShowDialog()

return $choice