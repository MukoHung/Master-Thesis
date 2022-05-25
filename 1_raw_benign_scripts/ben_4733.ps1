# ===========================================================================================
# 
# NAME: Zabbix_InstallAgent.ps1
# 
# AUTHOR: Pierre-Emmanuel Turcotte, 
# DATE  : 2012-11-05
# 
# COMMENT:	Remote installation of Zabbix agent from central location.
#
#			The zabbix source folder is a folder containing subfolder corresponding to the 
#			different agent versions. These subfolders contain the win32 and win64 subfolders
#			along with the zabbix_agentd.win.conf configuration file.
#
#			You must have administrative priviledges on the remote computers you will specify
#			in the computerName parameter. You can either use the following format:
#
#			zabbix_installagent.ps1 -ComputerName server1,server2,server3
#
#			or do not specify any servers, you will be prompted for servers, one at a time.
#
#			Additionnally, you have the following parameters you can optionally define:
#
#			-ZabbixVersion 		#Version of the agent to be installed(points to subfolder)
#								 Defaults to "2.0.3"
#			-ZabbixPath			#Folder where the agent installation resides on the central
#								 server. This is the folder that will be copied over to the
#								 remote locations.
#								 Defaults to "O:\Zabbix"
#
#			About the zabbix path, on my installation, this folder holds 3 subfolders:
#
#			O:\Zabbix
#					 \1.8.10
#					 \2.0
#					 \2.0.3
#
#			$ZabbixPath and $ZabbixVersion will be assembled in a new variable named
#			$ZabbixSource, look for it for a better undestanding.
#
# DISCLAIMER
#
# The sample script provided here are not supported by Pierre-Emmanuel Turcotte or his 
# employer. All scripts are provided AS IS without warranty of any kind. Pierre-Emmanuel
# Turcotte and his employer further disclaims all implied warranties including, without 
# limitation, any implied warranties of merchantability or of fitness for a particular 
# purpose. The entire risk arising out of the use or performance of the sample scripts 
# and documentation remains with you. In no event shall Pierre-Emmanuel Turcotte or his 
# employer, its authors, or anyone else involved in the creation, production, or delivery
# of the scripts be liable for any damages whatsoever (including, without limitation,
# damages for loss of business profits, business interruption, loss of business information,
# or other pecuniary loss) arising out of the use of or inability to use the sample scripts
# or documentation, even if Pierre-Emmanuel Turcotte or his employer has been advised of the
# possibility of such damages.
# 
# ===========================================================================================

# ===========================================================================================
# Parameters
# ===========================================================================================
[CmdletBinding()]
Param(
	[Parameter(Mandatory=$True,Position=1)]
	[array]$computerName,
	[string]$ZabbixPath = "E:\Proyectos\zabbix",
	[string]$ZabbixVersion = "3.4.4"
)

# ===========================================================================================
# Initialization
# ===========================================================================================
$ZabbixService = "Zabbix Agent"
$ZabbixSource = "$ZabbixPath\$ZabbixVersion"
$instOk
$instBad
# ===========================================================================================
# Welcome message
# ===========================================================================================
Write-Host "================================================================================"
Write-Host " Welcome!" 
Write-Host " This script requires administrative privileges on all implicated servers!"  
Write-Host "================================================================================"


# ===========================================================================================
# Verifying the source installation folder
# ===========================================================================================
Write-Host "================================================================================"
Write-Host " Zabbix source installation folder:" $ZabbixSource 

if (!(Test-Path $ZabbixSource))
{
	Write-Host " "
	Write-Host "########################################"
	Write-Host "# Error! - Folder does not exist!	   #"
	Write-Host "########################################"
	Write-Host " "
	exit
}
Write-Host "================================================================================"

