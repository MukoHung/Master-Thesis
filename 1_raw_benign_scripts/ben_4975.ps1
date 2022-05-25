<# 

This script is based off the GetLDLogs_v0.1 script written my. 
This script was downloaded for free and modified for its menu functionality.

#>

Set-ExecutionPolicy Unrestricted

<#-----------------------------------#>
<#--------- Selection menu ----------#>
<#-----------------------------------#> 

# Share drives
$menuItems="\\FILEPATH\justin_barfield\menuItems"

Import-Module BitsTransfer

function installCheckpoint(){
    Start-Process -FilePath powershell.exe -ArgumentList "-File  $menuItems\checkpoint\install.ps1" -Wait
}

function installConnectedBackup(){
    Start-Process -FilePath powershell.exe -ArgumentList "-File  $menuItems\connectedbackup\install.ps1" -Wait
}

function installMS1903(){
    Start-Process -FilePath powershell.exe -ArgumentList "-File $menuItems\1903\transfer.ps1" -Wait
}

function installMS32Bit(){
    Start-Process -FilePath powershell.exe -ArgumentList "-File $menuItems\ms_office\32-bit\install.ps1" -Wait
}

function installMS64Bit(){
    Start-Process -FilePath powershell.exe -ArgumentList "-File $menuItems\ms_office\64-bit\install.ps1" -Wait
}

function updateMSOffice(){
    Start-Process -FilePath powershell.exe -ArgumentList "-File $menuItems\ms_office\64-bit\install.ps1" -Wait
}

function installFireFox(){
    Start-Process -FilePath powershell.exe -ArgumentList "-File $menuItems\firefox\Firefox.exe" -Wait
}

function installSmartView(){
    Start-Process -FilePath powershell.exe -ArgumentList "-File $menuItems\smartview\install.ps1" -Wait
}

function installSnagIt(){
    Start-Process -FilePath powershell.exe -ArgumentList "-File $menuItems\snagit\transfer.ps1" -Wait
}
function installTeraData(){   
    Start-Process -FilePath powershell.exe -ArgumentList "-File $menuItems\TeraData\transfer.ps1" -Wait
}

function installWebEx() {
    Start-Process -FilePath powershell.exe -ArgumentList "-File $menuItems\webex\install.ps1" -Wait
}

function installPowerSettings(){
    Start-Process -FilePath powershell.exe -ArgumentList "-File $menuItems\power_settings\install.ps1" -Wait
}

function installRegFix(){
    Start-Process -FilePath powershell.exe -ArgumentList "-File $menuItems\regfix\install.ps1" -Wait
}

Clear-Host
$Host.UI.RawUI.WindowTitle = "ATL SSB Script Runner"

function loadMainMenu(){

    [bool]$loopMainMenu = $true
    while ($loopMainMenu){
        # Clear the screen.
        Clear-Host  
        Write-Host “ ---------------------------------------”
        Write-Host "¦`tATL SSB Script Runner v0.1`t¦"
        Write-Host “ ---------------------------------------`n”
        $runasAlias = [Environment]::UserName
        Write-Host "Running as: $runasAlias`n"
        Write-Host “`t`t+ Main Menu`t`t`n”
        Write-Host “`t`t`t1. New User Config`n”
        Write-Host “`t`t`t2. Loaner Setup`n”
        Write-Host “`t`t`t3. Individual Installers`n”
        Write-Host “`t`t`tQ. Quit And Exit`n”
        # Get user's entry.
        $mainMenu = Read-Host “`t`tEnter Sub-Menu Number”

        switch ($mainMenu){

            1{mainMenuOption1} # Calls New User Config
            2{mainMenuOption2} # Calls Loaner Setup
            3{mainMenuOption3} # Calls Individual Installers
            
            "q"
                {
                    $loopMainMenu = $false
                    Clear-Host
                    Write-Host -BackgroundColor DarkCyan -ForegroundColor Yellow "`t`t`t`t`t"
                    Write-Host -BackgroundColor DarkCyan -ForegroundColor Yellow "`tGoodbye!`t`t`t"
                    Write-Host -BackgroundColor DarkCyan -ForegroundColor Yellow "`t`t`t`t`t"
                    Start-Sleap -Seconds 1
                    $Host.UI.RawUI.WindowTitle = "Windows PowerShell" # Set back to standard.
                    Clear-Host
                    Exit-PSSession
                }

            default
                {
                    Write-Host -BackgroundColor Red -ForegroundColor White "You did not enter a valid sub-menu selection. Please enter a valid selection."
                    Start-Sleap -Seconds 3
                }
        }
    }
    return
}

