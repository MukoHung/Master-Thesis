function userguiden{n    $EqlDocPath = (Get-ItemProperty -path "HKLM:SOFTWAREEqualLogic").installpath + "Doc";n    if (test-path "$EqlDocPathPowerShellModule_UserGuide.pdf")n    {n        invoke-item $EqlDocPathPowerShellModule_UserGuide.pdf;n    }n}nFunction Get-EqlBannern{n    write-host "          Welcome to Equallogic Powershell Tools";n    write-host "";n    write-host -no "Full list of cmdlets:";n    write-host -no " ";n    write-host -fore Yellow "            Get-Command";n    if (test-path "$EqlPSToolsPath")n    {n        write-host -no "Full list of Equallogic cmdlets:";n        write-host -no " ";n        write-host -fore Yellow " Get-EqlCommand";n    }n    if (test-path "$EqlASMPSToolsPath")n    {n        write-host -no "Full list of ASM cmdlets:";n        write-host -no " ";n        write-host -fore Yellow "        Get-ASMCommand";n    }n    if (test-path "$EqlPSArrayPSToolsPath")n    {n        write-host -no "Full list of PS Array cmdlets:";n        write-host -no " ";n        write-host -fore Yellow "   Get-PSArrayCommand";n    }n    if (test-path "$EqlMpioPSToolsPath")n    {n        write-host -no "Full list of MPIO cmdlets:";n        write-host -no " ";n        write-host -fore Yellow "       Get-MPIOCommand";n    }n    write-host -no "Get general help:";n    write-host -no " ";n    write-host -fore Yellow "                Help";n    write-host -no "Cmdlet specific help:";n    write-host -no " ";n    write-host -fore Yellow "            Get-help <cmdlet>";n    write-host -no "Equallogic Powershell User Guide:";n    write-host -no " ";n    write-host -fore Yellow "UserGuide";n    write-host "";n}nFunction Get-EqlCommandn{n    get-command -module EqlPsTools;n}nFunction Get-ASMCommandn{n    get-command -module EqlASMPsTools;n}nFunction Get-PSArrayCommandn{n    get-command -module EqlPSArrayPSTools;n}nFunction Get-MPIOCommandn{n    get-command -module EqlMPIOPSTools;n}n$EqlPSToolsPath = (Get-ItemProperty -path "HKLM:SOFTWAREEqualLogic").installpath + "binEqlPSTools.dll";nif (test-path "$EqlPSToolsPath")n{n    import-module $EqlPSToolsPath;n}n$EqlASMPSToolsPath = (Get-ItemProperty -path "HKLM:SOFTWAREEqualLogic").installpath + "binEqlASMPSTools.dll";nif (test-path "$EqlASMPSToolsPath")n{n    import-module $EqlASMPSToolsPath;n}n$EqlPSArrayPSToolsPath = (Get-ItemProperty -path "HKLM:SOFTWAREEqualLogic").installpath + "binEqlPSArrayPSTools.dll";nif (test-path "$EqlPSArrayPSToolsPath")n{n    import-module $EqlPSArrayPSToolsPath;n}n$EqlMpioPSToolsPath = (Get-ItemProperty -path "HKLM:SOFTWAREEqualLogic").installpath + "binEqlMpioPSTools.dll";nif (test-path "$EqlMpioPSToolsPath")n{n    import-module $EqlMpioPSToolsPath;n}n$EqlShell = (Get-Host).UI.RawUI;n$EqlShell.BackgroundColor = "DarkBlue";n$EqlShell.ForegroundColor = "white";nClear-Host;nGet-EqlBanner;