# ===========================================================================================
# Execute actions for each server in list
# ===========================================================================================
foreach($computer in $computerName)
{
	$zabbixDestination = "\\$computer\C$\Zabbix\$ZabbixVersion"
	$ZabbixServiceState = $false
	If ((Test-Connection $computer -quiet -count 1))
	{
		# Server pings!
		Write-Host "================================================================================"
		Write-Host $computer "is available"
		Write-Host "================================================================================"
		# Verify if service is present...
		# Negative response may be caused by the absence of service (good!) or lack of priviledges (bad!)
		if (Get-Service -ComputerName $computer -Name $ZabbixService -ErrorAction SilentlyContinue)
		{
			# Zabbix Agent is present!
			# Bool. Get service state!
			$ZabbixServiceState = ((Get-Service -ComputerName $computer -Name $ZabbixService).status -ne "Stopped")	
			
			# Verify service state! Stop if necessary!
			if ($ZabbixServiceState)
			{
				# Zabbix agent present and started!
				try
				{
					Write-Host "================================================================================"
					Write-Host " Stopping Zabbix Agent..."
					Write-Host "================================================================================"
					Set-Service -ComputerName $computer -Status Stopped -Name $ZabbixService -ErrorAction Stop
					Start-Sleep -Seconds 3
				}
				catch
				{
					Write-Host "================================================================================"
					Write-Host " $computer - Zabbix agent could not be installed!"
					Write-Host " Service operation error!" $_			
					Write-Host "================================================================================"
					$instBad += $computer + " "
					Continue														# Next server!
					
				}
				Write-Host "================================================================================"
				Write-Host " Zabbix service stopped."
				Write-Host " Install new agent..."
			}
			else
			{
				Write-Host "================================================================================"
				Write-Host " Service $ZabbixService on $computer is stopped."	# Ok!
				Write-Host " Install new agent..."
			}	
		}
		else
		{
			Write-Host "================================================================================"
			Write-Host " Service $zabbixAgent not found."				# Ok!
			Write-Host " Install Zabbix agent..."
		}
		# Copy over zabbix folder, make sure no FW could block this
		try
		{
			# If folder exists, it will be overwritten. 
			# At this point, service should've been stopped...
			Copy-Item -Recurse $ZabbixSource $zabbixDestination -Force -ErrorAction Stop
			Write-Host " Copying folder..."
		}
		catch
		{
			Write-Host "================================================================================"
			Write-Host " $computer - Zabbix agent could not be installed!"
			Write-Host " Make sure you have administrative rights on target!"
			Write-Host " Copy error!" $_
			Write-Host "================================================================================"
			$instBad += $computer + " "
			continue																# Next Server
		}
		Write-Host " Folder successfully copied!"									# No catch triggered, so far so good...
		
		#################################################################################################################################
		# At this point, the service state has been determined and the folder has been copied to, rights should not be an issue...
		# Let's install...
		#################################################################################################################################
		
		### Get architecture x86 or x64...
		try
		{
			$os= Get-WMIObject -Class win32_operatingsystem -ComputerName $computer -ErrorAction Stop
		}
		catch
		{
			Write-Host "================================================================================"
			Write-Host " $computer - Zabbix agent could not be installed!"
			Write-Host " -- Make sure you have administrative rights!"
			Write-Host " -- Make sure no firewall is blocking communications!"
			Write-Host " Error!" $_
			Write-Host "================================================================================"
			$instBad += $computer + " "
			continue
		}
		if($os.OSArchitecture -ne $null)
		{
			# Architecture can be determined by $os.OSArchitecture...
			if ($os.OSArchitecture -eq "64-bit")
			{
				Write-Host " 64bit system detected!"
				$osArch = "win64"
			}
			elseif($os.OSArchitecture -eq "32-bit")
			{
				Write-Host " 32bit system detected!"
				$osArch = "win32"
			}
			else
			{
				Write-Host "================================================================================"
				Write-Host " Unknown architecture! Operation Canceled..."
				Write-Host $osArch
				Write-Host "================================================================================"
				$instBad += $computer + " "
				continue
			}
		}
		else
		{
			Write-Host " Windows Pre-2008"
			# Here have to analyze $os.Caption to determine architecture...
			if($os.Caption  -match "x64")
			{
				Write-Host " 64bit system detected!"
				$osArch = "win64"
			}
			else
			{
				Write-Host " 32bit system detected!"
				$osArch = "win32"
			}
		}
		### Architecture detection ended.
		### Begin installation...
		try
		{
			# Create uninstall string
			Write-Host " Create uninstall string..."
			$exec = "c:\zabbix\" + $zabbixVersion + "\bin\" + $osArch + "\zabbix_agentd.exe -c c:\zabbix\" + $zabbixVersion + "\conf\zabbix_agentd.win.conf -d"
			Write-Host "$exec"
			# Execute uninstall string
			Write-Host " Execute uninstall string..."
			$remoteWMI = Invoke-WMIMethod -Class Win32_Process -Name Create -Computername $computer -ArgumentList $exec
			Start-Sleep -Second 3 
			if ($remoteWMI.ReturnValue -ne 0)
			{
				# Oops...
				Write-Host "================================================================================"
				Write-Host " Problem while uninstalling previous zabbix agent! Cancelling..."
				Write-Host " Error:" $remoteWMI.ReturnValue
				Write-Host " 0 Successful Completion"
				Write-Host " 3 Insufficient Privilege"
				Write-Host " 8 Unknown Failure"
				Write-Host " 9 Path Not Found"
				Write-Host " 21 Invalid Parameter"
				Write-Host "================================================================================"
				$instBad += $computer + " "
				continue
			}
		}
		catch
		{
			Write-Host "================================================================================"
			Write-Host " Problem while uninstalling previous zabbix agent! Cancelling..."
			Write-Host $_
			Write-Host "================================================================================"
			$instBad += $computer + " "
			continue
		}
		try
		{
			# Create install string
			Write-Host " Create install string..."
			$exec = "c:\zabbix\" + $zabbixVersion + "\bin\" + $osArch + "\zabbix_agentd.exe -c c:\zabbix\" + $zabbixVersion + "\conf\zabbix_agentd.win.conf -i"
			Write-Host "$exec"
			# Execute install string
						Write-Host " Execute install string..."
			$remoteWMI = Invoke-WMIMethod -Class Win32_Process -Name Create -Computername $computer -ArgumentList $exec
			Start-Sleep -Second 3
			$enabledresult = (gwmi win32_service -computername $computer -filter "name='Zabbix Agent'").ChangeStartMode("Automatic")
			Write-Host '$enabledresult'
			if ($remoteWMI.ReturnValue -ne 0)
			{
				# Oops...
				Write-Host "================================================================================"
				Write-Host " Problem while installing new agent! Cancelling..."
				Write-Host " Error: " $remoteWMI.ReturnedValue
				Write-Host " 0 Successful Completion"
				Write-Host " 3 Insufficient Privilege"
				Write-Host " 8 Unknown Failure"
				Write-Host " 9 Path Not Found"
				Write-Host " 21 Invalid Parameter"
				Write-Host "================================================================================"
				$instBad += $computer + " "
				continue
			}
		}
		catch
		{
			Write-Host "================================================================================"
			Write-Host " Problem while installing new agent! Cancelling..."
			Write-Host $_
			Write-Host "================================================================================"
			$instBad += $computer + " "
			continue
		}
		try
		{
			# Create run string
			Write-Host " Create run string..."
			$exec = "c:\zabbix\" + $zabbixVersion + "\bin\" + $osArch + "\zabbix_agentd.exe -c c:\zabbix\" + $zabbixVersion + "\conf\zabbix_agentd.win.conf -s"
			Write-Host "$exec"
			# Execute run string
			Write-Host " Execute run string..."
			$remoteWMI = Invoke-WMIMethod -Class Win32_Process -Name Create -Computername $computer -ArgumentList $exec
			Start-Sleep -Second 3
			if ($remoteWMI.ReturnValue -ne 0)
			{
				# Problème...
				Write-Host "================================================================================"
				Write-Host " Problem while starting the agent! Cancelling..."
				Write-Host " Error: " $remoteWMI.ReturnedValue
				Write-Host " 0 Successful Completion"
				Write-Host " 3 Insufficient Privilege"
				Write-Host " 8 Unknown Failure"
				Write-Host " 9 Path Not Found"
				Write-Host " 21 Invalid Parameter"
				Write-Host "================================================================================"
				$instBad += $computer + " "
				continue
			}
		}
		catch
		{
			Write-Host "================================================================================"
			Write-Host " Problem while starting the agent! Cancelling..."
			Write-Host $_
			Write-Host "================================================================================"
			$instBad += $computer + " "
			continue
		}
		### Installation end...
		### Start verification
		try
		{
			$InstallStatus = Get-Service -ComputerName $computer -Name $ZabbixService
		}
		catch
		{
			Write-Host "================================================================================"
			Write-Host " Problem while verifying service!"
			Write-Host " Error! " $_
			Write-Host "================================================================================"
			$instBad += $computer + " "
			continue
		}
		if ($InstallStatus.Status -eq "Running")
		{
			Write-Host "================================================================================"
			Write-Host " Service installed and started!"
			Write-Host "================================================================================"
		}
		else
		{
			Write-Host "================================================================================"
			Write-Host " Service installed but not started!"
			Write-Host " Service state: " $InstallStatus.Status
			Write-Host "================================================================================"
		}
		$instOk += $computer + " "
	}
	Else
	{
		Write-Host $computer "is not available! Skipping!"
		$instBad += $computer + " "
		Continue																# Next server
	}
}
Write-Host "================================================================================"
Write-Host " SCRIPT FINISHED!"
Write-Host " Successful installations: " $instOk
Write-Host " Unsuccessful installations: " $instBad
Write-Host "================================================================================"
Write-Host " "
Write-Host " Press any key!"
$waitForIt = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
exit 0