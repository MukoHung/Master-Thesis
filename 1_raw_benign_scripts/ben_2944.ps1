<#
.SYNOPSIS
    This script can be used check if the baseline is met for wellfleet
.DESCRIPTION
        This script can be used check if the baseline is met for wellfleet
.EXAMPLE
    C:\PS> .\baseline.ps1
To determine whether a machine is Laptop or not.#>

Function Get-osdisplayname {
    (Get-CimInstance Win32_OperatingSystem).Caption.Trim()   
}
Function Get-osbuild {
    (Get-CimInstance Win32_OperatingSystem).version.Trim()
}
Function Get-osarchitecture {
    (Get-WmiObject win32_processor | Where-Object{$_.deviceID -eq "CPU0"}).AddressWidth
}

Function Detect-Laptop
{
    Param( [string]$computer = “localhost” )
    $isLaptop = $false
    #The chassis is the physical container that houses the components of a computer. Check if the machine’s chasis type is 9.Laptop 10.Notebook 14.Sub-Notebook
    if(Get-WmiObject -Class win32_systemenclosure -ComputerName $computer | Where-Object { $_.chassistypes -eq 9 -or $_.chassistypes -eq 10 -or $_.chassistypes -eq 14})
    { $isLaptop = $true }
    #Shows battery status , if true then the machine is a laptop.
    if(Get-WmiObject -Class win32_battery -ComputerName $computer)
    {$isLaptop = $true }
    $isLaptop
}

#If(Detect-Laptop) { 
#    Write-host “it’s a laptop” 
#}
#else { 
#    Write-host "it’s not a laptop"
#}

function Get-UACStatus {
	[cmdletBinding(SupportsShouldProcess = $true)]
	param(
		[parameter(ValueFromPipeline = $false, ValueFromPipelineByPropertyName = $true, Mandatory = $false)]
		[string]$Computer
	)
	[string]$RegistryValue = "EnableLUA"
	[string]$RegistryPath = "Software\Microsoft\Windows\CurrentVersion\Policies\System"
	[bool]$UACStatus = $false
	$OpenRegistry = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine,$Computer)
	$Subkey = $OpenRegistry.OpenSubKey($RegistryPath,$false)
	$Subkey.ToString() | Out-Null
	$UACStatus = ($Subkey.GetValue($RegistryValue) -eq 1)
	#write-host $Subkey.GetValue($RegistryValue)
	return $UACStatus
}
function Get-InstalledApps{
    if ([IntPtr]::Size -eq 4) {
        $regpath = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*'
    }
    else {
        $regpath = @(
            'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*'
            'HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*'
        )
    }
    Get-ItemProperty $regpath | .{process{if($_.DisplayName -and $_.UninstallString) { $_ } }} | Select-Object DisplayName, Publisher, InstallDate, DisplayVersion, UninstallString | Sort-Object DisplayName
}



#if ($uacstatus -eq $true){
#    Write-host "uac is enabled"
#
#}
#else{
#    Write-host "uac is disabled"
#}

#record the computer name for posteriety
$computername = Get-CimInstance -ClassName Win32_ComputerSystem | Select-Object -ExpandProperty Name

