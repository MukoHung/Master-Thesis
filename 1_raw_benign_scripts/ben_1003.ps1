param(
    
    [Parameter(ParameterSetName='AD')]
    [Switch]$ADLookup,
    
    [Parameter(ParameterSetName='FileList')]
    $FileList,

    [Parameter(ParameterSetName='ComputerName')]
    [String[]]$ComputerName,


    [Parameter(ParameterSetName='FileList')]
    [Parameter(ParameterSetName='ComputerName')]
    [Parameter(ParameterSetName='AD')]
    $WorkPath = "C:\TS",

    [Parameter(ParameterSetName='FileList')]
    [Parameter(ParameterSetName='ComputerName')]
    [Parameter(ParameterSetName='AD')]
    $MaxJobs = 5


    )
<#
.SYNOPSIS
Script to run Invoke-TSxLOG4JChecker.ps1 on remote systems.

.DESCRIPTION
This script runs Invoke-TSxLOG4JChecker.ps1 on remote systems and copies logs back.

Please ensure that the disclaimer is read and understood before execution!

.NOTES
 Author: Truesec Cyber Security Incident Response Team
 Website: https://truesec.com/
 Created: 2021-12-13

 .DISCLAIMER
 This script is provided "AS-IS"

#>




# Check if WorkPath folder exist, create if false
if (!(Test-Path -Path $WorkPath)) {
    New-Item $WorkPath -Type Directory
}

# Check if LOG4JCollection folder exist, create if false
if (!(Test-Path -Path $WorkPath\LOG4JCollection)) {
    New-Item $WorkPath\LOG4JCollection -Type Directory
}

# Get timestamp to use in naming of error file
$TimeStamp = Get-Date -UFormat "%Y%m%d.%H%M%S"


If ($ADLookup) {
    $Computers = (Get-ADComputer -Filter { Enabled -eq $true -and OperatingSystem -like "*Server*" } -Properties DNSHostName | Select-Object DNSHostName).DNSHostName
}

If ($FileList) {
    $Computers = Get-Content -Path $FileList 
}

If ($FileList) {
    $Computers = $ComputerName
}



$init = {
    function Invoke-RemoteLog4Check {
        param (
            [Parameter(Position = 0)]
            $Computer,
            [Parameter(Position = 1)]
            $WorkPath
        )



        Try {
            # First try PSSession
            $Session = New-PSSession -ComputerName $Computer -ErrorAction Stop

            $null = Invoke-Command -ScriptBlock { powershell.exe -ExecutionPolicy Bypass "C:\windows\temp\Invoke-TSxLOG4JChecker.ps1" } -Session $Session  -ErrorAction Stop

            Copy-Item -Path "C:\windows\temp\LOG4JCollection\*.txt" -Destination "$WorkPath\LOG4JCollection\" -FromSession $session -ErrorAction Stop

            Invoke-Command -Session $session -ScriptBlock {
                Remove-Item "c:\windows\temp\LOG4JCollection" -Recurse -Force
                Remove-Item "c:\windows\temp\Invoke-TSxLOG4JChecker.ps1" -Force
            } -ErrorAction Stop

        }
        Catch {

            $null = Invoke-WmiMethod -Path Win32_Process -Name Create -ArgumentList "powershell.exe -ExecutionPolicy Bypass C:\windows\temp\Invoke-TSxLOG4JChecker.ps1" -ComputerName $Computer

            Copy-Item "\\$Computer\c$\windows\temp\LOG4JCollection\*.txt" -Destination "$WorkPath\LOG4JCollection\"
            Remove-Item "\\$Computer\c$\windows\temp\LOG4JCollection" -Recurse -Force
            Remove-Item "\\$Computer\c$\windows\temp\Invoke-TSxLOG4JChecker.ps1" -Force
        }

    }
}


# Set a timestap as sufix for the PowerShell Job Name
$JobSuffix = (Get-Date).ToString("yyMMddHHmmss")

# Keep track of started and failed tries
$Failed = 0
$i = 0

foreach ($Computer in $Computers) {

    While ($(Get-Job -State Running).Count -ge $MaxJobs) {
        Start-Sleep -Seconds 30
    }


    Try {

        $Session = New-PSSession -ComputerName $Computer -ErrorAction Stop
        Copy-Item -Path "$WorkPath\Invoke-TSxLOG4JChecker.ps1" -Destination "C:\windows\temp\Invoke-TSxLOG4JChecker.ps1" -ToSession $Session -ErrorAction Stop
        $fileCopied = $true

        Remove-PSSession $Session
    }
    Catch {
        $FileCopied = $false
    }

    If ( $FileCopied -eq $false) {

        Try {
            Copy-Item -Path "$WorkPath\Invoke-TSxLOG4JChecker.ps1" -Destination "\\$computer\c$\windows\temp" -Force -ErrorAction Stop
            $FileCopied = $true
        }
        Catch {
            $FileCopied = $false
        }

    }

    If ($FileCopied -eq $true) {
        Start-Job -InitializationScript $init -ScriptBlock { Invoke-RemoteLog4Check -Computer $Args[0] -WorkPath $Args[1] } -Name "Invoke-RemoteLog4Check-$jobsuffix" -ArgumentList $Computer, $WorkPath
        $i ++
        Write-Progress -Activity "RemoteLog4Check on computers: $($Computers.Count)" -PercentComplete $($i / $Computers.Count * 100) -Status "Started: $i" -Id 1

        $Done = (Get-Job -Name "Invoke-RemoteLog4Check-$JobSuffix" | Where-Object State -eq Completed).Count
        Write-Progress -Activity "Done" -PercentComplete $($Done / $Computers.Count * 100) -Status "$Done" -ParentId 1
    }
    else {
        Write-Warning "Could not access computer, adding $Computer to $WorkPath\Failed_$TimeStamp.txt"
        $Computer | Out-File -Append -Encoding utf8 -FilePath $WorkPath\Failed_$TimeStamp.txt
        $Failed ++
    }
}


while ((Get-Job -Name "Invoke-RemoteLog4Check-$JobSuffix" | Where-Object State -eq Running).count -gt 0) {

    $Done = (Get-Job -Name "Invoke-RemoteLog4Check-$JobSuffix" | Where-Object State -eq Completed).count
    Write-Progress -Activity "Done" -PercentComplete $($Done / $i * 100) -Status $Done  -ParentId 1
    Start-Sleep -Seconds 30
}

Write-Progress -Activity "Done" -PercentComplete 100 -Status "Done"  -Id 1


# Write result to output
$Object = New-Object PSCustomObject
$Object | Add-Member Computers $($Computers.Count)
$Object | Add-Member JobsStarted $i
$Object | Add-Member JobsCompleted (Get-Job -Name "Invoke-RemoteLog4Check-$JobSuffix" | Where-Object State -eq Completed).Count
$Object | Add-Member ComputersNotReacheble $Failed

$Object