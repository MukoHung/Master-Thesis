#This Variable must be true so that the loop will run for the menu, when the value is set to false the script ends
& "$PSScriptRoot\Invoke-RemoveOldData.ps1" "C:\Windows\Mercy\MachineManager-log*" 7

$invokeLogFile = "$PSScriptRoot\Invoke-LogToFile.ps1"
$logPath = "C:\Windows\Mercy\MachineManager-log $(Get-Date -UFormat '%m%d%y').txt"

& $invokeLogFile $logPath "Starting the the Machine Manager script"


#quick way to get a computername in a variable that can be used throughout the script
function Get-ComputerName{

$Script:ComputerName = Read-Host "Enter the computer name"

& $invokeLogFile $logPath "Changing the computer name to $ComputerName"

}



#hashtable that contains all the child script paths
$hashtable= @{

'1' = "$PSSCriptRoot\Get-NetworkInfo.ps1"
'2' = "$PSSCriptRoot\Get-ProcessInfo.ps1"
'3' = "$PSSCriptRoot\Invoke-RepairPrinter.ps1"
'4' = "$PSSCriptRoot\Get-Services.ps1"
'5' = "$PSSCriptRoot\Get-MonitorSerial.ps1"
'6' = "$PSSCriptRoot\Invoke-Logoff.ps1"
'7' = "$PSSCriptRoot\Invoke-RemoveCitrix.ps1"
'8' = "$PSSCriptRoot\Invoke-RemoteDesktop.ps1"
'9' = "$PSSCriptRoot\Get-ImprivataReminder.ps1"
'10' = "$PSSCriptRoot\Get-PCRole"
'11' = "$PSSCriptRoot\Install-Isirona.ps1"
'12' = "$PSSCriptRoot\Invoke-RepairALProfile.ps1"
'13' = "$PSSCriptRoot\Invoke-RepairGAProfile"
'14' = "$PSSCriptRoot\Restart-IsironaService.ps1"
'15' = "$PSSCriptRoot\swfs.ps1"
'16' = "$PSSCriptRoot\Get-MachineConnection.ps1"
'17' = "$PSSCriptRoot\Invoke-Win10EasyTrasnfer.ps1"
'18' = "$PSSCriptRoot\Remove-Imprivata.ps1"
'19' = "$PSSCriptRoot\Install-Isirona.ps1"
'20' = "$PSSCriptRoot\Set-AutoLogon.ps1"
'21' = "$PSSCriptRoot\Invoke-Restart.ps1"
'22' = "$PSSCriptRoot\Get-LastIP.ps1"
'23' = "$PSSCriptRoot\Invoke-GPUpdate.ps1"
'24' = "$PSSCriptRoot\Invoke-PSS.ps1"
'25' = "$PSSCriptRoot\Invoke-PowerOff.ps1"
'26' = "$PSSCriptRoot\Get-UserHistory.ps1"
'27' = "$PSSCriptRoot\Invoke-SCCMRemote.ps1"
'28' = "$PSSCriptRoot\Invoke-ExplorerToPCC.ps1"
'29' = "$PSSCriptRoot\Invoke-AllowCCMRemote.ps1"
'30' = "$PSSCriptRoot\Invoke-ExplorertoMA.ps1"
'31' = "$PSSCriptRoot\Invoke-StopCCMViewer.ps1"
'32' = "$PSSCriptRoot\Get-OnlineAlert.ps1"
'33' = "$PSSCriptRoot\Get-CCMServiceAlert.ps1"
'34' = "$PSSCriptRoot\Set-MMBG.ps1"


}



#The main loop for the menu
While ($true) {
       
       Write-Output "`n`n"
     
       Write-Host -ForegroundColor Green "`t   Menu" -NoNewline
       Write-Host -ForegroundColor Cyan "    $ComputerName" 
       Write-Host -ForegroundColor Yellow "
       1. Network Adapater information
       2. Active Processes
       3. Printer Issues/Stuck Jobs
       4. Manage Services - Running/Stopped/Search 
       5. Monitor Serial Number
       6. Logoff Conneceted User
       7. Remove Citrix
       8. RDP Into a Machine
       9. Imprivata Policy Change Reminder / under construction
       10. Get Role of PC
       11. Install Isirona
       12. Repair Auto Login Profile
       13. Repair GA Profile
       14. Restart the Isirona Service
       15. Switch Computer Name to Serial
       16. Check Computer and Filesystem Access
       17. Windows 10 Transfer
       18. Remove Imprivata
       19. Install Isirona
       20. Set AutoLogon
       21. Restart the computer
       22. Get DNS info
       23. GPUPDATE
       24. Enter PSSESSION
       25. Power Off computer
       26. Get User History
       27. SCCM Remote
       28. Open Explorer to PC
       29. Allow CCM Remote
       30. Explorer to Manual Apps
       31. Kill CCM Viewer
       32. Wait until machine is online - 5 minutes
       33. Wait Until Online and CCM Remote - 5 minutes
       34. Change background - WIN10 Project
       C. Change Active Computer
       0. EXIT
       "
       #getting users choice and running the script associated to the key in the hashtable
       $userInput = Read-Host -Prompt "Enter an option"


       if($userinput -eq 'C'){Get-ComputerName}

       elseif($userinput -eq '0'){& $invokeLogFile $logPath "Stopping the script cleanly"
                                  break
             }

       elseif(!$hashtable.ContainsKey($userInput)){

              Write-Output "ENTER A VALID INPUT!";Start-Sleep -Seconds 1
              & $invokeLogFile $logPath "The user did not enter a valid input"}
       else{

            foreach($option in $hashtable.GetEnumerator()){
                    if($userInput -eq $option.key){& $hashtable[$userInput] $ComputerName
                        & $invokeLogFile $logPath "Ran the script $($hashtable[$userInput])"}
       
             }

        }
}


