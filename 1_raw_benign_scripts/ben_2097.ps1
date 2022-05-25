$ComputerInfo = @(
    @{
        Class = 'Win32_OperatingSystem'
        Select = @(
            @{
                N='OS Name'
                E={($_.Name -split '\|') | select -first 1}
            },
            @{
                N='Version'
                E={$_.Version}
            },
            @{
                N='Service Pack'
                E={($_.ServicePackMajorVersion,$_.ServicePackMinorVersion) -join '.'}
            },
            @{
                N='OS Manufacturer'
                E={$_.Manufacturer}
            },
            @{
                N='Windows Directory'
                E={$_.WindowsDirectory}
            },
            @{
                N='Locale'
                E={$_.Locale}
            },
            @{
                N='Available Physical Memory'
                E={$_.FreePhysicalMemory}
            },
            @{
                N='Total Virtual Memory'
                E={$_.TotalVirtualMemorySize}
            },
            @{
                N='Available Virtual Memory'
                E={$_.FreeVirtualMemory}
            }
        )
    },
    @{
        Class = 'Win32_LogicalDisk'
        Select = @(
            @{
                N='Drive'
                E={$_.DeviceID}
            },@{
                N='DriveType'
                E={$_.Description}
            },@{
                N='Size'
                E={$_.Size}
            },@{
                N='Freespace'
                E={$_.FreeSpace}
            },@{
                N='Compressed'
                E={$_.Compressed}
            }
        )
    }
) | ForEach-Object {
    $ThisSelect = $_.Select
    Get-WmiObject -Class $_.Class | Select $ThisSelect
}

$ComputerInfo | Format-List