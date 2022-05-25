<#
.SYNOPSIS
	Collect OSD Logs 
	
.DESCRIPTION
	Used to harvest deployment logs in an SCCM task sequence, for troubleshooting purposes.

.EXAMPLE
	Collect logs using the drive letter specified 
	.\Invoke-CollectLogs.ps1 -MappedDriveLetter L:

	Collect logs without using ZIP compression for the destination
	.\Invoke-CollectLogs.ps1 -MappedDriveLetter L: -DoNotCompress

	Verbose output
	.\Invoke-CollectLogs.ps1 -MappedDriveLetter L: -Verbose

.NOTES
    FileName:    Invoke-CollectLogs.ps1
    Author:      Maurice Daly
    Contact:     @MoDaly_IT
    Created:     2019-02-13
    Updated:     2019-02-26

    Version history:
	1.0.0 - (2019-02-13) Script created
	1.0.1 - (2019-02-19) Added additional checking logic for script paths
	1.0.2 - (2019-02-21) Updated to compress logs before copying to the logs destination.
						 Renames legacy compressed logs using date creation stamp.
						 Removes network share after processing
	1.0.3 - (2019-02-25) Script will now use OSDComputerName variable where available
						 Logs now copied to temporary folder to avoid file locks
	1.0.4 - (2019-02-26) Updated with added logging		
						 Panther logs now captured
	1.0.5 - (2019-12-11) Updated to capture logs from _SMSTaskSequence folder
