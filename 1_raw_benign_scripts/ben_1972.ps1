#Requires -Version 4.0

[CmdletBinding()]

Param(
    [switch]$OnlineInstall = $false
)

<#	
	.NOTES
	===========================================================================
	 Created on:   	02/24/2016 15:27
	 Created by:   	Colin Squier <hexalon@gmail.com>
	 Filename:     	Install-WMF5.ps1
     Updated:       03/01/16 10:05
	===========================================================================
	.DESCRIPTION
		Automates installation of Windows Management Framework 5
#>

<#
	.SYNOPSIS
		Returns the path of the executing script's directory.
	
	.DESCRIPTION
		Sapien's implementation of the variable $HostInvocation
		causes a conflict the with the system's variable.
	
	.EXAMPLE
		PS C:\> Get-ScriptDirectory
	
	.NOTES
		Work around for handling Sapien's custom host environment.
#>
function Get-ScriptDirectory
{
	if ($HostInvocation -ne $null)
	{
		Split-Path -Path $HostInvocation.MyCommand.path
	}
	else
	{
		Split-Path -Path $script:MyInvocation.MyCommand.Path
	}
}

<#
	.SYNOPSIS
		Detects .NET Framework versions installed.
	
	.DESCRIPTION
		Uses the registry to detect whcih .NET Framework versions
		are currently installed. This method is the only supported
		method by Microsoft.
	
	.EXAMPLE
		PS C:\> Get-Framework-Versions
	
	.NOTES
		Has not been tested against server OSes.
#>
function Get-Framework-Versions()
{
	$installedFrameworks = @()
	if (Test-Key "HKLM:\Software\Microsoft\.NETFramework\Policy\v1.0" "3705") { $installedFrameworks += "1.0" }
	if (Test-Key "HKLM:\Software\Microsoft\NET Framework Setup\NDP\v1.1.4322" "Install") { $installedFrameworks += "1.1" }
	if (Test-Key "HKLM:\Software\Microsoft\NET Framework Setup\NDP\v2.0.50727" "Install") { $installedFrameworks += "2.0" }
	if (Test-Key "HKLM:\Software\Microsoft\NET Framework Setup\NDP\v3.0\Setup" "InstallSuccess") { $installedFrameworks += "3.0" }
	if (Test-Key "HKLM:\Software\Microsoft\NET Framework Setup\NDP\v3.5" "Install") { $installedFrameworks += "3.5" }
	if (Test-Key "HKLM:\Software\Microsoft\NET Framework Setup\NDP\v4\Client" "Install")
	{
		$installedFrameworks += "4.0c"
		
		if ((Get-ItemProperty -Path "HKLM:\Software\Microsoft\NET Framework Setup\NDP\v4\Client").Version -like "4.5*")
		{
			$installedFrameworks += "4.5c"
		}
		if ((Get-ItemProperty -Path "HKLM:\Software\Microsoft\NET Framework Setup\NDP\v4\Client").Version -like "4.6*")
		{
			$installedFrameworks += "4.6c"
		}
	}
	if (Test-Key "HKLM:\Software\Microsoft\NET Framework Setup\NDP\v4\Full" "Install")
	{
		$installedFrameworks += "4.0"
		
		if ((Get-ItemProperty -Path "HKLM:\Software\Microsoft\NET Framework Setup\NDP\v4\Full").Version -like "4.5*" -or (Get-ItemProperty -Path "HKLM:\Software\Microsoft\NET Framework Setup\NDP\v4\Full").Version -like "4.6*")
		{
			[int32]$intRelease = (Get-ItemProperty -Path "HKLM:\Software\Microsoft\NET Framework Setup\NDP\v4\Full").Release
			
			# Based on Microsoft MSDN Article
			# Link: https://msdn.microsoft.com/en-us/library/hh925568(v=vs.110).aspx
			
			Switch ($intRelease)
			{
				"378389" { $installedFrameworks += "4.5" }
				"378675" { $installedFrameworks += "4.5.1" } #Windows 8.1/2012 R2
				"378758" { $installedFrameworks += "4.5.1" } #Windows Vista/7/8
				"379893" { $installedFrameworks += "4.5.2" }
				"393297" { $installedFrameworks += "4.6" } #All other OSes
                "393295" { $installedFrameworks += "4.6" } #Windows 10
                "394271" { $installedFrameworks += "4.6.1" } #All other OSes
                "394254" { $installedFrameworks += "4.6.1" } #Windows 10
			}
		}
	}
	return $installedFrameworks
}

<#
	.SYNOPSIS
		Function to test for the existence of registry keys.
	
	.DESCRIPTION
		Function to test for the existence of registry keys.
	
	.PARAMETER path
		The path to be tested.
	
	.PARAMETER key
		The key to be tested.
	
	.EXAMPLE
		PS C:\> Test-Key -path 'Value1' -key 'Value2'
	
	.NOTES
		Has not been tested against NULL value keys.