function mainMenuOption1(){
# This section is used for Loading Main Menu Option 1, .

    [bool]$loopSubMenu = $true
    while ($loopSubMenu){
            
        $Host.UI.RawUI.WindowTitle = "New User Config"
        Clear-Host  # Clear the screen.
        Write-Host “ ---------------------------------------”
        Write-Host "¦`tATL SSB Script Runner v0.1`t¦"
        Write-Host “ ---------------------------------------`n”
        Write-Host “`t`t+ New User Config`t`t`n”
        Write-Host “`t`t`t1. Standard`n”
        Write-Host “`t`t`t2. Standard + TeraData`n”
        Write-Host “`t`t`tQ. Quit And Return To Main Menu`n”
        $subMenu = Read-Host “`t`tEnter the Option Number desired”

        switch ($subMenu){

            1		#	Option1
                {
                    Write-Host "`nStandard..." -ForegroundColor Yellow

                    installFireFox
                    installMS64Bit
                    installConnectedBackup
                    installWebEx
                    installRegFix

                    Start-Sleep -Seconds 2
                }
            2		#	Option2
                {
                    Write-Host "`nStandard + Teradata..." -ForegroundColor Yellow

                    installMS32Bit
                    installTeraData
                    installFireFox
                    installConnectedBackup
                    installWebEx
                    installRegFix

                    Start-Sleep -Seconds 2
                }
            q     #Quit
                {
                    $loopSubMenu = $false
                }
            default
                {
                    Write-Host -BackgroundColor Red -ForegroundColor White "You did not enter a valid sub-menu selection. Please enter a valid selection."
                    Start-Sleap -Seconds 3
                }
        }
    }
}