#record some basic system information
$Serial = Get-WmiObject win32_SystemEnclosure | Select-Object serialnumber
$make = Get-CimInstance -ClassName Win32_ComputerSystem | Select-Object Manufacturer
$model  = Get-CimInstance -ClassName Win32_ComputerSystem | Select-Object Model
$OS = Get-osdisplayname
$osbuild = Get-osbuild
$osarchitecture = Get-osarchitecture
$uacstatus = Get-UACStatus
#Formatting for the html report
#############################################################################################################
$css = @"
<style>
h1, h5, th { text-align: center; font-family: Segoe UI; }
table { margin: auto; font-family: Segoe UI; box-shadow: 10px 10px 5px #888; border: thin ridge grey; }
th { background: #0046c3; color: #fff; max-width: 400px; padding: 5px 10px; }
td { font-size: 11px; padding: 5px 20px; color: #000; }
tr { background: #b8d1f3; }
tr:nth-child(even) { background: #dae5f4; }
tr:nth-child(odd) { background: #b8d1f3; }
</style>
"@
##############################################################################################################
#example for export
#Import-CSV "C:\temp\test.csv" | ConvertTo-Html -Head $css -Body "<h1>Baseline Report</h1>`n<h5>Generated on $(Get-Date)</h5>" | Out-File "C:\temp\test.html"

Detect-Laptop

$desktopservices=@(  
    #these are the service display names   
    "Advanced Monitoring Agent"
    "Carbon Black Sensor"
    "Cisco AMP for Endpoints Connector 7.2.11"
    "Cisco AMP Orbital"
    "Cisco AnyConnect Secure Mobility Agent"
    "Cisco AnyConnect Secure Mobility ISE Posture Agent"
    "Cisco Security Connector Monitoring Service 7.2.11"
)

$desktopsoftware=@(  
    "Advanced Monitoring Agent"
    "CarbonBlack Sensor"
    "Cisco AMP for Endpoints Connector"
    "Cisco AMP Orbital"
    "Cisco Anyconnect Secure mobility Client"
    "Cisco Anyconnect ise posture module"
    "Cisco Anyconnect Diagnostics and Reporting tool"
    "Local Administrator Password Solution"
    "Phish Alert"
    "ZixSelect® for Outlook"
)

$serverservices=@(  
    #these are the service display names   
    "Advanced Monitoring Agent"
    "Carbon Black Sensor"
    "Cisco AMP for Endpoints Connector 7.2.11"
    "Cisco AMP Orbital"
    "Tenable Nessus Agent"
    "SplunkForwarder Service"
)

$serversoftware=@(  
    "Advanced Monitoring Agent"
    "CarbonBlack Sensor"
    "Cisco AMP for Endpoints Connector"
    "Cisco AMP Orbital"
    "Local Administrator Password Solution"
    "Nessus Agent (x64)"
    "UniversalForwarder"
)


#begin the os checks for services and software installations / bitlocker
if ($OS -like "*Windows 10*") {
    #build the hash table for reporting

    #beginning desktop application and service testing
    Foreach ($app in $desktopsoftware) {    
       #Begin the check to see if the software is already installed.
       $software = $app
       #Check to see if the application is installed by referencing the "displayname" property on the msi
       $result = Get-InstalledApps | Where-Object {$_.DisplayName -like $software}    
       if ($result){
           #write-host $result + "App is installed"
       }
       else {
           write-host "$result is not installed"
       }
   }
   #begin desktop service checks to make sure the services are running.
   foreach ($service in $desktopservices) {    
       #Write-Output $service
       $status = get-service -DisplayName $service | select-object -ExpandProperty Status
       if ($status -eq "Running"){
           Write-host "Service is running"
       }
       Else {
           Write-Warning $service + "Service is not running"
       }
   }
   If(Detect-Laptop) { 
    #check the bitlocker encryption status and if encrypted record the key to make sure the drive is encrypted
    $Bitlockerstatus = Get-BitLockerVolume | Select-Object -ExpandProperty Volumestatus 
        if ($Bitlockerstatus -eq "FullyEncrypted"){
            Write-host "Drive is encrypted"
            #record the bitlocker key to a variable
            $BitlockerVolume = Get-BitLockerVolume 
            $BitlockerVolume |
            ForEach-Object {
                $MountPoint = $_.MountPoint
                $RecoveryKey = [string]($_.KeyProtector).RecoveryPassword
                if ($RecoveryKey.Length -gt 5) {
                    Write-Output ("The drive $MountPoint has a BitLocker recovery key $RecoveryKey.")
                }
            }
        }
        Else {
                    Write-Warning "Drive is not encrypted"
        }
    }
    else { 
        Write-host "it’s not a laptop"
    }
}
elseif ($OS -like "*Windows 8.1*") {
    #beginning desktop application and service testing
    Foreach ($app in $desktopsoftware) {    
       #Begin the check to see if the software is already installed.
       $software = $app
       #Check to see if the application is installed by referencing the "displayname" property on the msi
       $result = Get-InstalledApps | Where-Object {$_.DisplayName -like $software}    
       if ($result){
           write-host $result + "App is installed"
       }
       else {
           write-host "$software is not installed"
       }
   }
   foreach ($service in $desktopservices) {    
       Write-Output $service
       #Begin the check to see if the software is already installed.
       $status = get-service -DisplayName $service | select-object -ExpandProperty Status
       if ($status -eq "Running"){
           Write-host "Service is running"
       }
       Else {
           Write-Warning $service + "Service is not running"
       }
   }
   If(Detect-Laptop) { 
        #This section requires uac admin elevation.
        Write-host “it’s a laptop” 
        #check the bitlocker encryption status and if encrypted record the key to make sure the drive is encrypted
        $Bitlockerstatus = Get-BitLockerVolume | Select-Object -ExpandProperty Volumestatus 
        if ($Bitlockerstatus -eq "FullyEncrypted"){
            Write-host "Drive is encrypted"
            #record the bitlocker key to a variable
            $BitlockerVolume = Get-BitLockerVolume 
            $BitlockerVolume |
            ForEach-Object {
                $MountPoint = $_.MountPoint
                $RecoveryKey = [string]($_.KeyProtector).RecoveryPassword
                if ($RecoveryKey.Length -gt 5) {
                    Write-Output ("The drive $MountPoint has a BitLocker recovery key $RecoveryKey.")
                }
            }
        }
        Else {
            Write-Warning "Drive is not encrypted"
        }   
    }
    else { 
        Write-host "it’s not a laptop and doesn't need encryption"
    }
}
elseif ($OS -like "*Server*"){
    #beginning server application and service testing
    Foreach ($app in $serversoftware) {    
       #Check to see if the application is installed by referencing the "displayname" property on the msi
       $result = Get-InstalledApps | Where-Object {$_.DisplayName -like $software}    
       if ($result){
           write-host $result + "App is installed"
       }
       else {
           write-host "$software is not installed"
       }
   }
   #begin server service checks
   Foreach ($service in $serverservices) {    
       #Begin the check to see if the software is already installed.
       $status = get-service -DisplayName $service | select-object -ExpandProperty Status
       if ($status -eq "Running"){
           Write-host "Service is running"
       }
       Else {
           Write-Warning $service + "Service is not running"
       }
    }     
}

