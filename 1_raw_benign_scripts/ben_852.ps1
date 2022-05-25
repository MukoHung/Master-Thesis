configuration CONFIGVPN
{
   param
   (
        [String]$ComputerName,
        [String]$TimeZone,
        [String]$RemoteGatewayIP,
        [String]$IPv4Subnet,
        [String]$SharedKey,
        [System.Management.Automation.PSCredential]$Admincreds                                  
    )

    Import-DscResource -Module ComputerManagementDsc # Used for TimeZone

    [System.Management.Automation.PSCredential ]$LocalCreds = New-Object System.Management.Automation.PSCredential ("${ComputerName}\$($AdminCreds.UserName)", $AdminCreds.Password)

    Node localhost
    {
        File ConfigureRRAS
        {
            Type = 'Directory'
            DestinationPath = 'C:\ConfigureRRAS'
            Ensure = "Present"
        }

        TimeZone SetTimeZone
        {
            IsSingleInstance = 'Yes'
            TimeZone         = $TimeZone
        }

        Script ConfigureRRAS
        {
            SetScript =
            {
                # Create ConfigureRRAS Script
                $FalseValue = '$False'
                Set-Content -Path C:\ConfigureRRAS\SetupRRAS.ps1 -Value "Install-RemoteAccess -VpnType VpnS2S"
                Add-Content -Path C:\ConfigureRRAS\SetupRRAS.ps1 -Value "Import-Module RemoteAccess"
                Add-Content -Path C:\ConfigureRRAS\SetupRRAS.ps1 -Value "$Service =  Get-Service -Name 'Routing and Remote Access'"
                Add-Content -Path C:\ConfigureRRAS\SetupRRAS.ps1 -Value "$RemoteAccess = Get-RemoteAccess"                
                Add-Content -Path C:\ConfigureRRAS\SetupRRAS.ps1 -Value "$InstallStatus = $RemoteAccess.VpnS2SStatus"                                
                Add-Content -Path C:\ConfigureRRAS\SetupRRAS.ps1 -Value "while (($Service.Status -ne 'Running')){sleep 10}"                                                
                Add-Content -Path C:\ConfigureRRAS\SetupRRAS.ps1 -Value "while (($InstallStatus -ne 'Installed')){sleep 10}"                                                                
                Add-Content -Path C:\ConfigureRRAS\SetupRRAS.ps1 -Value "sleep 30"                                                                
                Add-Content -Path C:\ConfigureRRAS\SetupRRAS.ps1 -Value "Add-VpnS2SInterface -Protocol IKEv2 -AuthenticationMethod PSKOnly -NumberOfTries 3 -ResponderAuthenticationMethod PSKOnly -Name Azure -Destination $using:RemoteGatewayIP -IPv4Subnet $using:IPv4Subnet -SharedSecret $using:SharedKey"
                Add-Content -Path C:\ConfigureRRAS\SetupRRAS.ps1 -Value "Set-VpnServerIPsecConfiguration -EncryptionType MaximumEncryption"
                Add-Content -Path C:\ConfigureRRAS\SetupRRAS.ps1 -Value "Set-VpnS2Sinterface -Name Azure -InitiateConfigPayload $FalseValue -Force"
                Add-Content -Path C:\ConfigureRRAS\SetupRRAS.ps1 -Value "Connect-VpnS2SInterface -Name Azure"
            }
            GetScript =  { @{} }
            TestScript = { $false}
            DependsOn = '[File]ConfigureRRAS'
        }

        ScheduledTask CreateConfigureRRAS
        {
            TaskName            = 'Configure RRAS'
            ActionExecutable    = 'C:\windows\system32\WindowsPowerShell\v1.0\powershell.exe'
            ScheduleType        = 'Once'
            StartTime           = (Get-Date).AddMinutes(1)
            ActionArguments     = 'C:\ConfigureRRAS\SetupRRAS.ps1'
            Enable              = $true
            ExecuteAsCredential = $LocalCreds
            LogonType           = 'Password'
            DependsOn = '[Script]ConfigureRRAS'
        }

        Script AllowLegacy
        {
            SetScript =
            {
                # Allow Remote Copy
                $allowlegacy = get-itemproperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\RemoteAccess\Parameters" -Name "ModernStackEnabled" -ErrorAction 0
                IF ($allowlegacy.ModernStackEnabled -ne 0) {New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\RemoteAccess\Parameters\" -Name "ModernStackEnabled" -Value 0 -Force}
            }
            GetScript =  { @{} }
            TestScript = { $false}
            DependsOn = '[ScheduledTask]CreateConfigureRRAS'
        }

    }
}