function mainMenuOption2(){
# This section is used for Loading Main Menu Option 2, .  
    [bool]$loopSubMenu = $true
    while ($loopSubMenu){

    $Host.UI.RawUI.WindowTitle = "Loaner Setup"
    Clear-Host  # Clear the screen.
    Write-Host “ ---------------------------------------”
    Write-Host "¦`tATL SSB Script Runner v0.1`t¦"
    Write-Host “ ---------------------------------------`n”
    Write-Host “`t`t+ Loaner Setup`t`t`n”
    Write-Host “`t`t`t1.  Initiate”
    Write-Host “`t`t`tQ. Quit And Return To Main Menu`n”
    $subMenu = Read-Host “`t`tEnter the Option Number desired”

        switch ($subMenu){

            1	#	Security and Patch Manager - Vulscan
                {
                    Start-Process "\\FILEPATH\justin_barfield\loaner_batch\initiate_loaner.bat"
                }
            q
                {
                    $loopSubMenu = $false
                }
            default
                {
                    Write-Host -BackgroundColor Red -ForegroundColor White "You did not enter a valid sub-menu selection. Please enter a valid selection."
                    Start-Sleap -Seconds 3
                }
        }
    }
}

function mainMenuOption3(){
# This section is used for Loading Main Menu Option 3, .

    [bool]$loopSubMenu = $true
    while ($loopSubMenu){
            
        $Host.UI.RawUI.WindowTitle = "Individual Installers"
        Clear-Host  # Clear the screen.
        Write-Host “ ---------------------------------------”
        Write-Host "¦`tATL SSB Script Runner v0.1`t¦"
        Write-Host “ ---------------------------------------`n”
        Write-Host “`t`t+ Individual Installers`t`t`n”
        Write-Host “`t`t`t1. CheckPoint`n”
        Write-Host “`t`t`t2. Connected Backup`n”
        Write-Host “`t`t`t3. Microsoft 1903 update`n”
        Write-Host “`t`t`t4. Microsoft Office 32-bit`n”
        Write-Host “`t`t`t5. Microsoft Office 64-bit`n”
        Write-Host “`t`t`t6. Update Microsoft Office`n”
        Write-Host “`t`t`t7. Mozilla FireFox`n”
        Write-Host “`t`t`t8. Oracle Smartview 11.2.2.5.810`n”
        Write-Host “`t`t`t9. `n”
        Write-Host “`t`t`t10. SnagIt 20.0.0.4460`n”
        Write-Host “`t`t`t11. Teradata 16.20.17`n”
        Write-Host “`t`t`t12. WebEx`n”
        Write-Host “`t`t`tQ. Quit And Return To Main Menu`n”
        $subMenu = Read-Host “`t`tEnter the Option Number desired”
        switch ($subMenu){

            1		#	CheckPoint
                {
                    Write-Host "`nCheckPoint..." -ForegroundColor Yellow

                    installCheckpoint

                    Start-Sleep -Seconds 2
                }
            2		#	Connected Backup
                {
                    Write-Host "`nConnected Backup..." -ForegroundColor Yellow

                    installConnectedBackup

                    Start-Sleep -Seconds 2
                }
            3		#	Microsoft 1903 Update
                {
                    Write-Host "`nMicrosoft 1903 Update..." -ForegroundColor Yellow

                    installMS1903

                    Start-Sleep -Seconds 2
                    
                }
            4		#	Microsoft Office 32-bit
                {
                    Write-Host "`nMicrosoft Office 32-bit..." -ForegroundColor Yellow

                    installMS32Bit

                    Start-Sleep -Seconds 2
                }
            5		#	Microsoft Office 64-bit
                {
                    Write-Host "`nMicrosoft Office 64-bit..." -ForegroundColor Yellow

                    installMS64Bit

                    Start-Sleep -Seconds 2
                }

            6       #   Update MS Office
                {
                    Write-Host "`nUpdate Microsoft Office..." -ForegroundColor Yellow

                    updateMSOffice

                    Start-Sleep -Seconds 2

                }
            7		#	Mozilla FireFox
                {
                    Write-Host "`nMozilla FireFox..." -ForegroundColor Yellow

                    installFireFox

                    Start-Sleep -Seconds 2
                }
            8		#	Oracle Smartview 11.2.2.5.810 32-bit
                {
                    Write-Host "`nOracle Smartview 11.2.2.5.810..." -ForegroundColor Yellow

                    installSmartView

                    Start-Sleep -Seconds 2
                }
            9		#	Power settings
                {
                    Write-Host "`n" -ForegroundColor Yellow

                    

                    Start-Sleep -Seconds 2
                }
            10		#	SnagIt 20.0.0.4460
                {
                    Write-Host "`nSnagIt 20.0.0.4460..." -ForegroundColor Yellow

                    installSnagIt

                    Start-Sleep -Seconds 2
                }
            11		#	Teradata 16.20.10
                {
                    Write-Host "`nTeradata 16.20.10..." -ForegroundColor Yellow

                    installTeraData

                    Start-Sleep -Seconds 2
                }
            12
                {
                    Write-Host "`nWebEx Productivity Tools & Meetings"

                    installWebEx

                    Start-Sleep -Seconds 2
                }
            q     #Quit
                {
                    $loopSubMenu = $false
                }
            default
                {
                    Write-Host -BackgroundColor Red -ForegroundColor White "You did not enter a valid sub-menu selection. Please enter a valid selection."
                    Start-Sleep -Seconds 3
                }
        }
    }
}

#Start main menu
loadMainMenu

if ($clearHost) {Clear-Host}
if ($exitSession) {Exit-PSSession};