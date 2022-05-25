#Disable-UAC
echo "wwa"
#$bstrappackage = "-bootstrapPackage"
#$helperUri = $Boxstarter['ScriptToCall']
#$strpos = $helperUri.IndexOf($bstrappackage)
#$helperUri = $helperUri.Substring($strpos + $bstrappackage.Length)
#$helperUri = $helperUri.TrimStart("'", " ")
#$helperUri = $helperUri.TrimEnd("'", " ")
#$helperUri = $helperUri.Substring(0, $helperUri.LastIndexOf("/"))
#$helperUri += "/scripts"
#write-host "helper script base URI is $helperUri"

#function executeScript {
#    Param ([string]$script)
#    write-host "executing $helperUri/$script ..."
#	iex ((new-object net.webclient).DownloadString("$helperUri/$script"))
#}

#executeScript "SystemConfiguration.ps1";
#executeScript "FileExplorerSettings.ps1";
#executeScript "RemoveDefaultApps.ps1";
#executeScript "CommonDevTools.ps1";
#executeScript "WSL.ps1";
#executeScript "Browsers.ps1";
#executeScript "Docker.ps1";
#executeScript "JetBrains.ps1";
#code --install-extension msjsdiag.debugger-for-chrome
#code --install-extension msjsdiag.debugger-for-edge

#Enable-UAC
#Enable-MicrosoftUpdate
#Install-WindowsUpdate -acceptEula
