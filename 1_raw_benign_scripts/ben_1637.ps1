function Get-FISSystemInformation
{
<#
	.SYNOPSIS
		Gathers information on the target's system.
	
	.DESCRIPTION
		This function uses CIM to gather information about the target computer(s)'s system.
	
	.PARAMETER ComputerName
		The computer to gather information on.
		Can be an established CimSession, which will then be reused.
	
	.PARAMETER Credential
		The credentials to use to gather information.
		This parameter is ignored for local queries.
	
	.PARAMETER Authentication
		The authentication method to use to gather the information.
		Uses the system default settings by default.
		This parameter is ignored for local queries.
	
	.PARAMETER EnableException
		This parameters disables user-friendly warnings and enables the throwing of exceptions.
		This is less user friendly, but allows catching exceptions in calling scripts.
	
	.EXAMPLE
		PS C:\> Get-FISSystemInformation
	
		Returns system information on the local computer.
	
	.EXAMPLE
		PS C:\> Get-Content servers.txt | Get-FISSystemInformation
	
		Returns system information on all computers listed in servers.txt
	
	.EXAMPLE
		PS C:\> Get-ADComputer -Filter "name -like 'Desktop*'" | Get-FISSystemInformation
	
		Returns system information on all computers in ad whose name starts with "Desktop"
#>
	[OutputType([Fred.IronScripter2018.SystemInformation])]
	[CmdletBinding()]
	Param (
		[Parameter(ValueFromPipeline = $true)]
		[PSFComputer[]]
		$ComputerName = $env:COMPUTERNAME,
		
		[System.Management.Automation.CredentialAttribute()]
		[System.Management.Automation.PSCredential]
		$Credential,
		
		[Microsoft.Management.Infrastructure.Options.PasswordAuthenticationMechanism]
		$Authentication = [Microsoft.Management.Infrastructure.Options.PasswordAuthenticationMechanism]::Default,
		
		[switch]
		$EnableException
	)
	
	begin
	{
		Write-PSFMessage -Level InternalComment -Message "Bound parameters: $($PSBoundParameters.Keys -join ', ')" -Tag 'debug'
	}
	process
	{
		#region Process by Computer Name
		foreach ($Computer in $ComputerName)
		{
			Write-PSFMessage -Level VeryVerbose -Message "[$Computer] Establishing connection" -Target $Computer -Tag 'connect', 'start'
			
			try
			{
				if (-not $Computer.IsLocalhost)
				{
					if ($Computer.Type -like "CimSession") { $session = $Computer.InputObject }
					else { $session = New-CimSession -ComputerName $Computer -Credential $Credential -Authentication $Authentication -ErrorAction Stop }
					Write-PSFMessage -Level SomewhatVerbose -Message "[$Computer] Retrieving OS information" -Target $Computer -Tag 'os', 'get'
					$operatingSystem = Get-CimInstance -ClassName Win32_OperatingSystem -CimSession $session -ErrorAction Stop
					Write-PSFMessage -Level SomewhatVerbose -Message "[$Computer] Retrieving disk information" -Target $Computer -Tag 'disk', 'get'
					$disks = Get-CimInstance -ClassName Win32_LogicalDisk -CimSession $session -ErrorAction Stop
					if ($Computer.Type -notlike "CimSession") { Remove-CimSession -CimSession $session }
				}
				else
				{
					# No point in establishing a session to localhost, custom credentials also not supported
					Write-PSFMessage -Level SomewhatVerbose -Message "[$Computer] Retrieving OS information" -Target $Computer -Tag 'os', 'get'
					$operatingSystem = Get-CimInstance -ClassName Win32_OperatingSystem -ErrorAction Stop
					Write-PSFMessage -Level SomewhatVerbose -Message "[$Computer] Retrieving disk information" -Target $Computer -Tag 'disk', 'get'
					$disks = Get-CimInstance -ClassName Win32_LogicalDisk -ErrorAction Stop
				}
			}
			catch
			{
				Stop-PSFFunction -Message "[$Computer] Failed to connect to target computer" -Target $Computer -Tag 'connect', 'fail' -ErrorRecord $_ -EnableException $EnableException -Continue
			}
			
			$systemInfo = New-Object Fred.IronScripter2018.SystemInformation -Property @{
				ComputerName       = $Computer.ComputerName
				Name		       = $operatingSystem.Caption
				Version	           = $operatingSystem.Version
				ServicePack        = "{0}.{1}" -f $operatingSystem.ServicePackMajorVersion, $operatingSystem.ServicePackMinorVersion
				Manufacturer       = $operatingSystem.Manufacturer
				WindowsDirectory   = $operatingSystem.WindowsDirectory
				Locale		       = $operatingSystem.Locale
				FreePhysicalMemory = $operatingSystem.FreePhysicalMemory * 1024 # Comes in KB
				VirtualMemory      = $operatingSystem.TotalVirtualMemorySize * 1024 # Comes in KB
				FreeVirtualMemory  = $operatingSystem.FreeVirtualMemory * 1024 # Comes in KB
			}
			
			foreach ($disk in $disks)
			{
				$diskObject = New-Object Fred.IronScripter2018.DiskInfo -Property @{
					ComputerName  = $Computer.ComputerName
					Drive		  = $disk.DeviceID
					DriveType	  = $disk.Description
					Size		  = $disk.Size
					FreeSpace	  = $disk.FreeSpace
					Compressed    = $disk.Compressed
				}
				
				$systemInfo.Disks.Add($diskObject)
			}
			
			Write-PSFMessage -Level Verbose -Message "[$Computer] Finished gathering information" -Target $Computer -Tag 'success', 'finished'
			$systemInfo
		}
		#endregion Process by Computer Name
	}
	end
	{
		
	}
}