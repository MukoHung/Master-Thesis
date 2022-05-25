Configuration Config {
    param 
    ( 
        [Parameter(Mandatory)] 
        [string]$NodeName
    )
    
    Node $NodeName
    {
        WindowsFeature HyperV
        {
            Name = "Hyper-V"
            Ensure = "Present"
        }

        WindowsFeature HyperVRSAT
        {
            Name = "RSAT-Hyper-V-Tools"
            Ensure = "Present"
            DependsOn = "[WindowsFeature]HyperV"
        }

        Script CreateFolder
        {
            SetScript = {
                New-Item -Type Directory -Name Lab -Path D:
            }
            TestScript = {
                Test-Path -Path D:\Lab
            }
            GetScript = {
                @{ Ensure =
                    if (Test-Path -Path D:\Lab)
                    {
                        'Present'
                    } else {
                        'Absent'
                    }
                }
            }
            DependsOn = "[WindowsFeature]HyperVRSAT"
        }

        Script DownloadScripts
        {
            SetScript = {
                [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
                Invoke-WebRequest -UseBasicParsing -Uri https://github.com/k-takai/Demo/blob/master/20190629-Interact2019/ClusterSets/scripts.zip?raw=true -OutFile D:\scripts.zip
            }
            TestScript = {
                Test-Path -Path D:\scripts.zip
            }
            GetScript = {
                @{ Ensure =
                    if (Test-Path -Path D:\scripts.zip) {
                        'Present'
                    } else {
                        'Absent'
                    }
                }
            }
            DependsOn = "[Script]CreateFolder"
        }

        Script UnzipScripts
        {
            SetScript = {
                Expand-Archive D:\scripts.zip -DestinationPath D:\Lab -Force
            }
            TestScript = {
                !("1_Prereq.ps1","2_CreateParentDisks.ps1","3_Deploy.ps1","Cleanup.ps1","LabConfig.ps1","PostDeploy.ps1","01_PrepCluster.ps1","02_CreateMgmtCluster.ps1","03_CreateClusterSet.ps1","04_OperateClusterSet.ps1" | ForEach-Object { Test-Path -Path D:\Lab\$_ }).contains($false)
            }
            GetScript = {
                @{ Ensure =
                    if (!("1_Prereq.ps1","2_CreateParentDisks.ps1","3_Deploy.ps1","Cleanup.ps1","LabConfig.ps1","PostDeploy.ps1","01_PrepCluster.ps1","02_CreateMgmtCluster.ps1","03_CreateClusterSet.ps1","04_OperateClusterSet.ps1" | ForEach-Object { Test-Path -Path D:\Lab\$_ }).contains($false))
                    {
                        'Present'
                    } else {
                        'Absent'
                    }
                }
            }
            DependsOn = "[Script]DownloadScripts"
        }

        Script DownloadOSImage
        {
            SetScript = {
                [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
                Invoke-WebRequest -UseBasicParsing -Uri https://software-download.microsoft.com/download/sg/17763.379.190312-0539.rs5_release_svc_refresh_SERVER_EVAL_x64FRE_en-us.iso -OutFile D:\Lab\17763.379.190312-0539.rs5_release_svc_refresh_SERVER_EVAL_x64FRE_en-us.iso
            }
            TestScript = {
                Test-Path -Path D:\Lab\17763.379.190312-0539.rs5_release_svc_refresh_SERVER_EVAL_x64FRE_en-us.iso
            }
            GetScript = {
                @{ Ensure =
                    if (Test-Path -Path D:\Lab\17763.379.190312-0539.rs5_release_svc_refresh_SERVER_EVAL_x64FRE_en-us.iso) {
                        'Present'
                    } else {
                        'Absent'
                    }
                }
            }
            DependsOn = "[Script]CreateFolder"
        }

        Script DownloadCU
        {
            SetScript = {
                [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
                Invoke-WebRequest -UseBasicParsing -Uri http://download.windowsupdate.com/c/msdownload/update/software/updt/2019/06/windows10.0-kb4501371-x64_2b9302491bb940c881795280142c550e789c9eaa.msu -OutFile D:\Lab\windows10.0-kb4501371-x64.msu
            }
            TestScript = {
                Test-Path -Path D:\Lab\windows10.0-kb4501371-x64.msu
            }
            GetScript = {
                @{ Ensure =
                    if (Test-Path -Path D:\Lab\windows10.0-kb4501371-x64.msu) {
                        'Present'
                    } else {
                        'Absent'
                    }
                }
            }
            DependsOn = "[Script]CreateFolder"
        }

        Script DownloadSSU
        {
            SetScript = {
                [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
                Invoke-WebRequest -UseBasicParsing -Uri http://download.windowsupdate.com/c/msdownload/update/software/secu/2019/06/windows10.0-kb4504369-x64_38b8c4dff79633757ee50837a735d3df0e75fa65.msu -OutFile D:\Lab\windows10.0-kb4504369-x64.msu
            }
            TestScript = {
                Test-Path -Path D:\Lab\windows10.0-kb4504369-x64.msu
            }
            GetScript = {
                @{ Ensure =
                    if (Test-Path -Path D:\Lab\windows10.0-kb4504369-x64.msu) {
                        'Present'
                    } else {
                        'Absent'
                    }
                }
            }
            DependsOn = "[Script]CreateFolder"
        }

        Script DownloadWAC
        {
            SetScript = {
                [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
                Invoke-WebRequest -UseBasicParsing -Uri http://aka.ms/WACDownload -OutFile D:\Lab\WindowsAdminCenter.msi
            }
            TestScript = {
                Test-Path -Path D:\Lab\WindowsAdminCenter.msi
            }
            GetScript = {
                @{ Ensure =
                    if (Test-Path -Path D:\Lab\WindowsAdminCenter.msi) {
                        'Present'
                    } else {
                        'Absent'
                    }
                }
            }
            DependsOn = "[Script]CreateFolder"
        }

        LocalConfigurationManager 
        {
            RebootNodeIfNeeded = $true
        }
    }
}
