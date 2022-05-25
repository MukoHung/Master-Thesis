function userguiden{n    $EqlDocPath = (Get-ItemProperty -path "HKLM:SOFTWAREEqualLogic").installpath + "Doc";n    if (test-path "$EqlDocPathPowerShellModule_UserGuide.pdf")n    {n        invoke-item $EqlDocPathPowerShellModule_UserGuide.pdf;n    }n}nFunction Get-EqlBannern{n    write-host "          Welcome to Equallogic Powershell Tools";n    write-host "";n    write-host -no "Full list of cmdlets:";n    write-host -no " ";n    write-host -fore Yellow "            Get-Command";n    write-host -no "Full list of Equallogic cmdlets:";n    write-host -no " ";n    write-host -fore Yellow " Get-EqlCommand";n    write-host -no "Get general help:";n    write-host -no " ";n    write-host -fore Yellow "                Help";n    write-host -no "Cmdlet specific help:";n    write-host -no " ";n    write-host -fore Yellow "            Get-help <cmdlet>";n    write-host -no "Equallogic Powershell User Guide:";n    write-host -no " ";n    write-host -fore Yellow "UserGuide";n    write-host "";n}nFunction Get-EqlCommandn{n    get-command -module EqlPsTools;n}n$EqlPSToolsPath = (Get-ItemProperty -path "HKLM:SOFTWAREEqualLogic").installpath + "binEqlPSTools.dll";nimport-module $EqlPSToolsPath;n$EqlShell = (Get-Host).UI.RawUI;n$EqlShell.BackgroundColor = "DarkBlue";n$EqlShell.ForegroundColor = "white";nClear-Host;nGet-EqlBanner;