# Description: Boxstarter Script
# Author: Microsoft
# Common dev settings for machine learning using Windows and Linux native tools

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
    write-host "Executing $helperUri/$script ..."
    iex ((new-object net.webclient).DownloadString("$helperUri/$script"))
}

#--- Setting up Windows ---
executeScript "Initialize.ps1";
executeScript "SystemConfiguration.ps1";
executeScript "Win10InitialStartupScript.ps1";
executeScript "DebloatWindows10.ps1";
executeScript "FileExplorerSettings.ps1";
executeScript "CommonDevTools.ps1";
executeScript "CustomDevTools.ps1";
executeScript "GitConfig.ps1";
executeScript "VSCode.ps1";
executeScript "VisualStudio2017GameDev.ps1";
executeScript "PowershellModules.ps1";
executeScript "CommonApplications.ps1";
executeScript "CommonGameApps.ps1";
executeScript "PathOfBuildingCommunity.ps1";
executeScript "HyperV.ps1";
executeScript "WSL.ps1";
executeScript "Docker.ps1";
executeScript "Cleanup.ps1";

