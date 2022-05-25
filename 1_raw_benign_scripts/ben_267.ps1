Function Get-Uptime{
[Cmdletbinding()]
	Param (
		[Parameter(ValueFromPipeline=$true)]
		[ValidateNotNullorEmpty()]
		[String[]]$ComputerName = $Env:COMPUTERNAME
	)
	BEGIN{
#		
		$UptimeReport = @()
	}
	PROCESS{
		foreach ($Computer in $ComputerName){
#		Test if Machine is online
			if(Test-Connection -ComputerName $Computer -Count 1 -Quiet){
				$OS = Get-WmiObject -Class Win32_OperatingSystem -ComputerName $Computer -ErrorAction SilentlyContinue -ErrorVariable Err
#				If the uptime details can't be found, update status as ERROR
				if($Err){
					$StartTime = "Cannot confirm"
					$Uptime = "Cannot confirm"
					$Status = "ERROR"
					$MightNeedPatching = "Cannot confirm"
					Clear-Variable Err
				}
#				Process the Machine status - uptime, patching needed, start time
				else{
					$Status = "OK"
					$LastBootUpTime = $OS.ConvertToDateTime($OS.LastBootupTime)
					$LocalDateTime = $OS.ConvertToDateTime($OS.LocalDateTime)
					$StartTime = $LastBootUpTime.ToShortDateString() + " " + $LastBootUpTime.ToLongTimeString()
					$Uptime = ($LocalDateTime - $LastBootUpTime).Days
#					Round uptime to 1/10 of a day
					if((($LocalDateTime - $LastBootUpTime).TotalDays - ($LocalDateTime - $LastBootUpTime).Days) -ge 0.9){
						$Uptime++
					}
#					Check if patching is required - Rounding uptime to 1/10 of a month
					if($Uptime -gt 27){
						$MightNeedPatching = $True
					}
					else{
					    $MightNeedPatching = $False
					}
					}
					Clear-Variable LastBootupTime, LocalDateTime
				}
			}
#			If machine is offline, update Machine status as OFFLINE 
			else{
				$StartTime = "Machine Offline"
				$Uptime = "Machine Offline"
				$Status = "OFFLINE"
				$MightNeedPatching = "Machine Offline"
			}
#			Format Output as required
			$MachineStatus = New-Object -TypeName PSObject -Property @{"ComputerName"=$Computer;
											"StartTime" = $StartTime;
											"Uptime (Days)" = $Uptime;
											"Status" = $Status;
											"Might Need Patching" = $MightNeedPatching}
			$UptimeReport += $MachineStatus
#			Clear all temporary variables
			Clear-Variable MachineStatus, StartTime, Uptime, Status, MightNeedPatching 
		}
	}
	END{
#		Display output as required
		$UptimeReport |	select ComputerName, StartTime, "Uptime (Days)", Status, "Might Need Patching" | Format-Table -AutoSize
		Clear-Variable UptimeReport
	}
}