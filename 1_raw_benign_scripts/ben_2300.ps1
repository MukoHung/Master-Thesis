# documentation in comment!

##https://www.howtogeek.com/117192/how-to-run-powershell-commands-on-remote-computers/
##https://docs.microsoft.com/en-us/powershell/module/microsoft.wsman.management/about/about_wsman_provider?view=powershell-7
##https://docs.microsoft.com/en-us/powershell/module/microsoft.wsman.management/?view=powershell-7
##https://docs.microsoft.com/en-us/powershell/module/microsoft.wsman.management/test-wsman?view=powershell-7#examples

    #setup WINRM
        Enable-PSRemoting -Force

        
###inrm.cmd -> help commando Windows Remote Management


    #controleer het TrustedHosts bestand op reeds aanwezige host entrys
        Get-ChildItem -Path WSMan:\localhost\Client\TrustedHosts


    #configure the TrustedHosts setting on both the PC
    #trust any PC to connect remotely use asteriks * a wildcard symbol for all PCs (only for testing!!)
    #otherwise use a comma-separated list of IP addresses
          Set-Item -Path WSMan:\localhost\Client\TrustedHosts -Value "*"


    #controleer of de value is ingevoerd in het TrustedHosts bestand
        Get-ChildItem -Path WSMan:\localhost\Client\TrustedHosts


##now you�ll need to restart the WinRM service so your new settings take effect.

    #restart de dienst
        Restart-Service WinRM


    #testing on the PC you want to access the remote system from, after your PCs set up for PowerShell Remoting.
        Test-WsMan 192.168.1.3


    #voer dit commando uit...
        Invoke-Command -ComputerName 192.168.1.3 -ScriptBlock { Get-ChildItem C:\ } -Credential administrator



    #een Powershell sessie remote uitvoeren
        Enter-PSSession -ComputerName 192.168.1.3 -Credential administrator

# nu is het mogelijk om machines Remote vanop DC1 onderandere lid te maken van het Domian 