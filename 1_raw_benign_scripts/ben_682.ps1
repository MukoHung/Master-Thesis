# RUN ME FROM AN ADMIN POWERSHELL PROMPT
# SCRIPT MAY FAIL DUE TO ENVIRONMENT UPDATES AND REQUIRED REBOOTS BY PACKAGES.
# CAN SAFELY BE RE-RUN (THOUGH MAY WANT TO COMMENT OUT THE NEXT LINE) WITHOUT CAUSING RE-INSTALL OF ALL PACKAGES

Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

If(!(Test-Path "C:\tools"))
{
   New-Item -Path "C:\tools" -Type Directory
}

choco feature enable -n=allowGlobalConfirmation

# frameworks
choco install dotnetcore-sdk -y #.net core
choco install dotnetfx -y #.Net framework
choco install nodejs  -y
refreshenv

# browsers
choco install microsoft-edge -y
choco install googlechrome -y
choco install firefox  -y

# dev tools
choco install git  -y
choco install powershell -y
choco install powershell-core --install-arguments='"ADD_EXPLORER_CONTEXT_MENU_OPENPOWERSHELL=1"' -y
choco install terraform
refreshenv

choco install microsoft-windows-terminal -y
choco install vscode -y
choco install linqpad -y
choco install postman -y
choco install fiddler  -y
choco install lastpass  -y
choco install beyondcompare  -y
choco install armclient -y
choco install dotpeek -y
choco install servicebusexplorer -y

# azure tooling
choco install azure-cli -y
refreshenv

#choco install azurepowershell -y #CLI instead
choco install azcopy  -y
choco install microsoftazurestorageexplorer  -y
choco install azure-functions-core-tools -y
choco install azure-data-studio -y

#utils 
choco install notepadplusplus --x86  -y
choco install sysinternals --params "/InstallDir:C:\tools" -y
choco install 7zip.install -y
choco install jetbrainsmono
choco install sharex

#heavy
choco install sql-server-2019 -y
choco install sql-server-management-studio -y
choco install visualstudio2019enterprise  -y
choco install resharper  -y

#optional 
npm install -g @angular/cli -y

#java stuff
#choco install intellijidea-ultimate -y
#choco install openjdk14 -y
#choco install maven -y

#retired
#choco install filezilla  -y
#choco install webpi -y
#choco install paint.net  -y

#Docker
Enable-WindowsOptionalFeature -Online -FeatureName containers -All
RefreshEnv
choco install -y docker-for-windows

# other OS
choco install wsl2 -y

# Show hidden files, Show protected OS files, Show file extensions
Set-WindowsExplorerOptions -EnableShowHiddenFilesFoldersDrives -EnableShowProtectedOSFiles -EnableShowFileExtensions

#--- File Explorer Settings ---
# will expand explorer to the actual folder you're in
Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name NavPaneExpandToCurrentFolder -Value 1
#adds things back in your left pane like recycle bin
Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name NavPaneShowAllFolders -Value 1
#opens PC to This PC, not quick access
Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name LaunchTo -Value 1
#taskbar where window is open for multi-monitor
Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name MMTaskbarMode -Value 2
#--- Enable developer mode on the system ---
Set-ItemProperty -Path HKLM:\Software\Microsoft\Windows\CurrentVersion\AppModelUnlock -Name AllowDevelopmentWithoutDevLicense -Value 1

choco feature disable -n=allowGlobalConfirmation

Install-PackageProvider -Name NuGet -Force
#Install-Module -Force AzureRM
Start-Process 'cmd' -Verb RunAs -ArgumentList '/c az extension add --name subscription'
Start-Process 'cmd' -Verb RunAs -ArgumentList '/c az extension add --name azure-devops'