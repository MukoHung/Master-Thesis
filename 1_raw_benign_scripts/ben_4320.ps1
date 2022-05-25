#Checks the status of $ServiceName and kills it if in the 'Stop Pending' state.
#Creates an event log; logs results to it
#Get-Random (Get-Service | Select-Object -ExpandProperty Name) | Kill-HungService -Verbose

Function script:Kill-HungService {
[CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline=$True,Mandatory=$True,HelpMessage="Service to search for")]
        [string]$script:ServiceName
    )
$Service = Get-WmiObject -Class win32_service -Filter "Name = '$ServiceName'"
    If ($Service.State -eq "Stop Pending"){
		Stop-Process -Id $Service.ProcessId -Force -PassThru -ErrorAction Stop
		$EventID = "002"
		$Message = "The service $ServiceName was killed"
    }
 
    Else {
        $EventID = "003"
        $Message = "The service $ServiceName did not need to be killed"
    }
    Write-Verbose $Message
} #End Kill-HungService

Function script:Register-Events {
[CmdletBinding()]
    param(
        [Parameter(Mandatory=$True,HelpMessage="Event log name")]
        [string]$LogName = "UnFUBAR-Service"
    )
	Try { 
            Get-EventLog -LogName $LogName -ErrorVariable LogExists | Out-Null
	}
	Catch {
	}
	If ($LogExists.Message -like '*does not exist*') {
	    New-EventLog -LogName $LogName -Source "$LogName.ps1"
	}
	Write-EventLog -LogName $LogName -Source "$LogName.ps1" -EntryType Information -EventID $EventID -Message $Message
} #End Register-Events

. Kill-HungService
. Register-Events