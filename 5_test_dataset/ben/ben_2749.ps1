function EQControls2
{
.'C:\Users\Paul\Desktop\Powershell Scripts\ArrangeWindows.ps1'

$Global:EQPath = 'C:\Users\Public\Daybreak Game Company\Installed Games\EverQuest\'
$Global:EQInstall = 'test'

$ButtonLength = 45
$ButtonHight = 17
$StandardWidth = $ButtonLength
$StandardHight = $ButtonHight

$DesiredRows = 7
$DesiredColumns = 7

$FormSizeX = ($ButtonLength*$DesiredColumns) + ($ButtonLength*$DesiredColumns*.07) <# weird math to account for a module I cannot load into regular powershell that differes from ISE#>
$FormSizeY = ($ButtonHight*$DesiredRows) + ($ButtonHight*$DesiredRows*.07) <# weird math to account for a module I cannot load into regular powershell that differes from ISE#>

$CenterOfFormX = [math]::truncate($FormSizeX/2)
$CenterOfFormY = [math]::truncate($FormSizeY/2)

$ColumnX1 = 0
$ColumnX2 = $ButtonLength
$ColumnX3 = $ButtonLength * 2
$ColumnX4 = $ButtonLength * 3
$ColumnX5 = $ButtonLength * 4
$ColumnX6 = $ButtonLength * 5
$ColumnX7 = $ButtonLength * 6
$ColumnX8 = $ButtonLength * 7
$ColumnX9 = $ButtonLength * 8
$ColumnX10 = $ButtonLength * 9


$RowY1 = 0
$RowY2 = $ButtonHight
$RowY3 = $ButtonHight * 2
$RowY4 = $ButtonHight * 3
$RowY5 = $ButtonHight * 4
$RowY6 = $ButtonHight * 5
$RowY7 = $ButtonHight * 6
$RowY8 = $ButtonHight * 7
$RowY9 = $ButtonHight * 8
$RowY10 = $ButtonHight * 9

$form2 = New-Object System.Windows.Forms.Form
$form2.Text = 'EQ Windows Controls'
$form2.Size = New-Object System.Drawing.Size(($FormSizeX),($FormSizeY))
$Form2.maximumsize = New-Object System.Drawing.Size(($FormSizeX),($FormSizeY))
$form2.StartPosition = '0'
$form2.location = New-Object System.Drawing.Point(732,121)
$Form2.backcolor = [System.Drawing.Color]::DarkGray
$form2.TopMost = $true
$form2.FormBorderStyle = 'FixedDialog'

$EQInstallLabel= New-Object system.Windows.Forms.Label
$EQInstallLabel.text = 'Server'
$EQInstallLabel.AutoSize = $True
$EQInstallLabel.location = New-Object System.Drawing.Point(($ColumnX1),($RowY1))
$EQInstallLabel.Font = New-Object System.Drawing.Font('Microsoft Sans Serif',6.5)
$EQInstallLabel.TextAlign = 'MiddleCenter'
$form2.Controls.Add($EQInstallLabel)

$ToggleTestServer = New-Object System.Windows.Forms.Button
$ToggleTestServer.Location = New-Object System.Drawing.Point(($ColumnX2),($RowY1))
$ToggleTestServer.Size = New-Object System.Drawing.Size($StandardHight,$StandardHight)
$ToggleTestServer.Text = 'T'
$ToggleTestServer.Add_Click({$Global:EQPath = 'C:\Users\Public\Daybreak Game Company\Installed Games\EverQuest\' ; $Global:EQInstall = 'test'})
$ToggleTestServer.BackColor = [System.Drawing.Color]::LightGray
$ToggleTestServer.font = New-Object System.Drawing.Font("Microsoft Sans Serif", 6.5)
$form2.Controls.Add($ToggleTestServer)

$ToggleLiveServer = New-Object System.Windows.Forms.Button
$ToggleLiveServer.Location = New-Object System.Drawing.Point(($ColumnX2+$StandardHight),($RowY1))
$ToggleLiveServer.Size = New-Object System.Drawing.Size($StandardHight,$StandardHight)
$ToggleLiveServer.Text = 'L'
$ToggleLiveServer.Add_Click({$Global:EQPath = 'C:\Users\Public\Daybreak Game Company\Installed Games\EverQuest #2\' ; $Global:EQInstall = 'Live'})
$ToggleLiveServer.BackColor = [System.Drawing.Color]::LightGray
$ToggleLiveServer.font = New-Object System.Drawing.Font("Microsoft Sans Serif", 6.5)
$form2.Controls.Add($ToggleLiveServer)

$CloseEQ = New-Object System.Windows.Forms.Button
$CloseEQ.Location = New-Object System.Drawing.Point(($ColumnX4),($RowY1))
$CloseEQ.Size = New-Object System.Drawing.Size(($StandardWidth),$StandardHight)
$CloseEQ.Text = 'ExitEQ'
$CloseEQ.Add_Click({Get-Process eqgame | % { $_.CloseMainWindow() }})
$CloseEQ.BackColor = [System.Drawing.Color]::LightGray
$CloseEQ.font = New-Object System.Drawing.Font("Microsoft Sans Serif", 6.5)
$form2.Controls.Add($CloseEQ)

$LaunchpadLabel= New-Object system.Windows.Forms.Label
$LaunchpadLabel.text = 'Patcher'
$LaunchpadLabel.AutoSize = $True
$LaunchpadLabel.location = New-Object System.Drawing.Point(($ColumnX1),($RowY2))
$LaunchpadLabel.Font = New-Object System.Drawing.Font('Microsoft Sans Serif',6.5)
$LaunchpadLabel.TextAlign = 'MiddleCenter'
$form2.Controls.Add($LaunchpadLabel)

$Launchpad = New-Object System.Windows.Forms.Button
$Launchpad.Location = New-Object System.Drawing.Point(($ColumnX2),($RowY2))
$Launchpad.Size = New-Object System.Drawing.Size((($StandardWidth)),($StandardHight))
$Launchpad.Text = 'Patch'
$Launchpad.Add_Click({Start-process -FilePath "$($Global:EQPath)LaunchPad.exe"})
$Launchpad.BackColor = [System.Drawing.Color]::LightGray
$Launchpad.font = New-Object System.Drawing.Font('Microsoft Sans Serif', 6.5)
$form2.Controls.Add($Launchpad)

<#Test Server Section#>
$OpenEQLabel = New-Object system.Windows.Forms.Label
$OpenEQLabel.text = 'CharSet'
$OpenEQLabel.AutoSize = $True
$OpenEQLabel.location = New-Object System.Drawing.Point(($ColumnX1),($RowY3))
$OpenEQLabel.Font = New-Object System.Drawing.Font('Microsoft Sans Serif',6.5)
$OpenEQLabel.TextAlign = 'MiddleCenter'
$form2.Controls.Add($OpenEQLabel)

$OpenEQ1 = New-Object System.Windows.Forms.Button
$OpenEQ1.Location = New-Object System.Drawing.Point(($ColumnX2),($RowY3))
$OpenEQ1.Size = New-Object System.Drawing.Size(($StandardWidth),$StandardHight)
$OpenEQ1.Text = '6A'
$OpenEQ1.Add_Click({.'C:\Users\Paul\Desktop\Powershell Scripts\OpenEQ.ps1' ; OpenEQ -SetupType 6ManAlpha -ServerType $Global:EQInstall})
$OpenEQ1.BackColor = [System.Drawing.Color]::LightGray
$OpenEQ1.font = New-Object System.Drawing.Font('Microsoft Sans Serif', 6.5)
$form2.Controls.Add($OpenEQ1)

$OpenEQ2 = New-Object System.Windows.Forms.Button
$OpenEQ2.Location = New-Object System.Drawing.Point(($ColumnX3),($RowY3))
$OpenEQ2.Size = New-Object System.Drawing.Size(($StandardWidth),$StandardHight)
$OpenEQ2.Text = '6B'
$OpenEQ2.Add_Click({.'C:\Users\Paul\Desktop\Powershell Scripts\OpenEQ.ps1'; OpenEQ -SetupType 6ManBeta -ServerType $Global:EQInstall})
$OpenEQ2.BackColor = [System.Drawing.Color]::LightGray
$OpenEQ2.font = New-Object System.Drawing.Font("Microsoft Sans Serif", 6.5)
$form2.Controls.Add($OpenEQ2)

$OpenEQ3 = New-Object System.Windows.Forms.Button
$OpenEQ3.Location = New-Object System.Drawing.Point(($ColumnX4),($RowY3))
$OpenEQ3.Size = New-Object System.Drawing.Size(($StandardWidth),$StandardHight)
$OpenEQ3.Text = '12'
$OpenEQ3.Add_Click({.'C:\Users\Paul\Desktop\Powershell Scripts\OpenEQ.ps1' ; OpenEQ -SetupType 12Man -ServerType $Global:EQInstall})
$OpenEQ3.BackColor = [System.Drawing.Color]::LightGray
$OpenEQ3.font = New-Object System.Drawing.Font("Microsoft Sans Serif", 6.5)
$form2.Controls.Add($OpenEQ3)

<#--------------------------#>

$FormationLabel = New-Object system.Windows.Forms.Label
$FormationLabel.text = 'Order'
$FormationLabel.AutoSize = $True
$FormationLabel.location = New-Object System.Drawing.Point(($ColumnX1),($RowY4))
$FormationLabel.Font = New-Object System.Drawing.Font('Microsoft Sans Serif',6.5)
$FormationLabel.TextAlign = 'MiddleCenter'
$form2.Controls.Add($FormationLabel)

$3Man = New-Object System.Windows.Forms.Button
$3Man.Location = New-Object System.Drawing.Point(($ColumnX2),($RowY4))
$3Man.Size = New-Object System.Drawing.Size($StandardWidth,$StandardHight)
$3Man.Text = 'Pos3'
$3Man.Add_Click({ArrangeWindows -SetType 3Man})
$3Man.BackColor = [System.Drawing.Color]::LightGray
$3Man.font = New-Object System.Drawing.Font("Microsoft Sans Serif", 6.5)
$form2.Controls.Add($3Man)

$6Man = New-Object System.Windows.Forms.Button
$6Man.Location = New-Object System.Drawing.Point(($ColumnX3),($RowY4))
$6Man.Size = New-Object System.Drawing.Size($StandardWidth,$StandardHight)
$6Man.Text = 'Pos6'
$6Man.Add_Click({ArrangeWindows -SetType 6Man})
$6Man.BackColor = [System.Drawing.Color]::LightGray
$6Man.font = New-Object System.Drawing.Font("Microsoft Sans Serif", 6.5)
$form2.Controls.Add($6Man)

<#
$9Man = New-Object System.Windows.Forms.Button
$9Man.Location = New-Object System.Drawing.Point(($ColumnX4),($RowY4))
$9Man.Size = New-Object System.Drawing.Size($StandardWidth,$StandardHight)
$9Man.Text = 'Pos9'
$9Man.Add_Click({ArrangeWindows -SetType 3Man})
$9Man.BackColor = [System.Drawing.Color]::LightGray
$9Man.font = New-Object System.Drawing.Font("Microsoft Sans Serif", 6.5)
$form2.Controls.Add($9Man)
#>

$12Man = New-Object System.Windows.Forms.Button
$12Man.Location = New-Object System.Drawing.Point(($ColumnX4),($RowY4))
$12Man.Size = New-Object System.Drawing.Size($StandardWidth,$StandardHight)
$12Man.Text = 'Pos12'
$12Man.Add_Click({ArrangeWindows -SetType 12Man})
$12Man.BackColor = [System.Drawing.Color]::LightGray
$12Man.font = New-Object System.Drawing.Font("Microsoft Sans Serif", 6.5)
$form2.Controls.Add($12Man)


<#---------Music------------#>

$MusicLabel = New-Object system.Windows.Forms.Label
$MusicLabel.text = '.MP3'
$MusicLabel.AutoSize = $false
$MusicLabel.width = ($StandardWidth)
$MusicLabel.height = ($StandardHight-2)
$MusicLabel.location = New-Object System.Drawing.Point(($ColumnX1),($RowY5))
$MusicLabel.Font = New-Object System.Drawing.Font('Microsoft Sans Serif',6.5)
$MusicLabel.TextAlign = 'MiddleLeft'
$form2.Controls.Add($MusicLabel)

$ToClassicEQMusic = New-Object System.Windows.Forms.Button
$ToClassicEQMusic.Location = New-Object System.Drawing.Point(($ColumnX2),($RowY5))
$ToClassicEQMusic.Size = New-Object System.Drawing.Size($StandardWidth,$StandardHight)
$ToClassicEQMusic.Text = 'Classic'
$ToClassicEQMusic.Add_Click({.'C:\Users\Paul\Desktop\Powershell Scripts\Functions\EQsubUI\PSFunctions\ChangeToClassicEQMusic.ps1' ; ChangeToClassicEQMusic -EQPath $Global:EQPath})
$ToClassicEQMusic.BackColor = [System.Drawing.Color]::LightGray
$ToClassicEQMusic.font = New-Object System.Drawing.Font("Microsoft Sans Serif", 6.5)
$form2.Controls.Add($ToClassicEQMusic)

$ToPoPEQMusic = New-Object System.Windows.Forms.Button
$ToPoPEQMusic.Location = New-Object System.Drawing.Point(($ColumnX3),($RowY5))
$ToPoPEQMusic.Size = New-Object System.Drawing.Size($StandardWidth,$StandardHight)
$ToPoPEQMusic.Text = 'PoP'
$ToPoPEQMusic.Add_Click({.'C:\Users\Paul\Desktop\Powershell Scripts\Functions\EQsubUI\PSFunctions\ChangeToPoPEQMusic.ps1' ; ChangeToPoPEQMusic -EQPath $Global:EQPath})
$ToPoPEQMusic.BackColor = [System.Drawing.Color]::LightGray
$ToPoPEQMusic.font = New-Object System.Drawing.Font("Microsoft Sans Serif", 6.5)
$form2.Controls.Add($ToPoPEQMusic)

$ToFF12Music = New-Object System.Windows.Forms.Button
$ToFF12Music.Location = New-Object System.Drawing.Point(($ColumnX4),($RowY5))
$ToFF12Music.Size = New-Object System.Drawing.Size($StandardWidth,$StandardHight)
$ToFF12Music.Text = 'FF12'
$ToFF12Music.Add_Click({.'C:\Users\Paul\Desktop\Powershell Scripts\Functions\EQsubUI\PSFunctions\ChangeToFF12Music.ps1' ; ChangeToFF12Music -EQPath $Global:EQPath})
$ToFF12Music.BackColor = [System.Drawing.Color]::LightGray
$ToFF12Music.font = New-Object System.Drawing.Font("Microsoft Sans Serif", 6.5)
$form2.Controls.Add($ToFF12Music)

<#--------------------------#>

$LaunchTank1 = New-Object System.Windows.Forms.Button
$LaunchTank1.Location = New-Object System.Drawing.Point(($ColumnX5 + 2),($RowY1))
$LaunchTank1.Size = New-Object System.Drawing.Size($StandardWidth,$StandardHight)
$LaunchTank1.Text = 'Tank1'
$LaunchTank1.Add_Click({.'C:\Users\Paul\Desktop\Powershell Scripts\OpenEQ.ps1' ; OpenEQ -SpecificClient plmitchell -ServerType $Global:EQInstall})
$LaunchTank1.BackColor = [System.Drawing.Color]::LightGray
$LaunchTank1.font = New-Object System.Drawing.Font("Microsoft Sans Serif", 6.5)
$form2.Controls.Add($LaunchTank1)

$LaunchMage = New-Object System.Windows.Forms.Button
$LaunchMage.Location = New-Object System.Drawing.Point(($ColumnX6 + 2),($RowY1))
$LaunchMage.Size = New-Object System.Drawing.Size($StandardWidth,$StandardHight)
$LaunchMage.Text = 'Mage1'
$LaunchMage.Add_Click({.'C:\Users\Paul\Desktop\Powershell Scripts\OpenEQ.ps1' ; OpenEQ -SpecificClient emmitchell -ServerType $Global:EQInstall})
$LaunchMage.BackColor = [System.Drawing.Color]::LightGray
$LaunchMage.font = New-Object System.Drawing.Font("Microsoft Sans Serif", 6.5)
$form2.Controls.Add($LaunchMage)

$LaunchWiz = New-Object System.Windows.Forms.Button
$LaunchWiz.Location = New-Object System.Drawing.Point(($ColumnX7 + 2),($RowY1))
$LaunchWiz.Size = New-Object System.Drawing.Size($StandardWidth,$StandardHight)
$LaunchWiz.Text = 'Wiz1'
$LaunchWiz.Add_Click({.'C:\Users\Paul\Desktop\Powershell Scripts\OpenEQ.ps1' ; OpenEQ -SpecificClient boramur3 -ServerType $Global:EQInstall})
$LaunchWiz.BackColor = [System.Drawing.Color]::LightGray
$LaunchWiz.font = New-Object System.Drawing.Font("Microsoft Sans Serif", 6.5)
$form2.Controls.Add($LaunchWiz)

$LaunchCleric1 = New-Object System.Windows.Forms.Button
$LaunchCleric1.Location = New-Object System.Drawing.Point(($ColumnX5 + 2),($RowY2))
$LaunchCleric1.Size = New-Object System.Drawing.Size($StandardWidth,$StandardHight)
$LaunchCleric1.Text = 'Cleric1'
$LaunchCleric1.Add_Click({.'C:\Users\Paul\Desktop\Powershell Scripts\OpenEQ.ps1' ; OpenEQ -SpecificClient emmitchell2 -ServerType $Global:EQInstall})
$LaunchCleric1.BackColor = [System.Drawing.Color]::LightGray
$LaunchCleric1.font = New-Object System.Drawing.Font("Microsoft Sans Serif", 6.5)
$form2.Controls.Add($LaunchCleric1)

$LaunchEnch = New-Object System.Windows.Forms.Button
$LaunchEnch.Location = New-Object System.Drawing.Point(($ColumnX6 + 2),($RowY2))
$LaunchEnch.Size = New-Object System.Drawing.Size($StandardWidth,$StandardHight)
$LaunchEnch.Text = 'Ench1'
$LaunchEnch.Add_Click({.'C:\Users\Paul\Desktop\Powershell Scripts\OpenEQ.ps1' ; OpenEQ -SpecificClient plmitchell2 -ServerType $Global:EQInstall})
$LaunchEnch.BackColor = [System.Drawing.Color]::LightGray
$LaunchEnch.font = New-Object System.Drawing.Font("Microsoft Sans Serif", 6.5)
$form2.Controls.Add($LaunchEnch)

$LaunchBard = New-Object System.Windows.Forms.Button
$LaunchBard.Location = New-Object System.Drawing.Point(($ColumnX7 + 2),($RowY2))
$LaunchBard.Size = New-Object System.Drawing.Size($StandardWidth,$StandardHight)
$LaunchBard.Text = 'Bard1'
$LaunchBard.Add_Click({.'C:\Users\Paul\Desktop\Powershell Scripts\OpenEQ.ps1' ; OpenEQ -SpecificClient Boramur -ServerType $Global:EQInstall})
$LaunchBard.BackColor = [System.Drawing.Color]::LightGray
$LaunchBard.font = New-Object System.Drawing.Font("Microsoft Sans Serif", 6.5)
$form2.Controls.Add($LaunchBard)

$LaunchRanger = New-Object System.Windows.Forms.Button
$LaunchRanger.Location = New-Object System.Drawing.Point((($ColumnX6 + 2)-($StandardWidth/2)),($RowY3))
$LaunchRanger.Size = New-Object System.Drawing.Size($StandardWidth,$StandardHight)
$LaunchRanger.Text = 'Ranger'
$LaunchRanger.Add_Click({.'C:\Users\Paul\Desktop\Powershell Scripts\OpenEQ.ps1' ; OpenEQ -SpecificClient boramur2 -ServerType $Global:EQInstall})
$LaunchRanger.BackColor = [System.Drawing.Color]::LightGray
$LaunchRanger.font = New-Object System.Drawing.Font("Microsoft Sans Serif", 6.5)
$form2.Controls.Add($LaunchRanger)

$LaunchRanger = New-Object System.Windows.Forms.Button
$LaunchRanger.Location = New-Object System.Drawing.Point((($ColumnX7 + 2) -($StandardWidth/2)),($RowY3))
$LaunchRanger.Size = New-Object System.Drawing.Size($StandardWidth,$StandardHight)
$LaunchRanger.Text = 'GameUI'
$LaunchRanger.Add_Click({.'C:\Users\Paul\Desktop\Powershell Scripts\OpenEQ.ps1' ; OpenEQ -SpecificClient excruciatorUI -ServerType $Global:EQInstall})
$LaunchRanger.BackColor = [System.Drawing.Color]::LightGray
$LaunchRanger.font = New-Object System.Drawing.Font("Microsoft Sans Serif", 6.5)
$form2.Controls.Add($LaunchRanger)

<#--------------------------#>

$LaunchTank2 = New-Object System.Windows.Forms.Button
$LaunchTank2.Location = New-Object System.Drawing.Point(($ColumnX5 + 2),($RowY4))
$LaunchTank2.Size = New-Object System.Drawing.Size($StandardWidth,$StandardHight)
$LaunchTank2.Text = 'Tank2'
$LaunchTank2.Add_Click({.'C:\Users\Paul\Desktop\Powershell Scripts\OpenEQ.ps1' ; OpenEQ -SpecificClient excruciator1 -ServerType $Global:EQInstall})
$LaunchTank2.BackColor = [System.Drawing.Color]::LightGray
$LaunchTank2.font = New-Object System.Drawing.Font("Microsoft Sans Serif", 6.5)
$form2.Controls.Add($LaunchTank2)

$LaunchMage = New-Object System.Windows.Forms.Button
$LaunchMage.Location = New-Object System.Drawing.Point(($ColumnX6 + 2),($RowY4))
$LaunchMage.Size = New-Object System.Drawing.Size($StandardWidth,$StandardHight)
$LaunchMage.Text = 'Mage3'
$LaunchMage.Add_Click({.'C:\Users\Paul\Desktop\Powershell Scripts\OpenEQ.ps1' ; OpenEQ -SpecificClient excruciator6 -ServerType $Global:EQInstall})
$LaunchMage.BackColor = [System.Drawing.Color]::LightGray
$LaunchMage.font = New-Object System.Drawing.Font("Microsoft Sans Serif", 6.5)
$form2.Controls.Add($LaunchMage)

$LaunchWiz = New-Object System.Windows.Forms.Button
$LaunchWiz.Location = New-Object System.Drawing.Point(($ColumnX7 + 2),($RowY4))
$LaunchWiz.Size = New-Object System.Drawing.Size($StandardWidth,$StandardHight)
$LaunchWiz.Text = 'Mage2'
$LaunchWiz.Add_Click({.'C:\Users\Paul\Desktop\Powershell Scripts\OpenEQ.ps1' ; OpenEQ -SpecificClient excruciator5 -ServerType $Global:EQInstall})
$LaunchWiz.BackColor = [System.Drawing.Color]::LightGray
$LaunchWiz.font = New-Object System.Drawing.Font("Microsoft Sans Serif", 6.5)
$form2.Controls.Add($LaunchWiz)

$LaunchCleric1 = New-Object System.Windows.Forms.Button
$LaunchCleric1.Location = New-Object System.Drawing.Point(($ColumnX5 + 2),($RowY5))
$LaunchCleric1.Size = New-Object System.Drawing.Size($StandardWidth,$StandardHight)
$LaunchCleric1.Text = 'Cleric2'
$LaunchCleric1.Add_Click({.'C:\Users\Paul\Desktop\Powershell Scripts\OpenEQ.ps1' ; OpenEQ -SpecificClient excruciator2 -ServerType $Global:EQInstall})
$LaunchCleric1.BackColor = [System.Drawing.Color]::LightGray
$LaunchCleric1.font = New-Object System.Drawing.Font("Microsoft Sans Serif", 6.5)
$form2.Controls.Add($LaunchCleric1)

$LaunchEnch = New-Object System.Windows.Forms.Button
$LaunchEnch.Location = New-Object System.Drawing.Point(($ColumnX6 + 2),($RowY5))
$LaunchEnch.Size = New-Object System.Drawing.Size($StandardWidth,$StandardHight)
$LaunchEnch.Text = 'Ench2'
$LaunchEnch.Add_Click({.'C:\Users\Paul\Desktop\Powershell Scripts\OpenEQ.ps1' ; OpenEQ -SpecificClient excruciator3 -ServerType $Global:EQInstall})
$LaunchEnch.BackColor = [System.Drawing.Color]::LightGray
$LaunchEnch.font = New-Object System.Drawing.Font("Microsoft Sans Serif", 6.5)
$form2.Controls.Add($LaunchEnch)

$LaunchBard = New-Object System.Windows.Forms.Button
$LaunchBard.Location = New-Object System.Drawing.Point(($ColumnX7 + 2),($RowY5))
$LaunchBard.Size = New-Object System.Drawing.Size($StandardWidth,$StandardHight)
$LaunchBard.Text = 'Bard2'
$LaunchBard.Add_Click({.'C:\Users\Paul\Desktop\Powershell Scripts\OpenEQ.ps1' ; OpenEQ -SpecificClient excruciator4 -ServerType $Global:EQInstall})
$LaunchBard.BackColor = [System.Drawing.Color]::LightGray
$LaunchBard.font = New-Object System.Drawing.Font("Microsoft Sans Serif", 6.5)
$form2.Controls.Add($LaunchBard)

$Form2.ShowDialog()
}