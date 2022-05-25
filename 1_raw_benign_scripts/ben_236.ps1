configuration AdminRestAp {

    Import-DscResource -ModuleName xPSDesiredStateConfiguration
    Import-DscResource -ModuleName xNetworking

    Node "webserver" {
        <#
            Install windows features
        #>
        WindowsFeature InstallIIS {
            Name = "Web-Server"
            Ensure = "Present"
        }

        WindowsFeature EnableWinAuth {
            Name = "Web-Windows-Auth"
            Ensure = "Present"
            DependsOn = "[WindowsFeature]InstallIIS"
        }

        WindowsFeature EnableURLAuth {
            Name = "Web-Url-Auth"
            Ensure = "Present"
            DependsOn = "[WindowsFeature]InstallIIS"
        }

        WindowsFeature HostableWebCore {
            Name = "Web-WHC"
            Ensure = "Present"
            DependsOn = "[WindowsFeature]InstallIIS"
        }

        xFirewall AllowManagementPort {
            Name = "Admin port"
            DisplayName = "Admin port"
            Ensure = "Present"
            Protocol = "TCP"
            Enabled = "True"
            Direction = "InBound"
            LocalPort = 55539

        }

        <#
            Download dotnet core hosting bundle
        #>
        xRemoteFile DownloadDotNetCoreHostingBundle {
            Uri = "https://go.microsoft.com/fwlink/?linkid=844461" #https://docs.microsoft.com/en-us/aspnet/core/publishing/iis
            DestinationPath = "C:\temp\dnhosting.exe"
            MatchSource = $false
            #Proxy = "optional, your corporate proxy here"
            #ProxyCredential = "optional, your corporate proxy credential here"
        }

        # Discover your product name and id with Get-WmiObject Win32_product | ft IdentifyingNumber,Name after installing it once
        xPackage InstallDotNetCoreHostingBundle {
            Name = "Microsoft ASP.NET Core Module"
            ProductId = "B1B05FBB-1255-4F5B-9BAF-43B971A92613"
            Arguments = "/quiet /norestart /log C:\temp\dnhosting_install.log"
            Path = "C:\temp\dnhosting.exe"
            DependsOn = @("[WindowsFeature]InstallIIS",
                          "[xRemoteFile]DownloadDotNetCoreHostingBundle")
        }

        Script PutDotNetOnPath {
            SetScript = {
                $env:Path = $env:Path + "C:\Program Files\dotnet\;"
            }
            TestScript = {
                return $env:Path.Contains("C:\Program Files\dotnet\;")
            }
            GetScript = {
                return @{
                    SetScript = $SetScript
                    TestScript = $TestScript
                    GetScript = $GetSCript
                    Result = "Set dotnet path"
                }
            }
        }

        xRemoteFile DownloadAdminRestApi {
            Uri = "https://github.com/Microsoft/IIS.Administration/releases/download/v1.1.1/IIS.Administration.zip"
            DestinationPath = "C:\temp\IISAdministration.zip"
            MatchSource = $false
        }

        Archive UnzipAdminRestApi {
            Path = "C:\temp\IISAdministration.zip"
            Destination = "C:\temp\Admin\IISAdministration"
            Ensure = "Present"
            DependsOn = "[xRemoteFile]DownloadAdminRestApi"
        }

        Script InstallAdminRestApi {
            DependsOn = @("[Archive]UnzipAdminRestApi",
                          "[WindowsFeature]InstallIIS",
                          "[WindowsFeature]EnableURLAuth",
                          "[WindowsFeature]EnableWinAuth"
                          "[xPackage]InstallDotNetCoreHostingBundle",
                          "[Script]PutDotNetOnPath")
            SetScript = {
                # Run the IIS Administration installer
                & C:\temp\Admin\IISAdministration\setup\setup.ps1 Install -Verbose                
            }
            TestScript = {
                $svc = $null
                try {
                    $svc = Get-Service "Microsoft IIS Administration" -ErrorAction SilentlyContinue
                } catch {}

                return !!$svc
            }
            GetScript = {
                return @{
                    SetScript = $SetScript
                    TestScript = $TestScript
                    GetScript = $GetScript
                    Result = "Install Admin Rest Api"
                }
            }
        }
    }
}