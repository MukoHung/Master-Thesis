<#
    .SYNOPSIS
        Installs PowerShell scripts as Windows Services.

    .DESCRIPTION
        Installs or removes PowerShell script services.
        When installing, any additional command line arguments besides the mandatory ones are supplied as arguments to the script you are installing, and credentials for the service will be prompted for.
        The service will be installed for automatic start, however the initial state is 'Stopped'

        This tool will additionally pass the switch -Service to the target script which it should implement to know it is running as a service.

    .PARAMETER Name
        Name of the service.

    .PARAMETER Description
        Description of the service.

    .PARAMETER Script
        Absolute or relative path to the PowerShell Script to run as a service.
        Note that the path you supply is where the service wrapper will look for the script.
        If you move or delete it, the service will fail next time it starts.

    .PARAMETER DisplayName
        If present, sets the the service's display name, eg Application Layer Gateway Service. This is the name shown under the Name column in services.msc.
        If absent, the display name is the same as the service name.

    .PARAMETER UserName
        User account under which service will run. If no user name is given, you will be prompted.

    .PARAMETER Password
        Password for service account user. Not required if UserName is SYSTEM or NETWORK SERVICE

    .PARAMETER StartupType
        Startup type for service (e.g. manual, auto). See https://nssm.cc/commands for a description of values.

    .PARAMETER StartImmediately
        If set, the service will be started following installation.

    .PARAMETER ExitAction
        Configures the action which nssm should take when the script exits.
        - Restart   Restarts the script. Not useful if it keeps failing on an unhandled exception.
        - Ignore    Service will appear to be running, but nothing will be happening.
        - Exit      Service will stop.

    .PARAMETER Remove
        Removes the service.

    .NOTES
        This tool uses NSSM.EXE (https://nssm.cc) to configure the target script as a service.
        You need to have this installed and able to be found in the system path or the tool will fail.

    .LINK
        https://nssm.cc/commands
#>
param
(
    [Parameter(Position = 0, Mandatory=$true)]
    [string]$Name,

    [Parameter(Position = 1, Mandatory=$true, ParameterSetName='Install')]
    [string]$Description,

    [Parameter(Position = 2, Mandatory=$true, ParameterSetName='Install')]
    [string]$Script,

    [Parameter(ParameterSetName='Install')]
    [string]$DisplayName,

    [Parameter(ParameterSetName='Install')]
    [string]$UserName,

    [Parameter(ParameterSetName='Install')]
    [string]$Password = [string]::Empty,

    [Parameter(ParameterSetName = 'Install')]
    [ValidateSet('SERVICE_AUTO_START', 'SERVICE_DELAYED_START', 'SERVICE_DEMAND_START', 'SERVICE_DISABLED')]
    [string]$StartupType = 'SERVICE_AUTO_START',

    [Parameter(ParameterSetName = 'Install')]
    [switch]$StartImmediately,

    [Parameter(ParameterSetName='Install')]
    [ValidateSet('Restart', 'Ignore', 'Exit')]
    [string]$ExitAction = 'Exit',

    [Parameter(ValueFromRemainingArguments, ParameterSetName='Install')]
    [string[]]$ScriptArguments,

    [Parameter(ParameterSetName='Remove')]
    [switch]$Remove
)

$ErrorActionPreference = 'Stop'

try
{
    # Check for adminstrator privilege
    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent([Security.Principal.TokenAccessLevels]'Query,Duplicate'))

    if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
    {
        throw 'Need to run this script As Administrator'
    }

    # Find NSSM.EXE. Search this folder, then path
    foreach ($path in @("$PSScriptRoot\nssm.exe", 'nssm.exe'))
    {
        $nssm = Get-Command -Name $path -ErrorAction SilentlyContinue

        if ($nssm)
        {
            break
        }
    }

    if (-not $nssm)
    {
        throw 'Cannot find NSSM.EXE. Please install it (http://nssm.cc).'
    }

    switch ($PSCmdLet.ParameterSetName)
    {
        'Install' {

            # Service's executable is PowerShell.exe
            $servicePath = (Get-Command powershell.exe).Path

            # Remaining command line arguments are script arguments
            if (-not $ScriptArguments)
            {
                $ScriptArguments = '-Service'
            }
            elseif ($ScriptArguments -inotcontains '-Service')
            {
                $ScriptArguments += '-Service'
            }

            $scriptArgs = $(
                $ScriptArguments |
                ForEach-Object {

                    if ($_ -match '\s')
                    {
                        "`"$_`""
                    }
                    else
                    {
                        $_
                    }
                }
            ) -join ' '

            # Build full set of arguments that NSSM will pass to PowerShell.exe
            $serviceArgs = ('-ExecutionPolicy Bypass -NoProfile -File "{0}" {1}' -f (Resolve-Path $Script).Path, $scriptArgs).Trim()

            # Sort out credentials
            $cred = $(

                if (-not $UserName)
                {
                    if (-not [Environment]::UserInteractive)
                    {
                        throw 'Cannot request credentials in non-interactive session'
                    }

                    # Prompt for credentials
                    (Get-Credential -Message 'Enter service credentials').GetNetworkCredential()
                }
                else
                {
                    if ($UserName.IndexOf('\') -gt 0)
                    {
                        # Domain user
                        ($d, $u) = $UserName -split '\\'
                        New-Object System.Net.NetworkCredential ($u, $Password, $d)
                    }
                    else
                    {
                        New-Object System.Net.NetworkCredential ($UserName, $Password)
                    }
                }
            )

            $userName = $(

                if ([string]::IsNullOrEmpty($cred.Domain))
                {
                    $cred.UserName
                }
                else
                {
                    "$($cred.Domain)\$($cred.UserName)"
                }
            )

            # Install service
            & $nssm install $Name $servicePath $serviceArgs

            # Needs a little time to be ready
            Start-Sleep -Milliseconds 500

            # Set long description
            & $nssm set $Name Description $Description

            # Set credentials
            & $nssm set $Name ObjectName $userName $($cred.Password)

            # Set startup behaviour
            & $nssm set $Name Start $StartupType

            # Set display name
            if (-not [string]::IsNullOrEmpty($DisplayName))
            {
                & $nssm set $Name DisplayName $DisplayName
            }

            # Exit behaviour needs to be set directly in the registry
            Set-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Services\$($Name)\Parameters\AppExit" -Value $ExitAction
            Write-Host "Set service behaviour on script exit to $ExitAction"

            if ($StartImmediately -and $StartupType -ine 'SERVICE_DISABLED')
            {
                # Start the service
                $service = Get-Service -Name $name
                $service.Start()
                Write-Host 'Service started.'
            }
        }

        'Remove' {

            $service = Get-Service -Name $name -ErrorAction SilentlyContinue

            if ($service)
            {
                if ($service.Status -ine 'Stopped')
                {
                    Write-Host "Attempting to stop $Name"
                    $service.Stop()

                    while ($service.Status -ine 'Stopped')
                    {
                        Start-Sleep -Seconds 1
                        $service.Refresh()
                    }
                }

                & $nssm remove $Name
            }
        }
    }
}
catch
{
    $_.Exception.Message
    $_.ScriptStackTrace
    throw
}