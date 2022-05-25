configuration FixRemediateDriverIssue
{
    # DSC GraniResource : https://github.com/guitarrapc/DSCResources/tree/master/Custom
    Import-DscResource -ModuleName GraniResource
    cScheduleTask PlugAndPlayCleanup
    {
        Ensure = "Present"
        TaskName = 'Plug and Play Cleanup'
        TaskPath = '\Microsoft\Windows\Plug and Play\'
        Disable = $true
    }

    Script "RemoveRegistry-xenvbd"
    {
        SetScript       = { Remove-Item -Path 'registry::HKLM\SYSTEM\CurrentControlSet\Services\xenvbd\StartOverride' }
        TestScript      = { -not(Test-Path -Path 'registry::HKLM\SYSTEM\CurrentControlSet\Services\xenvbd\StartOverride') }
        GetScript       = {return @{
                TestScript = $TestScript
                SetScript  = $SetScript
                GetScript  = $GetScript
                Result     = $Result
            }
        }
    }

    Script "RemoveRegistry-xenfilt"
    {
        SetScript       = { Remove-Item -Path 'registry::HKLM\SYSTEM\CurrentControlSet\Services\xenfilt\StartOverride' }
        TestScript      = { -not(Test-Path -Path 'registry::HKLM\SYSTEM\CurrentControlSet\Services\xenfilt\StartOverride') }
        GetScript       = {return @{
                TestScript = $TestScript
                SetScript  = $SetScript
                GetScript  = $GetScript
                Result     = $Result
            }
        }
    }

    Script "RemoveRegistry-xenbus"
    {
        SetScript       = { Remove-Item -Path 'registry::HKLM\SYSTEM\CurrentControlSet\Services\xenbus\StartOverride' }
        TestScript      = { -not(Test-Path -Path 'registry::HKLM\SYSTEM\CurrentControlSet\Services\xenbus\StartOverride') }
        GetScript       = {return @{
                TestScript = $TestScript
                SetScript  = $SetScript
                GetScript  = $GetScript
                Result     = $Result
            }
        }
    }

    Script "RemoveRegistry-xeniface"
    {
        SetScript       = { Remove-Item -Path 'registry::HKLM\SYSTEM\CurrentControlSet\Services\xeniface\StartOverride' }
        TestScript      = { -not(Test-Path -Path 'registry::HKLM\SYSTEM\CurrentControlSet\Services\xeniface\StartOverride') }
        GetScript       = {return @{
                TestScript = $TestScript
                SetScript  = $SetScript
                GetScript  = $GetScript
                Result     = $Result
            }
        }
    }

    Script "RemoveRegistry-xenvif"
    {
        SetScript       = { Remove-Item -Path 'registry::HKLM\SYSTEM\CurrentControlSet\Services\xenvif\StartOverride' }
        TestScript      = { -not(Test-Path -Path 'registry::HKLM\SYSTEM\CurrentControlSet\Services\xenvif\StartOverride') }
        GetScript       = {return @{
                TestScript = $TestScript
                SetScript  = $SetScript
                GetScript  = $GetScript
                Result     = $Result
            }
        }
    }

    Registry xenbus
    {
        Ensure = "Present"
        Key = 'HKEY_lOCAL_MACHINE\System\CurrentControlSet\Services\Xenbus'
        ValueName = "Count"
        ValueData = "1"
        ValueType = "Dword"
    }

    Registry xenbusParameter
    {
        Ensure = "Present"
        Key = 'HKEY_LOCAL_MACHINE\System\CurrentControlSet\Services\XENBUS\Parameters'
        ValueName = "ActiveDevice"
        ValueData = 'PCI\VEN_5853&DEV_0001&SUBSYS_00015853&REV_01'
        ValueType = "String"
    }

    Registry UpperFilters4d36e97d
    {
        Ensure = "Present"
        Key = 'HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Class\{4d36e97d-e325-11ce-bfc1-08002be10318}'
        ValueName = "UpperFilters"
        ValueData = "XENFILT"
        ValueType = "String"
    }

    Registry UpperFilters4d36e96a
    {
        Ensure = "Present"
        Key = 'HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Class\{4d36e96a-e325-11ce-bfc1-08002be10318}'
        ValueName = "UpperFilters"
        ValueData = "XENFILT"
        ValueType = "String"
    }
}
