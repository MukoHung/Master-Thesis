<#
.SYNOPSIS

Disables services not required in Windows Server 2016.

.DESCRIPTION

Disables services not required to increase security of the system.

.PARAMETER ComputerName
Specifies a remote computer. Type the NetBIOS name, an Internet Protocol (IP) address, or a fully qualified domain name of a remote computer.

.PARAMETER MachineName
Specifies a remote computer. Type the NetBIOS name, an Internet Protocol (IP) address, or a fully qualified domain name of a remote computer.

.PARAMETER XboxOnly
Specifies the to only disable the Xbox services.

.INPUTS

You can pipe objects to ComputerName by the property name.
You can pipe objects to MachineName by the string data type.

.OUTPUTS

None. This command does not generate any output.

.EXAMPLE

PS C:\> Disable-Unused2016Services

This command with no parameters will disable all services that are not required in Windows Server 2016.

.EXAMPLE

PS C:\> Disable-Unused2016Services SVR01,SVR02,SVR03 -XboxOnly

This command with will remotely disable the 2 Xbox services on the computers named SVR01, SVR02 and SVR03.

.EXAMPLE

PS C:\> Get-ADComputer -Filter {OperatingSystem -Like "Windows Server*"} | Select-Object -ExpandProperty Name | Disable-Unused2016Services

Remotely disables unused services of computers piped in from AD.

.LINK

https://gist.github.com/GavinEke/abfc2a547aea74b9d74a2c0c598f3fd7
#>
Function Disable-Unused2016Services {
    [CmdletBinding(
        DefaultParameterSetName='ComputerName',
        SupportsShouldProcess=$True
    )]
    Param(
        [Parameter(ParameterSetName='ComputerName',ValueFromPipelineByPropertyName=$True)]
        [Alias('__SERVER')]
        [String[]]$ComputerName,
        
        [Parameter(ParameterSetName='MachineName',ValueFromPipeline=$True)]
        [String[]]$MachineName,

        [switch]$XboxOnly
    )

    Begin{
        $fullservices = @(
            'AxInstSV',
            'bthserv',
            'CDPUserSvc',
            'PimIndexMaintenanceSvc',
            'dmwappushservice',
            'MapsBroker',
            'lfsvc',
            'SharedAccess',
            'lltdsvc',
            'wlidsvc',
            'NgcSvc',
            'NgcCtnrSvc',
            'NcbService',
            'PhoneSvc',
            'PcaSvc',
            'QWAVE',
            'RmSvc',
            'SensorDataService',
            'SensrSvc',
            'SensorService',
            'ShellHWDetection',
            'ScDeviceEnum',
            'SSDPSRV',
            'WiaRpc',
            'OneSyncSvc',
            'TabletInputService',
            'upnphost',
            'UserDataSvc',
            'UnistoreSvc',
            'WalletService',
            'Audiosrv',
            'AudioEndpointBuilder',
            'FrameServer',
            'stisvc',
            'wisvc',
            'icssvc',
            'WpnService',
            'WpnUserService',
            'XblAuthManager',
            'XblGameSave'
        )
        $xboxservices = @(
            'XblAuthManager',
            'XblGameSave'
        )
        
        If ($XboxOnly) {
            Write-Verbose -Message 'Selecting only xbox services'
            $services = $xboxservices
        } Else {
            Write-Verbose -Message 'Selecting all services not required'
            $services = $fullservices
        }
    }

    Process {
        If ($PSCmdlet.ParameterSetName -eq 'ComputerName') {$Computer = $ComputerName}
        If ($PSCmdlet.ParameterSetName -eq 'MachineName') {$Computer = $MachineName}
        
        If ($Computer) {
            ForEach ($service in $services) {
                Write-Verbose -Message "Disabling $service on $Computer"
                Set-Service -ComputerName $Computer -Name $service -StartupType Disabled -ErrorAction SilentlyContinue
            }
            Write-Verbose -Message "Disabling Xbox tasks on $Computer"
            [void]$(Invoke-Command -ComputerName $Computer -ScriptBlock {Get-ScheduledTask -TaskPath '\Microsoft\XblGameSave\' | Disable-ScheduledTask})
        } Else {
            ForEach ($service in $services) {
                Write-Verbose -Message "Disabling $service on localhost"
                Set-Service -Name $service -StartupType Disabled
            }
            Write-Verbose -Message 'Disabling Xbox tasks on localhost'
            [void]$(Get-ScheduledTask -TaskPath '\Microsoft\XblGameSave\' | Disable-ScheduledTask)
        }
    }

    End{}
}
