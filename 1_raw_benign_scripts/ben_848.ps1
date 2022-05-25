<#.SYNOPSIS
   Configures the Windows Firewall across all machine in the environment.

.DESCRIPTION
    Configures the Windows Firewall across all tiers (Portal,
    Services, SharePoint, SQL, and Active Directory) or just a single tier.  

    This script works across different environments (i.e. DevInt, UAT, QA).
	This script requires Windows Server Server 2008 or Windows Server 2012.

.PARAMETER EnvironmentName
    The name of the environment configuration in the Environments.xml file.

.PARAMETER GlobalConfigurationFileName
    the environment xml file that describes the environment configuration information.

.PARAMETER DeploymentTier
    Determines which tier to deploy to.  The default is all Azure tiers (AllAzure).
    Choices are staging, AD, Portal, Services, SharePoint, SQL, AllAzure, OnPrem
	
#>
param(
[Parameter(Mandatory=$false)][string]$EnvironmentName,
[Parameter(Mandatory=$false)][string]$GlobalConfigurationFileName,
[Parameter(Mandatory=$false)]$DeploymentTier="AllAzure"
)

Set-StrictMode -Version 2

#Region External_Functions
    
    . "$PSSCriptRoot\Common\ConfigurationScriptFunctions.ps1"

#EndRegion

#region
function ConfigureADServers([Parameter(Mandatory=$true)]$basePath)
{
    Set-ExecutionPolicy "unrestricted" -Force

	. $basePath\Install.Net3.5N4.5NPowerShell3.ps1
	. $basePath\EnableRemoting.ps1
	. $basePath\CreateFolders.ps1
	. $basePath\UpdateServerSettings.ps1
	. $basePath\DownloadSoftwareFromAzureBlobStorage.ps1
	. $basePath\UnzipSoftware.ps1
	. $basePath\OpenFirewall.ps1
	. $basePath\NetworkDTC.ps1
	. $basePath\CreateSQLAliases.ps1
}

function ConfigureADServers([Parameter(Mandatory=$true)]$basePath)
{
    Set-ExecutionPolicy "unrestricted" -Force

	. $basePath\Install.Net3.5N4.5NPowerShell3.ps1
	. $basePath\EnableRemoting.ps1
	. $basePath\CreateFolders.ps1
	. $basePath\UpdateServerSettings.ps1
	. $basePath\DownloadSoftwareFromAzureBlobStorage.ps1
	. $basePath\UnzipSoftware.ps1
	. $basePath\OpenFirewall.ps1
	. $basePath\NetworkDTC.ps1
	. $basePath\CreateSQLAliases.ps1
}

function ConfigurePortalServers([Parameter(Mandatory=$true)]$basePath)
{
    Set-ExecutionPolicy "unrestricted" -Force

	. $basePath\Install.Net3.5N4.5NPowerShell3.ps1
	. $basePath\EnableRemoting.ps1
	. $basePath\CreateFolders.ps1
	. $basePath\UpdateServerSettings.ps1
	. $basePath\DownloadSoftwareFromAzureBlobStorage.ps1
	. $basePath\UnzipSoftware.ps1
	. $basePath\Addusers2requiredLocalGroups.ps1
	. $basePath\ImportCertificates.ps1
	. $basePath\AddWindowsFeatures.ps1
	. $basePath\AspNetStateService.ps1
	. $basePath\CreateWebSites.ps1
	. $basePath\OpenFirewall.ps1
	. $basePath\NetworkDTC.ps1
	. $basePath\CreateSQLAliases.ps1
	. $basePath\SetupQueueDistributor.ps1
}

function ConfigureMiddleTierServers([Parameter(Mandatory=$true)]$basePath)
{
    Set-ExecutionPolicy "unrestricted" -Force

	. $basePath\Install.Net3.5N4.5NPowerShell3.ps1
	. $basePath\EnableRemoting.ps1
	. $basePath\CreateFolders.ps1
	. $basePath\UpdateServerSettings.ps1
	. $basePath\DownloadSoftwareFromAzureBlobStorage.ps1
	. $basePath\UnzipSoftware.ps1
	. $basePath\Addusers2requiredLocalGroups.ps1
	. $basePath\ImportCertificates.ps1
	. $basePath\AddWindowsFeatures.ps1
	. $basePath\AspNetStateService.ps1
	. $basePath\CreateWebSites.ps1
	. $basePath\OpenFirewall.ps1
	. $basePath\NetworkDTC.ps1
	. $basePath\CreateSQLAliases.ps1
	. $basePath\SetupQueueDistributor.ps1
}

