function Get-ComputerMemory {
    param (
        [Parameter( 
            Position = 0,  
            ValueFromPipeline = $true, 
            ValueFromPipelineByPropertyName = $true 
        )] [String[]]$ComputerName = @($env:COMPUTERNAME.ToLower()),
        [int]$digits = 3
    )
    process {
        foreach ($computer in $ComputerName ) {
            # Initialize object to be returned.
            $monitorInfo = 1 | Select-Object `
             ComputerName,              `
             cpuAveragePct,             `
             UsedPhysicalMemoryPct,     `
             storageVolumes

            # - Begin gathering the info we'll need - 

            # Gather Processor data.
            Write-Progress "Get-WmiObject Win32_Processor -ComputerName $computer | Measure-Object -property LoadPercentage -Average | Select Average"
            $wmiProc = Get-WmiObject Win32_Processor -ComputerName $computer | Measure-Object -property LoadPercentage -Average | Select Average
            if (!$wmiProc) {Write-Warning "Unable to get Win32_Processor data from $computer"}

            # Gather hardware data.
            Write-Progress "Get-WmiObject Win32_ComputerSystem" "-ComputerName $computer"
            $wmiCompSys = Get-WmiObject Win32_ComputerSystem -ComputerName $computer
            if (!$wmiCompSys) {Write-Warning "Unable to get Win32_ComputerSystem data from $computer";}

            # Gather storage volume data.
            Write-Progress "Get-WmiObject Win32_Volume -ComputerName $computer | ? {$_.DriveLetter -ne $null -and $_.FileSystem -like "*FS"}"
            $wmiVolumes = Get-WmiObject Win32_Volume -ComputerName $computer | ? {$_.DriveLetter -ne $null -and $_.FileSystem -like "*FS"}
            if (!$wmiVolumes) {Write-Warning "Unable to get Win32_Volume data from $computer"}

            # Gather OS data.
            Write-Progress "Get-WmiObject Win32_OperatingSystem" "-ComputerName $computer"
            $wmiOpSys = Get-WmiObject Win32_OperatingSystem -ComputerName $computer
            if (!$wmiOpSys) {Write-Warning "Unable to get Win32_OperatingSystem data from $computer"}

            # - Now that we have all the info, create an object from it all -

            # Name of the computer.
            $monitorInfo.ComputerName = $computer.ToLower()

            # CPU utilization.
            $monitorInfo.cpuAveragePct = $wmiProc.Average

            # Storage Volume usage.
            $monitorInfo.storageVolumes = foreach ($volume in $wmiVolumes) {
                $diskObj = 1 | Select-Object DriveLetter, UsedSpacePct
                $diskObj.DriveLetter = $volume.DriveLetter
                $diskObj.UsedSpacePct = [string][int](100 - (100 * $volume.FreeSpace / $volume.Capacity))
                $diskObj
            }

            # Normalize memory to GB. Win32_OperatingSystem returns KB; Win32_ComputerSystem returns bytes.
            $totalPhys = $wmiCompSys.TotalPhysicalMemory / 1GB
            $freePhys = $wmiOpSys.FreePhysicalMemory / 1MB
            $monitorInfo.UsedPhysicalMemoryPct = [string]([int]((100 * (1 - ($freePhys/$totalPhys))) + .5))
            $monitorInfo
        }
    }
}
