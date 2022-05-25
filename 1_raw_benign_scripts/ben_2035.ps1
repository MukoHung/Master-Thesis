<#
.SYNOPSIS
	Dynamically generate OSDComputerName variable based on device type and serial number (limited to 9 characters)
	
.EXAMPLE
	.\Invoke-DynamicOSDName.ps1 

.NOTES
    FileName:    Invoke-DynamicOSDName.ps1 
    Author:      Maurice Daly
    Contact:     @MoDaly_IT
    Created:     2020-03-15
    Updated:     2020-03-15

    Version history:
	1.0.0 - (2020-03-15) Script created
#>

$Namespace = "ROOT\cimv2"
$Classname = "Win32_SystemEnclosure"
$SystemDetails = Get-WmiObject -Class $Classname -Namespace $Namespace | Select-Object * -ExcludeProperty PSComputerName, Scope, Path, Options, ClassPath, Properties, SystemProperties, Qualifiers, Site, Container

# Load Microsoft.SMS.TSEnvironment COM object
if ($PSCmdLet.ParameterSetName -like "Execute") {
	try {
		$TSEnvironment = New-Object -ComObject Microsoft.SMS.TSEnvironment -ErrorAction Continue
	} catch [System.Exception] {
		Write-Warning -Message "Unable to construct Microsoft.SMS.TSEnvironment object"
	}
}

function Set-OSDComputerName {
	# Set computername prefix
	if (($SystemDetails | Select-Object -ExpandProperty ChassisTypes) -match "9|10") {
		# Laptop chassis type detected
		$SystemType = "LT-"
	} elseif (($SystemDetails | Select-Object -ExpandProperty ChassisTypes) -match "3|4|6|7") {
		# Desktop chassis type detected
		$SystemType = "DT-"
	} else {
		# Fallback to VM
		$SystemType = "VM-"
	}
	
	# Add serial number and set value
	if ($($SystemDetails.SerialNumber).Count -lt 9) {
		# Measure serial number and extract serial if less than 9 characters
		$ComputerName = $SystemType + $($SystemDetails.SerialNumber).Substring(0,($SystemDetails.SerialNumber | Measure-Object -Character | Select-Object -ExpandProperty Characters))
	} else {
		# Capture first 9 characters of the serial number
		$ComputerName = $SystemType + $($SystemDetails.SerialNumber).Substring(0, 9)
	}
	
	# Set OSDComputerName variable
	$TSEnvironment.value("OSDComputerName") = $ComputerName
	Return $ComputerName
}

Set-OSDComputerName