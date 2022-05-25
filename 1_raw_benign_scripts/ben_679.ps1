# New GUID: [guid]::NewGuid()
$guid 				= [guid]"xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"		# This GUID ** MUST BE ** unique. If you doubt, make a new one.
$brokerName 		= "your.broker.name"
$brokerSystemName 	= $brokerName
$brokerDLL 			= "$($brokerName).dll"								# Make sure that matched the name of your file
$displayName 		= $brokerName -replace '\.',' '						# you can be creative here if you prefer...
$brokerDescription 	= "some desc"

Function GetK2InstallPath([string]$machine = $env:computername) {
<#
.SYNOPSIS
Get the K2 Installation Path.
.DESCRIPTION
Retrieve the K2 base install path. A remote machine can be used to get it from a remote server.
.PARAMETER machine 
The source file(s)
.EXAMPLE
GetK2InstallPath tisapwfdev.detesting.local
returns C:\Program Files (x86)\K2 blackpearl\
.NOTES
Created: 01/27/2014 by Ruben d'Arco
#>
    $registryKeyLocation = "SOFTWARE\SourceCode\BlackPearl\blackpearl Core\"
    $registryKeyName = "InstallDir"

	Write-Debug "Getting K2 install path from $machine "
    
    $reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine, $machine)
    $regKey= $reg.OpenSubKey($registryKeyLocation)
    $installDir = $regKey.GetValue($registryKeyName)
    return $installDir
}

Function StartK2Service([string]$server) {
    Write-Host -ForegroundColor DarkMagenta "Starting K2 blackpearl service on $server"
    Get-Service -DisplayName 'K2 blackpearl Server' -ComputerName $server | where-object {$_.Status -eq "Stopped"} | Start-Service
}

Function StopK2Service([string]$server) {
    Write-Host -ForegroundColor DarkMagenta "Stopping K2 blackpearl service on $server"
    Get-Service -DisplayName 'K2 blackpearl Server' -ComputerName $server | where-object {$_.Status -eq "Running"} | Stop-Service
}

Function GetK2ConnectionString([string]$k2Server = "localhost", [int]$port = 5555, [string]$userid, [string]$password, [string]$windowsdomain, [bool]$integrated = $true, [bool]$isPrimary=$true)
{
    Write-Debug "Creating connectionstring for machine '$k2Server' and port '$port'";
	
	Add-Type -AssemblyName ('SourceCode.HostClientAPI, Version=4.0.0.0, Culture=neutral, PublicKeyToken=16a2c5aaaa1b130d')
    $connString = New-Object -TypeName "SourceCode.Hosting.Client.BaseAPI.SCConnectionStringBuilder";
    $connString.Integrated = $integrated;
    $connString.IsPrimaryLogin = $isPrimary;
    $connString.Host = $k2Server;
    $connString.Port = $port;
	$connString.UserID = $userid;
	$connString.Password = $password;
	$connString.WindowsDomain = $windowsdomain;

    return $connString.ConnectionString; 
}

Function RegisterServiceType([string]$k2ConnectionString, [string]$k2Server, [string]$ServiceTypeDLL, [guid]$guid, 
	[string]$systemName, [string]$displayName, [string]$description = "")
{
    # Get Paths for local environment and for the remote machine, we might run this installer from a simple windows 7 host, while we deploy to a server that has a different drive...
    $k2Path = GetK2InstallPath
    $remK2Path = GetK2InstallPath -machine $k2Server
    $smoManServiceAssembly = Join-Path $k2Path "bin\SourceCode.SmartObjects.Services.Management.dll"
    $serviceBrokerAssembly = Join-Path $remK2Path "ServiceBroker\$($ServiceTypeDLL)"
	
    Write-Debug "Adding/Updating ServiceType $serviceBrokerAssembly with guid $guid using $k2ConnectionString"
    
    Add-Type -Path $smoManServiceAssembly # we load this assembly locally, but we connect to the remote host.
    $smoManService = New-Object SourceCode.SmartObjects.Services.Management.ServiceManagementServer

    #Create connection and capture output (methods return a bool)
    $tmpOut = $smoManService.CreateConnection()
    $tmpOut = $smoManService.Connection.Open($k2ConnectionString);
    Write-Debug "Connected to K2 host server"

    # Check if we need to update or register a new one...
    if ([string]::IsNullOrEmpty($smoManService.GetServiceType($guid)) ) {
        Write-Debug "Registering new service type..."
        $tmpOut = $smoManService.RegisterServiceType($guid, $systemName, $displayName, $description, $serviceBrokerAssembly, $systemName);
        write-debug "Registered new service type..."
    } else {
        Write-Debug "Updating service type..."
        $tmpOut = $smoManService.UpdateServiceType($guid, $systemName, $displayName, $description, $serviceBrokerAssembly, $systemName);
        Write-Debug "Updated service type..."
    }
    $smoManService.Connection.Close();
    write-host "Deployed service-type"
}

$DebugPreference = "Continue" 
$targetPath = "$(GetK2InstallPath)ServiceBroker"
$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition

Write-Host Stopping Service
StopK2Service -server localhost
sleep -Seconds 1
 
Write-Host Installing files
Copy-Item $scriptPath\* -Include *.dll,*.md -Destination "$targetPath"

Write-Host Starting Service
StartK2Service -server localhost
sleep -Seconds 2

$k2constring = GetK2ConnectionString 
Write-Host K2 Connection String:
Write-Host $k2constring
Write-Host  not executing RegisterServiceType, remarked out line
# RegisterServiceType -k2ConnectionString $k2constring -ServiceTypeDLL $brokerDLL -guid $guid -systemName $brokerSystemName -displayName $displayName -description $brokerDescription