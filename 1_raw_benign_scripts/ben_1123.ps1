# TODO Scheduled tasks to purge temp folders
# TODO Autohotkey repo and setup
# TODO Taskbar pins, not possible on Win10

## Boxstarter options
$Boxstarter.RebootOk=$true 
$Boxstarter.NoPassword=$false 
$Boxstarter.AutoLogin=$true

## Explorer options
Set-ExplorerOptions -showHiddenFilesFoldersDrives -showProtectedOSFiles -showFileExtensions

Update-ExecutionPolicy Unrestricted

if (Test-PendingReboot) { Invoke-Reboot }

Install-WindowsUpdate -AcceptEula
if (Test-PendingReboot) { Invoke-Reboot }

cinst chocolatey
cinst boxstarter

## Software Installs
### .net tools
cinst linqpad
cinst dotpeek

### Dev tools
cinst visualstudiocode
cinst putty
cinst sysinternals
cinst notepadplusplus
cinst scriptcs
#cinst cmder 
cinst nodejs

### Web dev
cinst googlechrome 
cinst fiddler4

### Automation
cinst autohotkey

### Misc
cinst f.lux

## Refresh environment variables  
RefreshEnv

$devDir = "$env:SystemDrive\dev"
$devTempDir = "$env:SystemDrive\dev\temp"

mkdir $devDir
mkdir $devTempDir

## npm
npm i -g nativescript

## VS Code configuration
code --install-extension filipw.scriptcsRunner
code --install-extension Telerik.nativescript
code --install-extension ms-vscode.PowerShell
function AutoHotKey 
{ 
  popd $devDir
  git -clone -q https://github.com/ppejovic/autohotkey.git autohotkey
  .\autohotkey\master.ahk;
  pushd
}

AutoHotKey