#>
[CmdletBinding(SupportsShouldProcess = $true)]
param (
	[parameter(Mandatory = $true, HelpMessage = "Specify the mapped drive letter")]
	[ValidateNotNullOrEmpty()]
	[string]$MappedDriveLetter,
	[parameter(Mandatory = $false, HelpMessage = "Do not compress or archive logs files")]
	[switch]$DoNotCompress = $false
)
Begin {
	# Load Microsoft.SMS.TSEnvironment COM object
	try {
		$TSEnvironment = New-Object -ComObject Microsoft.SMS.TSEnvironment -ErrorAction Continue
	} catch [System.Exception] {
		Write-Warning -Message "Unable to construct Microsoft.SMS.TSEnvironment object"
	}
}
Process {
	
	function Write-CMLogEntry {
		param (
			[parameter(Mandatory = $true, HelpMessage = "Value added to the log file.")]
			[ValidateNotNullOrEmpty()]
			[string]$Value,
			[parameter(Mandatory = $true, HelpMessage = "Severity for the log entry. 1 for Informational, 2 for Warning and 3 for Error.")]
			[ValidateNotNullOrEmpty()]
			[ValidateSet("1", "2", "3")]
			[string]$Severity,
			[parameter(Mandatory = $false, HelpMessage = "Name of the log file that the entry will written to.")]
			[ValidateNotNullOrEmpty()]
			[string]$FileName = "Invoke-CollectLogs.log"
		)
		# Determine log file location
		$LogFilePath = Join-Path -Path $TSEnvironment.Value("_SMSTSLogPath") -ChildPath $FileName
		
		# Construct time stamp for log entry
		$Time = -join @((Get-Date -Format "HH:mm:ss.fff"), " ", (Get-WmiObject -Class Win32_TimeZone | Select-Object -ExpandProperty Bias))
		
		# Construct date for log entry
		$Date = (Get-Date -Format "MM-dd-yyyy")
		
		# Construct context for log entry
		$Context = $([System.Security.Principal.WindowsIdentity]::GetCurrent().Name)
		
		# Construct final log entry
		$LogText = "<![LOG[$($Value)]LOG]!><time=""$($Time)"" date=""$($Date)"" component=""Invoke-CollectLogs"" context=""$($Context)"" type=""$($Severity)"" thread=""$($PID)"" file="""">"
		
		# Add value to log file
		try {
			Out-File -InputObject $LogText -Append -NoClobber -Encoding Default -FilePath $LogFilePath -ErrorAction Stop
			if ($Severity -eq 1) {
				Write-Verbose -Message $Value
			} elseif ($Severity -eq 3) {
				Write-Warning -Message $Value
			}
		} catch [System.Exception] {
			Write-Warning -Message "Unable to append log entry to LogCollection.log file. Error message at line $($_.InvocationInfo.ScriptLineNumber): $($_.Exception.Message)"
		}
	}
	
	function Test-FileAccess {
		# Test read-write access	
		try {
			# Create a random generated file name using GUID value
			$FileName = New-Guid
			$TestFilePath = (Join-Path -Path $MappedDriveLetter -ChildPath $FileName)
			Write-CMLogEntry -Value "Creating test access file - $TestFilePath" -Severity 1
			New-Item -Path $TestFilePath -ItemType File | Out-Null
			if (Test-Path -Path $TestFilePath) {
				# Remove file, access verified
				Write-CMLogEntry -Value "Removing test access file" -Severity 1
				Remove-Item -Path $TestFilePath
			}
			Return $true
		} catch [System.Exception] {
			Write-CMLogEntry -Value "Unable to write data to $($MappedDriveLetter)" -Severity 2
			Return $false
		}
	}
	
	function Copy-Logs {
		Write-Verbose -Message "Mapped Drive Letter is $($MappedDriveLetter)"
		# Copy SMSTS logs to share
		try {
			# Create machine name folder where required
			if (-not ([string]::IsNullOrEmpty($TSEnvironment.Value("OSDComputerName")))) {
				$LogsDirectory = Join-Path -Path $MappedDriveLetter -ChildPath $TSEnvironment.Value("OSDComputerName")
				Write-CMLogEntry -Value "Computer name is $($TSEnvironment.Value('OSDComputerName'))" -Severity 1
			} else {
				$LogsDirectory = Join-Path -Path $MappedDriveLetter -ChildPath $Env:COMPUTERNAME
				Write-CMLogEntry -Value "Computer name is $($env:COMPUTERNAME)" -Severity 1
			}
			Write-CMLogEntry -Value "Logs directory set to: $LogsDirectory" -Severity 1
			if ((Test-Path -Path $LogsDirectory) -eq $false) {
				Write-CMLogEntry -Value "Creating computer folder at the following path: $($LogsDirectory)" -Severity 1
				New-Item -Path $LogsDirectory -ItemType Dir | Out-Null
			}
			
			# Set log destination value
			$LogsSource = $TSEnvironment.Value("_SMSTSLogPath")
			
			# Manage / check for legacy zip files
			if ($DoNotCompress -eq $false) {
				Write-CMLogEntry -Value "ZIP compressing logs and copying from $LogsSource to $LogsDirectory" -Severity 1
				if (Test-Path -Path (Join-Path -Path $LogsDirectory -ChildPath "OSDLogs.zip")) {
					$ZippedFileCreation = Get-Item -Path (Join-Path -Path $LogsDirectory -ChildPath "OSDLogs.zip") | Select-Object -ExpandProperty CreationTime
					Write-CMLogEntry -Value "Existing log zip file found, created on $ZippedFileCreation" -Severity 1
					$NewZipName = "OSDLogs-$(($ZippedFileCreation).ToString('hhmm-dd-MM-yyyy')).zip"
					Write-CMLogEntry -Value "Archiving existing log zip file. Renaming to $NewZipName" -Severity 1
					if ((Test-Path -Path (Join-Path -Path $LogsDirectory -ChildPath $NewZipName)) -eq $false) {
						Write-CMLogEntry -Value "Archiving captured legacy log file" -Severity 1
						Write-CMLogEntry -Value "Appending date stamp $(($ZippedFileCreation).ToString('hhmm-dd-MM-yyyy'))" -Severity 1
						Rename-Item -Path (Join-Path -Path $LogsDirectory -ChildPath "OSDLogs.zip") -NewName $NewZipName
					} else {
						Remove-Item -Path (Join-Path -Path $LogsDirectory -ChildPath "OSDLogs.zip") -Force
					}
				}
			}
			
			# Copy Pather Setup logs
			if (Test-Path -Path (Join-Path -Path $env:SystemRoot -ChildPath "Panther")) {
				$PantherLogs = Join-Path -Path $env:SystemRoot -ChildPath "Panther"
				$PantherLogsDest = Join-Path -Path $env:TEMP -ChildPath "DeploymentLogs\Panther"
				if ((Test-Path -Path $PantherLogsDest) -eq $false) {
					Write-CMLogEntry -Value "Creating temporary folder - $PantherLogsDest" -Severity 1
					New-Item -Path $PantherLogsDest -ItemType Dir | Out-Null
				}
				Write-CMLogEntry -Value "Copying panther setup logs from $($PantherLogs)" -Severity 1
				Get-ChildItem -Path $PantherLogs -Recurse | Where-Object {
					$_.FullName -match ".log"
				} | Copy-Item -Destination $PantherLogsDest -Container -Recurse -Force
			}
			
			# Copy Dism logs
			if (Test-Path -Path (Join-Path -Path $env:SystemRoot -ChildPath "Logs\Dism\Dism.log")) {
				$DismLog = Join-Path -Path $env:SystemRoot -ChildPath "Logs\Dism\Dism.log"
				Write-CMLogEntry -Value "Copying dism log from $($DismLog)" -Severity 1
				Copy-Item -Path $DismLog -Destination (Join-Path -Path $env:TEMP -ChildPath "DeploymentLogs") -Force
			}
			
			# Copy SMS agent logs
			$SMSAgentLogPath = Join-Path -Path $env:SystemRoot -ChildPath "CCM\Logs"
			if (Test-Path -Path $SMSAgentLogPath) {
				Write-CMLogEntry -Value "Copying SMS agent logs from $($SMSAgentLogPath)" -Severity 1
				$SMSAgentLogsDest = Join-Path -Path $env:TEMP -ChildPath "DeploymentLogs"
				if ((Test-Path -Path $SMSAgentLogsDest) -eq $false) {
					Write-CMLogEntry -Value "Creating temporary folder - $SMSAgentLogsDest" -Severity 1
					New-Item -Path $SMSAgentLogsDest -ItemType Dir | Out-Null
				}
				Get-ChildItem -Path $SMSAgentLogPath | Where-Object {
					$_.Name -match "AppDiscovery|AppEnforce|ExeCmgr"
				} | Copy-Item -Destination (Join-Path -Path $env:TEMP -ChildPath "DeploymentLogs") -Container -Recurse -Force
			}
			
			# Copy SMS task sequence logs
			$SMSTaskSequenceLogPath = Join-Path -Path $env:SystemDrive -ChildPath "_SMSTaskSequence\Logs"
			if (Test-Path -Path $SMSTaskSequenceLogPath) {
				Write-CMLogEntry -Value "Copying task sequence logs from $($SMSTaskSequenceLogPath)" -Severity 1
				$SMSAgentLogsDest = Join-Path -Path $env:TEMP -ChildPath "DeploymentLogs"
				if ((Test-Path -Path $SMSAgentLogsDest) -eq $false) {
					Write-CMLogEntry -Value "Creating temporary folder - $SMSAgentLogsDest" -Severity 1
					New-Item -Path $SMSAgentLogsDest -ItemType Dir | Out-Null
				}
				Get-ChildItem -Path $SMSTaskSequenceLogPath -Recurse | Where-Object {
					$_.FullName -match ".log"
				} | Copy-Item -Destination (Join-Path -Path $env:TEMP -ChildPath "DeploymentLogs") -Force -Recurse -Container
			}
			
			# Copy logs to cater for locked files when compressing
			Write-CMLogEntry -Value "Copying logs from $(Join-Path -Path $env:TEMP -ChildPath "DeploymentLogs") to $LogsDirectory" -Severity 1
			Get-ChildItem -Path $LogsSource -Recurse | Where-Object {
				$_.FullName -match ".log"
			} | Copy-Item -Destination (Join-Path -Path $env:TEMP -ChildPath "DeploymentLogs") -Recurse -Container -Force
			if ($DoNotCompress -eq $true) {
				Get-ChildItem -Path (Join-Path -Path $env:TEMP -ChildPath "DeploymentLogs") -Recurse | Copy-Item -Destination $LogsDirectory -Container -Recurse -Force
			} else {
				Compress-Archive -Path (Join-Path -Path $env:TEMP -ChildPath "DeploymentLogs") -DestinationPath (Join-Path -Path $LogsDirectory -ChildPath "OSDLogs.zip") -CompressionLevel Optimal | Copy-Item -Destination $LogsDirectory
			}
			
		} catch [System.Exception] {
			Write-CMLogEntry -Value "Issues occured while copying logs to destination" -Severity 2
		}
	}
	
	# Check availability of the mapped drive specified	
	if (-not ([string]::IsNullOrEmpty($MappedDriveLetter))) {
		
		# Catch drive letter without :
		if ($MappedDriveLetter -notmatch ":") {
			$MappedDriveLetter = $MappedDriveLetter + ":"
		}
		
		# Run functions
		if ((Test-Path -Path $MappedDriveLetter) -eq $true) {
			Write-CMLogEntry -Value "The specified drive letter $($MappedDriveLetter) exists. Checking r/w access." -Severity 1
			if (Test-FileAccess -eq $true) {
				Write-CMLogEntry -Value "Calling copy logs function" -Severity 1
				Copy-Logs
				Write-CMLogEntry -Value "Removing mapped drive $MappedDriveLetter" -Severity 1
				net use $MappedDriveLetter /delete /y | Out-Null
			}
		}
	} else {
		Write-CMLogEntry -Value "Mapped drive letter not specificed" -Severity 1
	}
}
