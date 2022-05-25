<# DANGER REBOOTING! #>
$msg = "Due to installs/updates of SQL Prompt, this computer must be restarted. You have 15 minutes to save your work"
$delay = 900 # seconds
shutdown /r /f /d P:4:1 /t`$($delay) /c "$msg" 2>$null
if ($LastExitCode -ne 0) {
    Write-Host "Cannot reboot $PC ($LastExitCode)" -ForegroundColor black -BackgroundColor red

}
else {
    #LogWrite "$env:username,$PC,Reboot Sent,$datetime" #fix this...
    # Set Variables
    $eventLog = "System"
    $eventSource = "RebootScript2021-11-20_LRR"
    $eventID = 9037 # 8191 Highest System-Defined Audit Message Value? source: https://www.andreafortuna.org/2019/06/12/windows-security-event-logs-my-own-cheatsheet/
    $entryType = "Error"
    $whoami = "$env:USERDOMAIN`\$env:USERNAME"
    $eventIDMessage = "Rebooting System from script initiated by user $($whoami)"

    # Set Error Action Preference to Stop for Try Catch code
    $ErrorActionPreference = "stop"
        If ([System.Diagnostics.EventLog]::SourceExists($eventSource) -eq $False) {
            New-EventLog -LogName System -Source $eventSource
        }

    # Write EventLog Function
    function Write-SysEventLog {
        Param($errorMessage)
        #Write-EventLog -LogName $eventLog -EventID $eventID -EntryType $entryType -Source $eventSource -Message $errorMessage
        $paramHash = @{
            LogName = $eventLog
            EventID = $eventID
            EntryType = $entryType
            Source = $eventSource
            Message = $errorMessage
        }
        
        Write-EventLog @paramHash
        }

    Try {
        #<# debug #>1/0
        Write-SysEventLog @paramHash -Message $eventIDMessage
    }
    Catch {
        $errorMessage = $_.Exception.message
        Write-SysEventLog $errorMessage
        }
}
<#

References:
https://stackoverflow.com/questions/18107018/powershell-with-shutdown-command-error-handling/18109510#18109510
https://www.ciraltos.com/writing-event-log-powershell/
https://devblogs.microsoft.com/scripting/how-to-use-powershell-to-write-to-event-logs/
https://www.andreafortuna.org/2019/06/12/windows-security-event-logs-my-own-cheatsheet/

#>