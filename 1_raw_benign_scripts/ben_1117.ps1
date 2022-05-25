Configuration SCCMDistributionPoint
{
    # Create NO_SMS_ON_DRIVE.SMS file on C:\ drive
    File NoSmsOnDrive
    {
        DestinationPath = "C:\NO_SMS_ON_DRIVE.SMS"
        Contents = [System.String]::Empty
        Type = "File"
        Ensure = "Present"
    }

    # Remote Differential Compression
    WindowsFeature RemoteDifferentialCompression
    {
        Name = "RDC"
        Ensure = "Present"
        LogPath = "C:\Windows\debug\DSC_WindowsFeature_RemoteDifferentialCompression.log"
    }

    # DHCP Server
    WindowsFeature DhcpServer
    {
        Name = "DHCP"
        Ensure = "Present"
        LogPath = "C:\Windows\debug\DSC_WindowsFeature_DhcpServer.log"
    }

    # DHCP Server Tools
    WindowsFeature DhcpServerTools
    {
        DependsOn = "[WindowsFeature]DhcpServer"
        Name = "RSAT-DHCP"
        Ensure = "Present"
        LogPath = "C:\Windows\debug\DSC_WindowsFeature_DhcpServerTools.log"
    }

    # DHCP Server Option Value - 006 DNS Server
    Script DhcpServerOptionValue006
    {
        DependsOn = "[WindowsFeature]DhcpServer"
        TestScript = {
            $IPConfig = (Get-NetIPConfiguration | Where-Object IPv4DefaultGateway)
            $DNSServer = ($IPConfig.DNSServer | Where-Object AddressFamily -eq 2).ServerAddresses
            
            $Option = Get-DhcpServerv4OptionValue -OptionId 6 -ErrorAction SilentlyContinue
            if ($Option -ne $null)
            {
                $CompareResult = Compare-Object -ReferenceObject $DNSServer `
                    -DifferenceObject $Option.Value
                         
                return ($CompareResult.SideIndicator -eq $null)
            }
            else
            {
                return $false
            }
        }
        SetScript = { 
            $IPConfig = (Get-NetIPConfiguration | Where-Object IPv4DefaultGateway)
            $DNSServer = ($IPConfig.DNSServer | Where-Object AddressFamily -eq 2).ServerAddresses

            Set-DhcpServerv4OptionValue -DnsServer $DNSServer
        }
        GetScript = {
            return @{
                GetScript = $GetScript
                SetScript = $SetScript
                TestScript = $TestScript
                Credential = $Credential
                Result = (Invoke-Expression $TestScript)
            }
        }
    }

    # DHCP Server Option Value - 015 DNS Domain Name
    Script DhcpServerOptionValue015
    {
        DependsOn = "[WindowsFeature]DhcpServer"
        TestScript = {
            $Option = Get-DhcpServerv4OptionValue -OptionId 15 -ErrorAction SilentlyContinue
            if ($Option -ne $null)
            {
                return [bool]($Option.Value -eq (Get-WmiObject -Class Win32_ComputerSystem).Domain)
            }
            else
            {
                return $false
            }
        }
        SetScript = { 
            Set-DhcpServerv4OptionValue -DnsDomain (Get-WmiObject -Class Win32_ComputerSystem).Domain
        }
        GetScript = {
            return @{
                GetScript = $GetScript
                SetScript = $SetScript
                TestScript = $TestScript
                Credential = $Credential
                Result = (Invoke-Expression $TestScript)
            }
        }
    }

    # DHCP Server Option Value - 060 PXEClient
    Script DhcpServerOptionValue060
    {
        DependsOn = "[WindowsFeature]DhcpServer"
        TestScript = {
            $Option = Get-DhcpServerv4OptionValue -OptionId 60 -ErrorAction SilentlyContinue
            if ($Option -ne $null)
            {
                return [bool]($Option.Value -eq "PXEClient")
            }
            else
            {
                return $false
            }
        }
        SetScript = {
            Set-DhcpServerv4OptionValue -OptionId 60 -Value "PXEClient"
        }
        GetScript = {
            return @{
                GetScript = $GetScript
                SetScript = $SetScript
                TestScript = $TestScript
                Credential = $Credential
                Result = (Invoke-Expression $TestScript)
            }
        }
    }

    # DHCP Server Option Value - 066 Boot Server Host Name
    Script DhcpServerOptionValue066
    {
        DependsOn = "[WindowsFeature]DhcpServer"
        TestScript = {
            $IPConfig = (Get-NetIPConfiguration | Where-Object IPv4DefaultGateway)

            $Option = Get-DhcpServerv4OptionValue -OptionId 66 -ErrorAction SilentlyContinue
            if ($Option -ne $null)
            {
                return [bool]($Option.Value -eq $IPConfig.IPv4Address.IPAddress)
            }
            else
            {
                return $false
            }
        }
        SetScript = {
            $IPConfig = (Get-NetIPConfiguration | Where-Object IPv4DefaultGateway) 
            Set-DhcpServerv4OptionValue -OptionId 66 -Value $IPConfig.IPv4Address.IPAddress
        }
        GetScript = {
            return @{
                GetScript = $GetScript
                SetScript = $SetScript
                TestScript = $TestScript
                Credential = $Credential
                Result = (Invoke-Expression $TestScript)
            }
        }
    }

    # DHCP Server Option Value - 067 Bootfile Name
    Script DhcpServerOptionValue067
    {
        DependsOn = "[WindowsFeature]DhcpServer"
        TestScript = {
            $Option = Get-DhcpServerv4OptionValue -OptionId 67 -ErrorAction SilentlyContinue
            if ($Option -ne $null)
            {
                return [bool]($Option.Value -eq "SMSBoot\x64\wdsnbp.com")
            }
            else
            {
                return $false
            }
        }
        SetScript = {
            Set-DhcpServerv4OptionValue -OptionId 67 -Value "SMSBoot\x64\wdsnbp.com"
        }
        GetScript = {
            return @{
                GetScript = $GetScript
                SetScript = $SetScript
                TestScript = $TestScript
                Credential = $Credential
                Result = (Invoke-Expression $TestScript)
            }
        }
    }

    # Windows Deployment Services
    WindowsFeature WindowsDeploymentServices
    {
        Name = "WDS"
        Ensure = "Present"
        IncludeAllSubFeature = $true
        LogPath = "C:\Windows\debug\DSC_WindowsFeature_WindowsDeploymentServices.log"
    }

    # WDS Remote Installation Folder
    File WindowsDeploymentServicesFolder
    {
        DependsOn = "[WindowsFeature]WindowsDeploymentServices"
        DestinationPath = "D:\Deployment"
        Ensure = "Present"
        Type = "Directory"
    }

    # WDS Initialize Server
    Script WindowsDeploymentServicesInitializeServer
    {
        DependsOn = "[File]WindowsDeploymentServicesFolder"
        TestScript = {
            $WdsServer = (New-Object -ComObject WdsMgmt.WdsManager).GetWdsServer("localhost")
            
            return ($WdsServer.SetupManager.InitialSetupComplete)
        }
        SetScript = { 
            Start-Process -FilePath "C:\Windows\System32\wdsutil.exe" -Wait `
                -ArgumentList "/Initialize-Server", "/REMINST:D:\Deployment"
        }
        GetScript = {
            return @{
                GetScript = $GetScript
                SetScript = $SetScript
                TestScript = $TestScript
                Credential = $Credential
                Result = (Invoke-Expression $TestScript)
            }
        }
    }
    
    # WDS Configure DHCP settings
    Script WindowsDeploymentServicesConfigureDhcpProperties
    {
        DependsOn = "[Script]WindowsDeploymentServicesInitializeServer"
        TestScript = {
            $WdsServer = (New-Object -ComObject WdsMgmt.WdsManager).GetWdsServer("localhost")
            
            $SetupManager = $WdsServer.SetupManager
            return (
                    $SetupManager.DhcpPxeOptionPresent -eq $true `
                    -and $SetupManager.DhcpOperationMode -eq "2"
                   )
        }
        SetScript = { 
            Start-Process -FilePath "C:\Windows\System32\wdsutil.exe" -Wait `
                -ArgumentList "/Set-Server", "/UseDhcpPorts:No", "/DhcpOption60:Yes"
        }
        GetScript = {
            return @{
                GetScript = $GetScript
                SetScript = $SetScript
                TestScript = $TestScript
                Credential = $Credential
                Result = (Invoke-Expression $TestScript)
            }
        }
    }

    # WDS Configure PXE response delay
    Script WindowsDeploymentServicesConfigurePXEResponseDelay
    {
        DependsOn = "[Script]WindowsDeploymentServicesInitializeServer"
        TestScript = {
            $WdsServer = (New-Object -ComObject WdsMgmt.WdsManager).GetWdsServer("localhost")

            $Policy = $WdsServer.ConfigurationManager.DeviceAnswerPolicy
            return ($Policy.ResponseDelay -eq 1)
        }
        SetScript = {
            $WdsServer = (New-Object -ComObject WdsMgmt.WdsManager).GetWdsServer("localhost")

            $Policy = $WdsServer.ConfigurationManager.DeviceAnswerPolicy
            $Policy.ResponseDelay = 1
            $Policy.Commit()
        }
        GetScript = {
            return @{
                GetScript = $GetScript
                SetScript = $SetScript
                TestScript = $TestScript
                Credential = $Credential
                Result = (Invoke-Expression $TestScript)
            }
        }
    }

    # Windows Server Update Services
    WindowsFeature WindowsServerUpdateServices
    {
        Name = "UpdateServices"
        Ensure = "Present"
        LogPath = "C:\Windows\debug\DSC_WindowsFeature_WindowsServerUpdateServices.log"
    }

    # Windows Server Update Services Management Console
    WindowsFeature WindowsServerUpdateServicesManagementConsole
    {
        Name = "UpdateServices-UI"
        Ensure = "Present"
        LogPath = "C:\Windows\debug\DSC_WindowsFeature_WindowsServerUpdateServicesManagementConsole.log"
    }

    # File Server
    WindowsFeature FileServer
    {
        Name = "FS-FileServer"
        Ensure = "Present"
        LogPath = "C:\Windows\debug\DSC_WindowsFeature_FileServer.log"
    }

    # Web Server (IIS)
    WindowsFeature WebServer
    {
        Name = "Web-Server"
        Ensure = "Present"
        LogPath = "C:\Windows\debug\DSC_WindowsFeature_WebServer.log"
    }

    # IIS Management Console
    WindowsFeature WebServerManagementConsole
    {
        Name = "Web-Mgmt-Console"
        Ensure = "Present"
        LogPath = "C:\Windows\debug\DSC_WindowsFeature_WebServerManagementConsole.log"
    }

    # IIS Management Scripts and Tools
    WindowsFeature WebServerManagementScriptsTools
    {
        Name = "Web-Scripting-Tools"
        Ensure = "Present"
        LogPath = "C:\Windows\debug\DSC_WindowsFeature_WebServerManagementScriptsTools.log"
    }

    # IIS Management Scripts and Tools
    WindowsFeature WebServerManagementService
    {
        Name = "Web-Mgmt-Service"
        Ensure = "Present"
        LogPath = "C:\Windows\debug\DSC_WindowsFeature_WebServerManagementService.log"
    }

    # IIS Logging Tools
    WindowsFeature WebServerLoggingTools
    {
        Name = "Web-Log-Libraries"
        Ensure = "Present"
        LogPath = "C:\Windows\debug\DSC_WindowsFeature_WebServerLoggingTools.log"
    }

    # IIS Tracing
    WindowsFeature WebServerTracing
    {
        Name = "Web-Http-Tracing"
        Ensure = "Present"
        LogPath = "C:\Windows\debug\DSC_WindowsFeature_WebServerTracing.log"
    }

    # IIS Windows Authentication
    WindowsFeature WebServerWindowsAuth
    {
        Name = "Web-Windows-Auth"
        Ensure = "Present"
        LogPath = "C:\Windows\debug\DSC_WindowsFeature_WebServerWindowsAuth.log"
    }

    # IIS WebDAV Publishing
    WindowsFeature WebServerWebDAVPublishing
    {
        Name = "Web-DAV-Publishing"
        Ensure = "Present"
        LogPath = "C:\Windows\debug\DSC_WindowsFeature_WebServerWebDAVPublishing.log"
    }

    # IIS 6 Metabase Compatibility
    WindowsFeature WebServerLegacyMetabaseCompatibility
    {
        Name = "Web-Metabase"
        Ensure = "Present"
        LogPath = "C:\Windows\debug\DSC_WindowsFeature_WebServerLegacyMetabaseCompatibility.log"
    }

    # IIS 6 WMI Compatibility
    WindowsFeature WebServerLegacyWMICompatibility
    {
        Name = "Web-WMI"
        Ensure = "Present"
        LogPath = "C:\Windows\debug\DSC_WindowsFeature_WebServerLegacyWMICompatibility.log"
    }

    # BITS IIS Server Extension
    WindowsFeature WebServerBITSExtension
    {
        Name = "BITS-IIS-Ext"
        Ensure = "Present"
        LogPath = "C:\Windows\debug\DSC_WindowsFeature_WebServerBITSExtension.log"
    }

    # IIS ASP.NET 3.5
    WindowsFeature WebServerAspNet35
    {
        Name = "Web-Asp-Net"
        Ensure = "Present"
        LogPath = "C:\Windows\debug\DSC_WindowsFeature_WebServerAspNet35.log"
    }

    # .NET Framework 3.5 HTTP Activation
    WindowsFeature DotNet35HttpActivation
    {
        Name = "NET-HTTP-Activation"
        Ensure = "Present"
        LogPath = "C:\Windows\debug\DSC_WindowsFeature_DotNet35HttpActivation.log"
    }
    
    # .NET Framework 3.5 Non-HTTP Activation
    WindowsFeature DotNet35NonHttpActivation
    {
        Name = "NET-Non-HTTP-Activ"
        Ensure = "Present"
        LogPath = "C:\Windows\debug\DSC_WindowsFeature_DotNet35NonHttpActivation.log"
    }
}