function ConfigureCombinedPortalAndMiddleTierServers([Parameter(Mandatory=$true)]$basePath)
{
    Set-ExecutionPolicy "unrestricted" -Force

	. $basePath\Install.Net3.5N4.5NPowerShell3.ps1
	. $basePath\EnableRemoting.ps1
	. $basePath\CreateFolders.ps1 -ServerRole "Services"
	. $basePath\UpdateServerSettings.ps1
	. $basePath\DownloadSoftwareFromAzureBlobStorage.ps1 -ServerRole "Services"
	. $basePath\UnzipSoftware.ps1 -ServerRole "Services"
	. $basePath\Addusers2requiredLocalGroups.ps1
	. $basePath\ImportCertificates.ps1 -ServerRole "Services"
	. $basePath\AddWindowsFeatures.ps1 -ServerRole "Services"
	. $basePath\AspNetStateService.ps1 -ServerRole "Portal"
	. $basePath\CreateWebSites.ps1 -ServerRole "Portal"
	. $basePath\CreateWebSites.ps1 -ServerRole "Services"
	. $basePath\OpenFirewall.ps1
	. $basePath\NetworkDTC.ps1
	. $basePath\CreateSQLAliases.ps1
	. $basePath\SetupQueueDistributor.ps1
}

function ConfigureSharePointServers([Parameter(Mandatory=$true)]$basePath)
{
    Set-ExecutionPolicy "unrestricted" -Force

	. $basePath\Install.Net3.5N4.5NPowerShell3.ps1
	. $basePath\EnableRemoting.ps1
	. $basePath\CreateFolders.ps1
	. $basePath\UpdateServerSettings.ps1
	. $basePath\DownloadSoftwareFromAzureBlobStorage.ps1
	. $basePath\UnzipSoftware.ps1
	. $basePath\Addusers2requiredLocalGroups.ps1
	. $basePath\ImportCertificates.ps1
	. $basePath\OpenFirewall.ps1
	. $basePath\CreateSQLAliases.ps1
}

function ConfigureOnPremServer([Parameter(Mandatory=$true)]$basePath)
{
    Set-ExecutionPolicy "unrestricted" -Force

	. $basePath\Install.Net3.5N4.5NPowerShell3.ps1
	. $basePath\EnableRemoting.ps1
	. $basePath\CreateFolders.ps1
	. $basePath\UpdateServerSettings.ps1
	. $basePath\DownloadSoftwareFromAzureBlobStorage.ps1
	. $basePath\UnzipSoftware.ps1
	. $basePath\Addusers2requiredLocalGroups.ps1
	. $basePath\ImportCertificates.ps1
	. $basePath\AddWindowsFeatures.ps1
	. $basePath\AspNetStateService.ps1
	. $basePath\CreateWebSites.ps1
	. $basePath\OpenFirewall.ps1
	. $basePath\CreateSQLAliases.ps1
	. $basePath\SetupQueueDistributor.ps1

}

function ConfigureSqlServer([Parameter(Mandatory=$true)]$basePath)
{
    Set-ExecutionPolicy "unrestricted" -Force

	. $basePath\Install.Net3.5N4.5NPowerShell3.ps1
	. $basePath\EnableRemoting.ps1
	. $basePath\CreateFolders.ps1
	. $basePath\UpdateServerSettings.ps1
	. $basePath\DownloadSoftwareFromAzureBlobStorage.ps1
	. $basePath\UnzipSoftware.ps1
	. $basePath\OpenFirewall.ps1
	. $basePath\NetworkDTC.ps1
	. $basePath\CreateSQLAliases.ps1

}
#endregion

