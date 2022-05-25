# Description: Boxstarter Script  
# Author: Rohit Sankaran
# Dev settings for my work laptop

Disable-UAC

# Get the base URI path from the ScriptToCall value
$bstrappackage = "-bootstrapPackage"
$helperUri = $Boxstarter['ScriptToCall']
$strpos = $helperUri.IndexOf($bstrappackage)
$helperUri = $helperUri.Substring($strpos + $bstrappackage.Length)
$helperUri = $helperUri.TrimStart("'", " ")
$helperUri = $helperUri.TrimEnd("'", " ")
$helperUri = $helperUri.Substring(0, $helperUri.LastIndexOf("/"))
$helperUri += "/scripts"
write-host "helper script base URI is $helperUri"

function executeScript {
    Param ([string]$script)
    write-host "executing $helperUri/$script ..."
    iex ((new-object net.webclient).DownloadString("$helperUri/$script"))
}

#--- Setting up Windows ---
executeScript "00-SystemConfiguration.ps1";
executeScript "01-FileExplorerSettings.ps1";
executeScript "02-CommonDevTools.ps1";
executeScript "03-WindowsTools.ps1";
executeScript "04-Docker.ps1";

#--- Get personal projects ---
executeScript "05-PersonalProjects.ps1";

#--- Configure Windows environment .gitconfig, PowerShell ---
executeScript "06-ConfigureWindowsEnvironment.ps1";

Enable-UAC
