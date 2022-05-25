############################################
# Written on 27 JUL 2014                   #
# By: CW2 Dieppa, Phillip A.               #
#                                          #
############################################

[CmdletBinding()]
Param (
    [Parameter(Mandatory=$False)]
    [hashtable]$configData,
    [bool]$connectToExchange
)


if ($connectToExchange -eq $true) {
    $remoteExchange = Get-ChildItem "$env:ProgramFiles\Microsoft\Exchange *" -Filter "RemoteExchange.ps1" -Recurse
    . $remoteExchange
    Connect-ExchangeServer -auto
}

$commonDir = "..\config\common.ps1"
if ($configData -eq $null) {
    cd $PSScriptRoot
    #use dot notation to access the common functions
    . $commonDir

    #get the config file's Fully Qualified name to pass into the setConfigData
    $configFQName = Get-ChildItem -Path ..\config\config.ini | Select-Object FullName
    #load the config.ini
    $configData = @{}
    $configData = setConfigData $configFQName.FullName.ToString()
} else {
    cd $PSScriptRoot
    #use dot notation to access the common functions
    . $commonDir
}

Function mainMenuAction ($result) {
    
    switch ($result) {
        1 {
            #Display the Database Monitor
            $dir = $PSScriptRoot
            cmd /c start powershell -Mta -NoExit -Command "Set-Location -Path '$dir'; & '.\Exchange - Database Monitor\Database Monitor.ps1'" 
            #cmd /c powershell -Mta -NoExit -Command "Set-Location -Path '$dir'; & '.\Exchange - Database Monitor\Database Monitor.ps1'" 
            #& '.\Exchange - Database Monitor\Database Monitor.ps1'
            & $PSCommandPath -configData $configData -connectToExchange $false

        }

        2 {
            #Display the Reboot launcher
            & '.\Exchange - Reboot Exchange Servers\Reboot Exchange Servers.ps1' -configData $configData
        }

        3 {
            #Delete Mailbox Dumpsters
            & '.\Exchange - Delete Mailbox Dumpsters\Delete Mailbox Dumpsters.ps1' -configData $configData
            #powershell.exe -noexit -command ". 'C:\Program Files\Microsoft\Exchange Server\V14\bin\RemoteExchange.ps1'; Connect-ExchangeServer -auto; "
        }

        4 {
            #Search and Delete Messages (ExMerge)
            & '.\Exchange - Search and Delete Messages\Search and Delete Messages.ps1' -configData $configData
            #powershell.exe -noexit -command ". 'C:\Program Files\Microsoft\Exchange Server\V14\bin\RemoteExchange.ps1'; Connect-ExchangeServer -auto; "
        }

        5 {
            #Shared Mailbox Utility
            & '.\Exchange - Shared Mailbox Tool\Shared Mailbox Tool.ps1' -configData $configData
            #powershell.exe -noexit -command ". 'C:\Program Files\Microsoft\Exchange Server\V14\bin\RemoteExchange.ps1'; Connect-ExchangeServer -auto; "
        }

        6 {
            #load the previous script
            #Exchange Server Tools
            & '.\..\Launcher.ps1'
        }
        
        7 {
            #exit 
            exit
        }
        
        default {   
        }
    }
}

#Show the main menu
$result = 0
while ($result -eq 0) {
    #Clear the screen
    
    $title = "Exchange Maintenance Tools"
    $choices = @("Start Database Monitor", 
    "Reboot Exchange Servers", 
    "Empty Dumpsters Above 100MB",
    "Search and Delete Messages (ExMerge - Not Working)",
    "Shared Mailbox Utility", 
    "Back", 
    "Exit")
    $info = @("Exchange Servers", $configData.Get_Item("ExchangeServers"), "User Account OU", $configData.Get_Item("UserAccountOU"), "Log Directory", $configData.Get_Item("LogDirectory"))
    #$info = @()
    [int]$result = displayMenu $title $choices $info

    #Only accept data within the bounds of the choices - reject everything else.
    if (($result -le 0) -or ($result -gt $choices.Length)) {
        $result = 0
    }

}

#Perform the operation
mainMenuAction($result)