function Main(
[Parameter(Mandatory=$false)][string]$EnvironmentName,
[Parameter(Mandatory=$false)][string]$GlobalConfigurationFileName,
[Parameter(Mandatory=$false)]$DeploymentTier="AllAzure"
)
{

    $EnvironmentConfigurationFileName=$null
    #$ServerName = $env:COMPUTERNAME
    $ServerName = "UAT8AD1"

    $GlobalConfigurationFileName = Ensure-EnvironmentFile $GlobalConfigurationFileName
    $GlobalConfiguration = Get-GlobalConfiguration -InputFile $GlobalConfigurationFileName

    $EnvironmentName = Ensure-EnvironmentName -EnvironmentName $EnvironmentName -ServerName $ServerName -EnvironmentConfigurationFiles $GlobalConfiguration.EnvironmentConfigurationFiles

    $EnvironmentConfigurationFileName = Ensure-EnvironmentConfigurationFileName $EnvironmentConfigurationFileName $EnvironmentName $ServerName $GlobalConfiguration.EnvironmentConfigurationFiles
    $EnvironmentConfiguration = Get-EnvironmentConfiguration -EnvironmentConfigurationFileName $EnvironmentConfigurationFileName -EnvironmentName $EnvironmentName 

    $DeploymentTier = Ensure-DeploymentTier -DeploymentTier $DeploymentTier -ServerName $ServerName -EnvironmentConfiguration $EnvironmentConfiguration

	$RemotePowerShellUser = $EnvironmentConfiguration.RemotePowerShellUser # User name used for remote PowerShell Sessions on each server
	$RemotePowerShellPwd = $EnvironmentConfiguration.RemotePowerShellPwd                               # Password for remote PowerShell Sessions on each server

	  
	#Global Configuration Information from Environment.xml
	$DeployLogsDir = $GlobalConfiguration.DeployLogsDir                       # Powershell Transcripts from each deploy live here
	
	# Servers used in Remote PowerShell Sessions
	#$ActiveDirectoryServers = $EnvironmentConfiguration.ActiveDirectoryServers
	$PortalServers = $EnvironmentConfiguration.PortalServers
	$MiddleTierServers = $EnvironmentConfiguration.MiddleTierServers
	$UseUnifiedPortalMiddleTier = $EnvironmentConfiguration.UseUnifiedPortalMiddleTier 
	$SharePointServer = $EnvironmentConfiguration.SharePointServer
    $SharePointWFEs = $EnvironmentConfiguration.SharePointWFEs
    $SharePointAPPs = $EnvironmentConfiguration.SharePointAPPs
    $ActiveDirectoryServers = $EnvironmentConfiguration.ActiveDirectoryServers


	$AllServers = @()
	$AllServers += $PortalServers
    
    if ($UseUnifiedPortalMiddleTier -eq $false)
    {
	    $AllServers += $MiddleTierServers
    }

	#$AllServers += $SharePointServer
    if (($SharePointWFEs.Count -gt 0) -and ($SharePointWFEs[0].Length -gt 0))
    {
        $AllServers += $SharePointWFEs
    }

    $AllServers += $SharePointAPPs
    $AllServers += $ActiveDirectoryServers

    $SQLServers = @()
	foreach ($SQLServer in $EnvironmentConfiguration.SQLServers)
	{
		$SQLServers += $SQLServer.Name
	}

	$AllServers += $SQLServers
	
	#Build transcript file name.
	$DateStamp = get-date -uformat "%Y-%m-%d@%H-%M-%S"
	[String] $TranscriptFile = $DeployLogsDir + "\Deploy_" + $EnvironmentConfiguration.Name + "_" + $dateStamp +".rtf"

    #endregion Configuration_Information

   
    # Cleanup any open remote PowerShell sessions and open transcript if the last script ended with a ctrl-c.
    Remove-CimSession * -EA 0
    try{Stop-Transcript}catch{} #There's no easy way to see if the transcript is running.

    if (!($Host.Name.Contains("ISE")))
    {
        Start-Transcript -path $TranscriptFile -Force
    }
    else
    {
        Write-Warning "The PowerShell ISE doesn't support transcripts."
    }

    Write-Host ("Starting Deployment: " + ([System.DateTime]::Now).ToString())
    Write-Host "ServerName:  $env:computername"

	Write-Host "Preparing to open the firewall."
	
	# Setup Remote PowerShell Sessions 
	# Creates a persistent connection (PSSession) to the specified computer. 
	#If you enter multiple computer names, New-PSSession creates multiple PSSessions, one for each computer. 
	#The default is the local computer.
	#Type the NetBIOS name, an IP address, or a fully qualified domain name of one or more remote computers. 
	#To specify the local computer, type the computer name, "localhost", or a dot (.). 
	#When the computer is in a different domain than the user, the fully qualified domain name is 
	$secpasswd = ConvertTo-SecureString $RemotePowerShellPwd -AsPlainText -Force
	$cred  = New-Object System.Management.Automation.PSCredential ($RemotePowerShellUser, $secpasswd)

    $ADSsession = New-PSSession -Name "ServicesInstall"  -ComputerName $ActiveDirectoryServers
	$PortalSession   = New-PSSession -Name "PortalInstall"    -ComputerName $PortalServers
	$ServiceSsession = New-PSSession -Name "ServicesInstall"  -ComputerName $MiddleTierServers
	$SPServerSession    = New-PSSession -Name "SharPointInstall" -ComputerName $SharePointServer -Authentication CredSSP -Credential $cred
    $SPWFEsSession    = New-PSSession -Name "SharPointWFEInstall" -ComputerName $SharePointWFEs -Authentication CredSSP -Credential $cred
    $SPAPPsSession    = New-PSSession -Name "SharPointAPPInstall" -ComputerName $SharePointAPPs -Authentication CredSSP -Credential $cred
    $SqlSsession = New-PSSession -Name "SqlInstall"  -ComputerName $SQLServers
	$AllServersSsession = New-PSSession -Name "AllServersInstall"  -ComputerName $SQLServers

	$basePath = "C:\Apps\Dist"
	
    if (($DeploymentTier -eq "AllAzure") -or ($DeploymentTier -eq "AD"))
    {
        Invoke-Command -Session $ADSsession -ScriptBlock $function:ConfigureADServers -ArgumentList $basePath -ErrorVariable errorMsg
    }

    if ((($DeploymentTier -eq "AllAzure") -or ($DeploymentTier -eq "Portal")) -and ($UseUnifiedPortalMiddleTier -eq $false))
    {
		Invoke-Command -Session $PortalSession -ScriptBlock $function:ConfigurePortalServers -ArgumentList $basePath -ErrorVariable errorMsg
    }

    if ((($DeploymentTier -eq "AllAzure") -or ($DeploymentTier -eq "Services")) -and ($UseUnifiedPortalMiddleTier -eq $false))
    {
		Invoke-Command -Session $ServicesSession -ScriptBlock $function:ConfigureMiddleTierServers -ArgumentList $basePath -ErrorVariable errorMsg
    }

    if ((($DeploymentTier -eq "AllAzure") -or ($DeploymentTier -eq "Portal") -or ($DeploymentTier -eq "Services")) -and ($UseUnifiedPortalMiddleTier -eq $true))
    {
		Invoke-Command -Session $ServicesSession -ScriptBlock $function:ConfigureMiddleTierServers -ArgumentList $basePath -ErrorVariable errorMsg
    }

    if (($DeploymentTier -eq "AllAzure") -or ($DeploymentTier -eq "SharePoint"))
    {	
		Invoke-Command -Session $SPServerSession -ScriptBlock $function:ConfigureSharePointServers -ArgumentList $basePath -ErrorVariable errorMsg
        Invoke-Command -Session $SPWFEsSession -ScriptBlock $function:ConfigureSharePointServers -ArgumentList $basePath -ErrorVariable errorMsg
        Invoke-Command -Session $SPAPPsSession -ScriptBlock $function:ConfigureSharePointServers -ArgumentList $basePath -ErrorVariable errorMsg
    }

	if (($DeploymentTier -eq "AllAzure") -or ($DeploymentTier -eq "SQL"))
    {
		 Invoke-Command -Session $SqlSession -ScriptBlock $function:ConfigureSqlServer -ArgumentList $basePath -ErrorVariable errorMsg
    }
	
    if ($DeploymentTier -ne "OnPrem")
    {
        #Nothing to do.
	}
	
	#Close all open remote PowerShell sessions before ending.
	Remove-PSSession *

    if (!($Host.Name.Contains("ISE")))
    {
        Stop-Transcript
    }
}

Main -DeploymentTier $DeploymentTier -EnvironmentName $EnvironmentName -GlobalConfigurationFileName $GlobalConfigurationFileName