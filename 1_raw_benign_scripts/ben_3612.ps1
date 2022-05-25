#requires -version 4.0

#originally from http://poshcode.org/5085

Function Send-PopupMessage {

<#
.SYNOPSIS
Send a graphical popup message.
.DESCRIPTION
This command is a PowerShell wrapper for the MSG.EXE command line tool. You can use this to display a popup message for yourself, or users on remote computers. By default the popup message will automatically dismiss in 60 seconds or you can specify a timeout value in seconds. 

By default command execution will continue immediately. If you use -Wait then PowerShell will wait until the user clicks OK or until the default 60 second timeout is reached.

The intention is that you will incorporate this command into your scripts.

    #dot source the function
    . c:\scripts\Send-PopupMessage.ps1
    #your code
    Send-PopupMessage -message "Task is Complete. Processed $count items." -timeout 30

You must have administrator privileges on any remote computers you want to send to.
.PARAMETER Message
Enter the text of your message. The message must be less than 262 characters in length.
.PARAMETER Username
The name of a logged on user or use * to indicate all users on a computer. Do not include the domain or machinename component.
.PARAMETER Computername
The name of a computer. You must have administrator privileges on any remote computer. This command has aliases of: CN
.PARAMETER TimeOut
The timeout value in seconds. If you set the value to 0, the message box will never be dismissed until someone acknowledges it. Use with caution when sending to remote computers.
.PARAMETER Wait
Force PowerShell to pause until the message box is dismissed. This is useful in scripting situations where you want to wait until the user acknowledges the message.
.EXAMPLE
Send-PopupMessage "Birthday cake in the breakroom" -username Bob -computername BobDesk -timout 30

Send a popup message to Bob on his desktop with a 30 second timeout.

.EXAMPLE
Get-Eventlog system -Newest 1 -EntryType Error | select Message | Send-PopupMessage

Get the last error from the system eventlog and display as a popup message for the current user.

.NOTES
NAME        :  Send-PopupMessage
VERSION     :  2.0   
LAST UPDATED:  7/7/2016
AUTHOR      :  Jeff Hicks (@JeffHicks)

Learn more about PowerShell:
http://jdhitsolutions.com/blog/essential-powershell-resources/

  ****************************************************************
  * DO NOT USE IN A PRODUCTION ENVIRONMENT UNTIL YOU HAVE TESTED *
  * THOROUGHLY IN A LAB ENVIRONMENT. USE AT YOUR OWN RISK.  IF   *
  * YOU DO NOT UNDERSTAND WHAT THIS SCRIPT DOES OR HOW IT WORKS, *
  * DO NOT USE IT OUTSIDE OF A SECURE, TEST SETTING.             *
  ****************************************************************
.LINK
.INPUTS
[string]
.OUTPUTS
None
#>

[cmdletbinding(DefaultParameterSetName="Time")]    

Param (
[Parameter(
Position=0,
Mandatory,
HelpMessage="Enter the text of your message",
ValueFromPipeline,
ValueFromPipelineByPropertyName
)]
[ValidateNotNullorEmpty()]
[string]$Message,

[Parameter(ValueFromPipelineByPropertyName)]
[ValidateNotNullorEmpty()]
[string]$Username = "*",

[Parameter( ValueFromPipelineByPropertyName )]
[ValidateNotNullorEmpty()]
[Alias("CN")]
[string[]]$Computername = $env:computername,

[Parameter(ParameterSetName="Time")]
[int32]$TimeOut,
[Parameter(ParameterSetName="Wait")]
[switch]$Wait

)

Begin {
    Write-Verbose "[BEGIN  ] Starting: $($MyInvocation.Mycommand)"
} #Begin

Process {

    #Don't send a message to * on a remote computer with -Wait.
    if ($Wait -AND ($Username -eq "*") -AND ($Computername -notmatch "$($env:computername)|localhost|127.0.0.1")) {
        Write-Warning "You should specify a username when using -Wait on a remote computer."
        #Bail out
        Return
    }

    #display PSBoundparameters formatted nicely for Verbose output  
    [string]$pb = ($PSBoundParameters | Format-Table -AutoSize | Out-String).TrimEnd()
    Write-Verbose "[PROCESS] PSBoundparameters: `n$($pb.split("`n").Foreach({"$("`t"*4)$_"}) | Out-String) `n" 

    if ($Message.Length -gt 262) {
        Write-Verbose "[PROCESS] The message is too long ($($message.length)). Truncating."
        $Message = $Message.Substring(0,262)
    }        

    foreach ($Computer in $Computername) {
        #create the MSG.exe command
        Write-Verbose "[PROCESS] Creating a message for $Username on $Computer"
        $cmd = "msg.exe $Username /SERVER:$Computer "

        if ($Timeout -gt 0) {
            $cmd+="/time:$timeout "
        }
        elseif ($Wait) {
            $cmd+="/W "
        }

        #add the message
        $cmd+=$Message

        #redirect errors
        $errFile = "$($env:temp)\msg.err"
        $cmd+=" 2>$errFile"
        Write-Verbose "[PROCESS] Command: $cmd"

        #turn the command into a scriptblock
        $sb = [scriptblock]::Create($cmd)

        #execute it
        Invoke-Command -ScriptBlock $sb

        #test if there is an error file that has something in it
        if ( (Test-Path $errFile) -AND ((Get-Item -Path $errFile).Length -gt 0)) {
            Write-Warning "[$Computer] $($error[0].Exception.Message)"
        }

        #remove err file which may only be a 0 byte file
        Write-Verbose "[PROCESS] Removing $errFile"
        Remove-Item -Path $errFile
    } #foreach
} #Process

End {
    Write-Verbose "[END    ] Ending: $($MyInvocation.Mycommand)"
} #end

}

#define an optional alias
Set-Alias -Name spm -Value Send-PopUpMessage