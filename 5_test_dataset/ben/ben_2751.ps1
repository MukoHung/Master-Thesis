# Set TLS support
[Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls"

# Import Choco Install-*
Import-Module "$env:ChocolateyInstall\helpers\chocolateyInstaller.psm1" -Force

# Set up choco cache location to work around Boxstarter Issue 241
$chocoCache = (Join-Path ([Environment]::GetEnvironmentVariable("LocalAppData")) "Temp\ChocoCache")
New-Item -Path $chocoCache -ItemType directory -Force
# Remove *.tmp from the choco cache directory so the ad-hoc package installs using Install-ChocolateyPackage behave idempotently - this is a hack
Remove-Item -Path (Join-Path $chocoCache '*.tmp') -Recurse -Force

# Get Post Build Content
Write-BoxstarterMessage "Getting post build content"
$path = "C:\_PostBuildContent"
$answersPath = "C:\Windows\Temp\User_Answers.json"
if (Test-Path -Path $path) {
    Remove-Item -Path $path -Recurse
}
Invoke-WebRequest -UseBasicParsing https://github.com/KZeronimo/PostBuildContent/archive/develop.zip -OutFile C:\PostBuildContent.zip
Expand-Archive -Path C:\PostBuildContent.zip -DestinationPath $path
Move-Item (Join-Path $path 'PostBuildContent-develop\*') $path
if (Test-Path $answersPath) {
    Copy-Item $answersPath -Destination (Join-Path $path 'User_Answers.json')
}
Remove-Item -Path (Join-Path $path 'PostBuildContent-develop')
Remove-Item -Path C:\PostBuildContent.zip

# Configure Windows Explorer Options
Set-WindowsExplorerOptions -EnableShowFileExtensions -EnableShowHiddenFilesFoldersDrives -EnableShowFullPathInTitleBar

# Trust PSGallery
Get-PackageProvider -Name NuGet -ForceBootstrap
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted

# Install oh-my-posh
Write-BoxstarterMessage "Installing posh-git and oh-my-posh"
Install-Module -Name posh-git -Scope AllUsers
cinst oh-my-posh --cacheLocation $chocoCache

# Install PowerShell Core
Write-BoxstarterMessage "Installing PowerShell Core"
cinst powershell-core --cacheLocation $chocoCache

# Install Source Code Pro and Patched
Write-BoxstarterMessage "Installing Source Code Pro and SourceCodePro+Powerline+Awesome+Regular Font"
cinst sourcecodepro --cacheLocation $chocoCache
& C:\_PostBuildContent\helpers\install-font.ps1 -Url https://github.com/gabrielelana/awesome-terminal-fonts/blob/patching-strategy/patched/SourceCodePro+Powerline+Awesome+Regular.ttf?raw=true -ChecksumType sha256 -Checksum 44f51e4e61b171f070ad792ee61fb11c72e682be91d381b94ad9f314e4a5ba20

# Install Cascadia Code Nerd Font
Write-BoxstarterMessage "Installing Cascadia Code Nerd & PL Font"
cinst cascadia-code-nerd-font --cacheLocation $chocoCache
& C:\_PostBuildContent\helpers\install-font.ps1 -Url https://github.com/microsoft/cascadia-code/releases/download/v2110.31/CascadiaCode-2110.31.zip -ChecksumType sha256 -Checksum b1a18b6b15818f5e5467f06363c963d7f373f26c41910284943076c064756fac -FontFilesFilter '*PL*.otf'

# Install Git (core credential mgr intalled with git for windows)
cinst git -params '"/GitAndUnixToolsOnPath"' --cacheLocation $chocoCache

# Install Visual Studio Code
cinst visualstudiocode --cacheLocation $chocoCache

# Install Notepad++
cinst notepadplusplus --cacheLocation $chocoCache

# Install Google Chrome
cinst googlechrome --cacheLocation $chocoCache

# Install PowerShell Azure Modules
Write-BoxstarterMessage "Installing Azure PowerShell modules"
Install-Module -Name Az -Scope AllUsers -AllowClobber
Install-Module -Name Azure -Scope AllUsers -AllowClobber

# Install posh-docker docker
Write-BoxstarterMessage "Installing posh-docker"
Install-Module -Name posh-docker -Scope AllUsers

# Install Azure CLI
cinst azure-cli --cacheLocation $chocoCache

# Install Node.js
cinst nodejs --cacheLocation $chocoCache

# Install Python
cinst python --cacheLocation $chocoCache

# Install NuGet Command Line
cinst nuget.commandline --cacheLocation $chocoCache

Write-BoxstarterMessage "Refreshing path to have access to command line tools"
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine")

# Install Visual Studio 2019
Write-BoxstarterMessage "Installing Visual Studio 2019"
& C:\_PostBuildContent\helpers\install-vs2019.ps1
Start-Sleep -Seconds 30

# Install Open Command Line VSIX
Write-BoxstarterMessage "Installing Open Command Line VSIX"
#& C:\_PostBuildContent\helpers\install-vsix.ps1 -Name OpenCommandLine -Url http://vsixgallery.com/extensions/f4ab1e64-5d35-4f06-bad9-bf414f4b3bbb/Open%20Command%20Line%20v2.4.233.vsix
#Start-Sleep -Seconds 60

# Install Clean Solution VSIX
Write-BoxstarterMessage "Installing Clean Solution VSIX"
#& C:\_PostBuildContent\helpers\install-vsix.ps1 -Name CleanSolution -Url https://marketplace.visualstudio.com/_apis/public/gallery/publishers/MadsKristensen/vsextensions/CleanSolution/1.4.30/vspackage
#Start-Sleep -Seconds 60

# Install License Header Manager VSIX
Write-BoxstarterMessage "Installing License Header Manager VSIX"
#& C:\_PostBuildContent\helpers\install-vsix.ps1 -Name LicenseHeaderManager -Url https://github.com/rubicon-oss/LicenseHeaderManager/releases/download/3.0.3/LicenseHeaderManager.vsix
#Start-Sleep -Seconds 60

# Install VS Color Theme Editor VSIX
Write-BoxstarterMessage "Installing VS Color Themes VSIX"
#& C:\_PostBuildContent\helpers\install-vsix.ps1 -Name VS-ColorThemes -Url https://marketplace.visualstudio.com/_apis/public/gallery/publishers/VisualStudioPlatformTeam/vsextensions/ColorThemesforVisualStudio/1.0.11/vspackage
#Start-Sleep -Seconds 60

# Install Azure IoT Edge Tools VSIX
Write-BoxstarterMessage "Installing Azure IoT Edge Tools VSIX"
#& C:\_PostBuildContent\helpers\install-vsix.ps1 -Name VS-ColorThemes -Url https://marketplace.visualstudio.com/_apis/public/gallery/publishers/vsc-iot/vsextensions/vs16iotedgetools/1.7.0/vspackage

# Install additional components needed for Azure IoT Edge in VS 2019
# https://docs.microsoft.com/en-us/azure/iot-edge/how-to-visual-studio-develop-module
Write-BoxstarterMessage "Installing additional components needed for Azure IoT Edge in VS 2019"
#pip install --upgrade iotedgehubdev

#Set-Location -Path C:\_PostBuildContent
#$path = "https://github.com/Microsoft/vcpkg"
#if (! (Test-Path -Path ($path -split '/')[-1])) {
#    git clone $path
#    Set-Location -Path C:\_PostBuildContent\vcpkg
#    .\bootstrap-vcpkg.bat
#    .\vcpkg.exe install azure-iot-sdk-c:x64-windows
#    .\vcpkg.exe --triplet x64-windows integrate install
#}
#Set-Location -Path C:\Windows\system32

# Install Sql Server Management Studio
cinst sql-server-management-studio --cacheLocation $chocoCache

# Install Microsoft Azure Storage Explorer
cinst microsoftazurestorageexplorer --cacheLocation $chocoCache

# Install Postman
cinst postman --cacheLocation $chocoCache

# Install LINQPad
cinst linqpad --cacheLocation $chocoCache --ignore-checksums

# Install NuGet Package Explorer
cinst nugetpackageexplorer --cacheLocation $chocoCache
Install-ChocolateyShortcut -ShortcutFilePath (Join-Path ([Environment]::GetEnvironmentVariable("AppData")) "Microsoft\Windows\Start Menu\Programs\Nuget Package Explorer.lnk") -TargetPath "C:\ProgramData\chocolatey\bin\NugetPackageExplorer.exe"

# Install Service Bus Explorer
cinst servicebusexplorer --cacheLocation $chocoCache
Install-ChocolateyShortcut -ShortcutFilePath (Join-Path ([Environment]::GetEnvironmentVariable("AppData")) "Microsoft\Windows\Start Menu\Programs\Service Bus Explorer.lnk") -TargetPath "C:\ProgramData\chocolatey\bin\ServiceBusExplorer.exe"

# Install Azure IoT Hub Device Explorer Xplat
cinst azure-iot-explorer --pre --cacheLocation $chocoCache --ignore-checksums

# Install Docker Desktop
cinst docker-desktop --cacheLocation $chocoCache

# Enable Linux Subsystem - WSL1
cinst Microsoft-Windows-Subsystem-Linux -source windowsFeatures --cacheLocation $chocoCache

# Enable Virtual Machine Platform - WSL2
cinst VirtualMachinePlatform -source windowsFeatures --cacheLocation $chocoCache

# Enable Hyper-V - Docker Windows Containers
cinst Microsoft-Hyper-V-All -source windowsFeatures --cacheLocation $chocoCache
# Note Windows Hypervisor Platform is not installed because its not compatible with Packer

# Enable Containers - Docker Windows Containers
cinst Containers -source windowsFeatures --cacheLocation $chocoCache

# Enable Windows Sandbox
cinst Containers-DisposableClientVM -source windowsFeatures --cacheLocation $chocoCache

# Create Hyper-V Off boot option
Write-BoxstarterMessage "Creating Hyper-V Off boot option"
bcdedit /copy '{current}' /d "Windows 10 - No Hyper-V" | ForEach-Object { $id = $_.Substring(($_.IndexOf('{')), (($_.IndexOf('}')) - ($_.IndexOf('{'))) + 1); bcdedit /set $id hypervisorlaunchtype Off }

# Create root folder structure
Write-BoxstarterMessage "Creating root folder structure"
New-Item -Path "C:\_Src" -Type Directory -Force
New-Item -Path "C:\_Src\Prod" -Type Directory -Force
New-Item -Path "C:\_Src\Prod\Mesh" -Type Directory -Force
New-Item -Path "C:\_Src\Sdbx" -Type Directory -Force

# Remove Desktop Shortcuts
Write-BoxstarterMessage "Removing desktop shortcuts"
Get-ChildItem -Path "C:\Users\*\Desktop\*" -Recurse -Include *.lnk | Remove-Item -Force

# Copy Themed Wallpaper
Write-BoxstarterMessage "Copying themed wallpaper"
Copy-Item -Path "C:\_PostBuildContent\themes\*" -Destination (New-Item (Join-Path $env:UserProfile "Pictures\Themes") -Type container -Force) -Recurse -Force

# Deploy post build files
Write-BoxstarterMessage "Deploying post build files"
Copy-Item "C:\_PostBuildContent\git\.gitconfig" -Destination $env:UserProfile -Force
Copy-Item "C:\_PostBuildContent\terminal\Microsoft.PowerShell_profile.ps1" -Destination (New-Item (Join-Path $env:UserProfile "Documents\WindowsPowerShell") -Type container -Force) -Force
Copy-Item "C:\_PostBuildContent\terminal\Microsoft.PowerShell_profile.ps1" -Destination (New-Item (Join-Path $env:UserProfile "Documents\PowerShell") -Type container -Force) -Force
Copy-Item "C:\_PostBuildContent\terminal\wt_profiles_settings.json" -Destination (Join-Path $env:LocalAppData "Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json") -Force
Copy-Item "C:\_PostBuildContent\terminal\agnoster-mesh.omp.json" -Destination (Join-Path $env:LocalAppData "Programs\oh-my-posh\themes\agnoster-mesh.omp.json") -Force

# Configure my .gitconfig
Write-BoxstarterMessage "Customizing gitconfig"
& C:\_PostBuildContent\git\configure-my-gitconfig.ps1

# Setup configuration and dotfile tracking
Write-BoxstarterMessage "Setting up configuration and dotfile tracking"
$path = Join-Path $env:UserProfile ".myconf"
New-Item -Path ($path) -Type Directory -Force
Set-Location -Path $path
if (! (Test-Path -Path "HEAD")) {
    git init --bare $path
    Write-Output '*' >> $env:UserProfile/.myconf/info/exclude
}

# Clone One Flow Repo
Write-BoxstarterMessage "Cloning One Flow repo"
Set-Location -Path C:\_Src\Prod\Mesh
$path = "https://meshsystems.visualstudio.com/DefaultCollection/Mesh%20Systems/_git/Mesh.DevAutomation.OneFlow"
if (! (Test-Path -Path ($path -split '/')[-1])) {
    git clone $path
}

# Clone Packer-Windows
Write-BoxstarterMessage "Cloning Packer Windows Repo"
Set-Location -Path C:\_Src\Prod\Mesh
$path = "https://meshsystems.visualstudio.com/DefaultCollection/Mesh%20Systems/_git/Mesh.DevAutomation.Packer-Windows"
if (! (Test-Path -Path ($path -split '/')[-1])) {
    git clone $path
}