#>
function Test-Key([string]$path, [string]$key)
{
	if (!(Test-Path -Path $path)) { return $false }
	if ((Get-ItemProperty -Path $path).$key -eq $null) { return $false }
	return $true
}

if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
[Security.Principal.WindowsBuiltInRole] "Administrator"))
{
	Write-Warning -Message "You do not have Administrator rights to run this script!`nPlease re-run this script as an Administrator!"
	Break
}

$Option = New-CimSessionOption -Protocol Dcom
$Session = New-CimSession -SessionOption $Option -ComputerName $env:COMPUTERNAME
$OS = (Get-CimInstance -ClassName Win32_OperatingSystem -CimSession $Session)
$OSVersion = $OS.Version
$WinEdition = $OS.Caption
$scriptDirectory = Get-ScriptDirectory
$Source = (Split-Path -Path $scriptDirectory -Parent)
$PackagePath = (Join-Path -Path $Source -ChildPath "ComputerSetup\WMF5")

$Product = "Windows Management Framework 5"
$MinimumFxVersion = "4.5"

$Version = $Host.Version.Major

if ($Version -ge 5)
{
	Write-Verbose -Message "$Product or later already installed."
	break
}

switch ($OSVersion)
{
    "6.1.7601"
    {
        #Win 7
        $MinimumFxVersion = "4.5"

        $DotNet = Get-Framework-Versions
	
        #Select last element in array
        $LastFx = $DotNet[-1]
	
        if (!($LastFx -eq $null))
        {
	        Write-Verbose -Message ".NET Framework version installed is: $LastFx"
        }
    
        if ($LastFx -ge $MinimumFxVersion)
        {
            $HotFix = (Get-HotFix | Where-Object { $_.HotfixID -eq 'KB3134760' })
	
	        if (!($HotFix -eq $null))
	        {
		        Write-Verbose -Message "$Product or later already installed."
	        }
	
	        if ($($OS.OSArchitecture) -eq '32-bit')
	        {
		        if ($HotFix -eq $null)
		        {
                    if($OnlineInstall)
                    {
                        try
                        {
                            $W7File32 = "Win7-KB3134760-x86.msu"
                            $W7FullPath32 = Join-Path -Path $PackagePath -ChildPath $W7File32
                            $Downloader = Invoke-WebRequest -Uri 'http://go.microsoft.com/fwlink/?LinkID=717962' -OutFile $W7FullPath32
                            Write-Verbose -Message "Downloading $Product for $WinEdition. Destination: $W7FullPath32"
                            Unblock-File -Path $W7FullPath32
                        }
                        catch
                        {
                            throw $_
                        }
	                }
                    else
                    {
                        $W7File32 = "Win7-KB3134760-x86.msu"
                        $W7FullPath32 = Join-Path -Path $PackagePath -ChildPath $W7File32
                    }
			        Write-Verbose -Message "Installing $Product"
			        $UpdateFile = Start-Process -FilePath "wusa.exe" -ArgumentList "`"$W7FullPath32`" /quiet /norestart" -Wait -Passthru
			        $ExitCode = $UpdateFile.ExitCode
		        }
	        }
	        else
	        {
		        if ($HotFix -eq $null)
		        {
                    if($OnlineInstall)
                    {
                        try
                        {
                            $W7File64 = "Win7AndW2K8R2-KB3134760-x64.msu"
                            $W7FullPath64 = Join-Path -Path $PackagePath -ChildPath $W7File64
                            Write-Verbose -Message "Downloading $Product for $WinEdition. Destination: $W7FullPath64"
                            $Downloader = Invoke-WebRequest -Uri 'http://go.microsoft.com/fwlink/?LinkId=717504' -OutFile $W7FullPath64
                            Unblock-File -Path $W7FullPath64
                        }
                        catch
                        {
                            throw $_
                        }
	                }
                    else
                    {
                        $W7File64 = "Win7AndW2K8R2-KB3134760-x64.msu"
                        $W7FullPath64 = Join-Path -Path $PackagePath -ChildPath $W7File64
                    }
			        Write-Verbose -Message "Installing $Product"
			        $UpdateFile = Start-Process -FilePath "wusa.exe" -ArgumentList "`"$W7FullPath64`" /quiet /norestart" -Wait -Passthru
			        $ExitCode = $UpdateFile.ExitCode
		        }
	        }
        }
    }
    "6.2.9200"
    {
        #Win 8
        $HotFix = (Get-HotFix | Where-Object { $_.HotfixID -eq 'KB3134759' })

        if (!($HotFix -eq $null))
        {
            Write-Verbose -Message "$Product or later already installed."
        }

        if ($($OS.OSArchitecture) -eq '64-bit')
        {
            if ($HotFix -eq $null)
            {
                if($OnlineInstall)
                {
                    try
                    {
                        $W8File64 = "W2K12-KB3134759-x64.msu"
                        $W8FullPath64 = Join-Path -Path $PackagePath -ChildPath $W8File64
                        Write-Verbose -Message "Downloading $Product for $WinEdition. Destination: $W8FullPath64"
                        $Downloader = Invoke-WebRequest -Uri 'http://go.microsoft.com/fwlink/?LinkId=717506' -OutFile $W8FullPath64
                        Unblock-File -Path "$W8FullPath64"
                    }
                    catch
                    {
                        throw $_
                    }
                }
                else
                {
                    $W8File64 = "W2K12-KB3134759-x64.msu"
                    $W8FullPath64 = Join-Path -Path $PackagePath -ChildPath $W8File64
                }
                Write-Verbose -Message "Installing $Product"
                $UpdateFile = Start-Process -FilePath "wusa.exe" -ArgumentList "`"$W8FullPath64`" /quiet /norestart" -Wait -Passthru
                $ExitCode = $UpdateFile.ExitCode
            }
        }
    }
    "6.3.9600"
    {
        #Win 8.1
        $HotFix = (Get-HotFix | Where-Object { $_.HotfixID -eq 'KB3134758' })

        if (!($HotFix -eq $null))
        {
	        Write-Verbose -Message "$Product or later already installed."
        }

        if ($($OS.OSArchitecture) -eq '32-bit')
        {
	        if ($HotFix -eq $null)
	        {
	            if($OnlineInstall)
	            {
		            try
                    {
                        $W81File32 = "Win8.1-KB3134758-x86.msu"
                        $W81FullPath32 = Join-Path -Path $PackagePath -ChildPath $W81File32
	                    Write-Verbose -Message "Downloading $Product for $WinEdition. Destination: $W81FullPath32"
	                    $Downloader = Invoke-WebRequest -Uri 'http://go.microsoft.com/fwlink/?LinkID=717963' -OutFile $W81FullPath32
	                    Unblock-File -Path "$W81FullPath32"
                    }
                    catch
                    {
	                    throw $_
                    }
                }
                else
                {
	                $W81File32 = "Win8.1-KB3134758-x86.msu"
	                $W81FullPath32 = Join-Path -Path $PackagePath -ChildPath $W81File32
                }   
                Write-Verbose -Message "Installing $Product"
                $UpdateFile = Start-Process -FilePath "wusa.exe" -ArgumentList "`"$W81FullPath32`" /quiet /norestart" -Wait -Passthru
                $ExitCode = $UpdateFile.ExitCode
            }
        }
        else
        {
            if ($HotFix -eq $null)
            {
                if($OnlineInstall)
                {
                    try
                    {
                        $W81File64 = "Win8.1AndW2K12R2-KB3134758-x64.msu"
                        $W81FullPath64 = Join-Path -Path $PackagePath -ChildPath $W81File64
                        Write-Verbose -Message "Downloading $Product for $WinEdition. Destination: $W81FullPath64"
                        $Downloader = Invoke-WebRequest -Uri 'http://go.microsoft.com/fwlink/?LinkId=717507' -OutFile $W81FullPath64
                        Unblock-File -Path "$W81FullPath64"
                    }
                    catch
                    {
                        throw $_
                    }
                }
                else
                {
                    $W81File64 = "Win8.1AndW2K12R2-KB3134758-x64.msu"
                    $W81FullPath64 = Join-Path -Path $PackagePath -ChildPath $W81File64
                }
                Write-Verbose -Message "Installing $Product"
                $UpdateFile = Start-Process -FilePath "wusa.exe" -ArgumentList "`"$W81FullPath64`" /quiet /norestart" -Wait -Passthru
                $ExitCode = $UpdateFile.ExitCode
            }
        }
    }
    default
    {
	    Write-Error -Message "The computer does not meet system requirements." -Category ResourceUnavailable
    }
}

if (!($ExitCode -eq $null))
{
    Write-Verbose -Message "$Product installer exit code: $ExitCode"
    if ($ExitCode -eq 0)
    {
        Write-Verbose -Message "Installation completed successfully."
    }
    elseif ($ExitCode -eq 1602)
    {
        Write-Error -Message "The user canceled installation." -Category OperationStopped
    }
    elseif ($ExitCode -eq 1603)
    {
        Write-Error -Message "A fatal error occurred during installation." -Category InvalidResult
    }
    elseif ($ExitCode -eq 1641)
    {
        Write-Warning -Message "A restart is required to complete the installation. This message indicates success."
    }
    elseif ($ExitCode -eq 3010)
    {
        Write-Warning -Message "A restart is required to complete the installation. This message indicates success."
    }
    elseif ($ExitCode -eq 5100)
    {
        Write-Error -Message "The computer does not meet system requirements." -Category ResourceUnavailable
    }
}

Remove-CimSession -CimSession $Session