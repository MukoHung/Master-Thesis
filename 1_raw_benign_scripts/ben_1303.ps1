<#
.SYNOPSIS
    Enable VSS Shadow Copies on remote computers.
.DESCRIPTION
    Enable VSS Shadow Copies on remote computers. The default settings will take a snapshot every 1 hour and use up to 5% of the disk.
.PARAMETER ComputerName
    The computer(s) to enable VSS on. If piping from Get-ADComputer use 'Get-ADComputer -Filter * | select Name' to handle a bug in Get-ADComputer's piping.
.PARAMETER DriveLetter
    Which drive to enable VSS on.
.PARAMETER CacheSize
    How much of the drive to use for cache, defaults to 5% but may also be specified as xMB/GB/TB.
.PARAMETER TaskInterval
    How often to take a snapshot, defaults to 1H. Valid options include xH/M/S.
.PARAMETER TaskDuration
    How many hours a day should the VSS snapshot task run. Specified as xH where x is 1-24.
.PARAMETER TaskStartTime
    What time should the recurring task start. Defaults to midnight '00:00:00'.
.PARAMETER Credential
    Credential to use to perform the changes.
.EXAMPLE
    .\Enable-VSSShadowCopies.ps1 -ComputerName 'SERVER1' -DriveLetter C
.EXAMPLE
    'SERVER1','SERVER2' | .\Enable-VSSShadowCopies.ps1 -DriveLetter D -CacheSize 20GB -TaskInterval 1H -TaskDuration 12H -TaskStartTime '06:00:00'
.EXAMPLE
    Get-ADComputer -Filter {Name -like 'SERVER*'} | Select-Object Name | .\Enable-VSSShadowCopies.ps1 -DriveLetter D -Credential (Get-Credential) -Verbose
#>
[CmdletBinding()]
param(

    [parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
    [Alias('IPAddress','__Server','CN','Name')]
    [string[]]
    $ComputerName,

    [Parameter(Mandatory)]
    [ValidateNotNull()]
    [ValidateLength(1,1)]
    [string]
    $DriveLetter,

    [ValidatePattern('\d+(MB|GB|TB|%)')]
    [string]
    $CacheSize='5%',

    [ValidatePattern('\d+[HMS]')]
    [string]
    $TaskInterval='1H',

    [ValidatePattern('\d+[H]')]
    [string]
    $TaskDuration='24H',

    [ValidatePattern('\d\d:\d\d:\d\d')]
    [string]
    $TaskStartTime='00:00:00',


    [ValidateNotNull()]
    [System.Management.Automation.PSCredential]
    [System.Management.Automation.Credential()]
    $Credential = [System.Management.Automation.PSCredential]::Empty

)

begin {

    $CacheSize    = $CacheSize.ToUpper()
    $TaskInterval = $TaskInterval.ToUpper()
    $TaskDuration = $TaskDuration.ToUpper()

}

process {

    $ComputerName | ForEach-Object {

        Invoke-Command -ComputerName $_ -Credential $Credential -ScriptBlock {

            $DriveLetter       = $Using:DriveLetter
            $CacheSize         = $Using:CacheSize

            if ( -not( (vssadmin.exe list shadowstorage) -match "for volume: \(${DriveLetter}:\)" ) ) {

                Write-Verbose "Enabling VSS on ${DriveLetter}: with cache size ${CacheSize}" -Verbose:$Using:VerbosePreference
        
                $return = vssadmin add shadowstorage /for=${DriveLetter}: /on=${DriveLetter}:  /maxsize=${CacheSize}

            } else {

                Write-Verbose "VSS already enabled on ${DriveLetter}:, updating cache size to ${CacheSize}" -Verbose:$Using:VerbosePreference
        
                $return = vssadmin.exe resize shadowstorage /for=${DriveLetter}: /on=${DriveLetter}:  /maxsize=${CacheSize}

            }

            switch -Regex ( $return ) {

                'error: (.*)' { Write-Error $Matches[1] }

            }

            switch -Regex ( vssadmin.exe list shadowstorage ) {

                'for volume: (\([^:]+:\).*)' {
                    $volume = New-Object PSObject
                    $volume | Add-Member -MemberType NoteProperty -Name 'Volume' -Value $Matches[1]
                }

                'shadow copy storage volume: (\([^:]+:\).*)' {
                    $volume | Add-Member -MemberType NoteProperty -Name 'StorageVolume' -Value $Matches[1]
                }

                'used shadow copy storage space: ([0-9\.]+)\s([a-z]+)' {
                    $volume | Add-Member -MemberType NoteProperty -Name 'UsedSpace' -Value "$($Matches[1])$($Matches[2])"
                }

                'allocated shadow copy storage space: ([0-9\.]+)\s([a-z]+)' {
                    $volume | Add-Member -MemberType NoteProperty -Name 'AllocatedSpace' -Value "$($Matches[1])$($Matches[2])"
                }

                'maximum shadow copy storage space: ([0-9\.]+)\s([a-z]+)' {
                    $volume | Add-Member -MemberType NoteProperty -Name 'MaximumSpace' -Value "$($Matches[1])$($Matches[2])"
                    $volume
                }

            }

        }

        Invoke-Command -ComputerName $_ -Credential $Credential -ScriptBlock {

            $DriveLetter       = $Using:DriveLetter
            $TaskInterval      = $Using:TaskInterval
            $TaskDuration      = $Using:TaskDuration
            $TaskStartTime     = $Using:TaskStartTime

            $Volume = Get-Volume -DriveLetter $DriveLetter

            $TaskName = $Volume.UniqueId -replace '\\\\\?\\(.*)\\', 'ShadowCopy$1'

            if ( Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue ) {

                Write-Verbose "VSS task '$TaskName' already exists on $env:COMPUTERNAME, overwriting with new schedule..." -Verbose:$Using:VerbosePreference

            }
    
            $ScheduledTaskXml = @"
<?xml version="1.0" encoding="UTF-16"?>
<Task version="1.1" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task">
    <RegistrationInfo>
    <Author>$env:USERDOMAIN\Administrator</Author>
    <URI>\$TaskName</URI>
    </RegistrationInfo>
    <Triggers>
    <CalendarTrigger>
        <Repetition>
        <Interval>PT${TaskInterval}</Interval>
        <Duration>PT${TaskDuration}</Duration>
        <StopAtDurationEnd>false</StopAtDurationEnd>
        </Repetition>
        <StartBoundary>$(Get-Date -Format 'yyyy-MM-dd')T${TaskStartTime}</StartBoundary>
        <Enabled>true</Enabled>
        <ScheduleByDay>
        <DaysInterval>1</DaysInterval>
        </ScheduleByDay>
    </CalendarTrigger>
    </Triggers>
    <Principals>
    <Principal id="Author">
        <UserId>S-1-5-18</UserId>
        <RunLevel>HighestAvailable</RunLevel>
    </Principal>
    </Principals>
    <Settings>
    <DisallowStartIfOnBatteries>false</DisallowStartIfOnBatteries>
    <StopIfGoingOnBatteries>false</StopIfGoingOnBatteries>
    <IdleSettings>
        <Duration>PT10M</Duration>
        <WaitTimeout>PT1H</WaitTimeout>
        <StopOnIdleEnd>false</StopOnIdleEnd>
        <RestartOnIdle>false</RestartOnIdle>
    </IdleSettings>
    <Enabled>true</Enabled>
    <Hidden>false</Hidden>
    <RunOnlyIfIdle>false</RunOnlyIfIdle>
    <WakeToRun>false</WakeToRun>
    <ExecutionTimeLimit>PT72H</ExecutionTimeLimit>
    <Priority>5</Priority>
    </Settings>
    <Actions Context="Author">
    <Exec>
        <Command>C:\windows\system32\vssadmin.exe</Command>
        <Arguments>Create Shadow /AutoRetry=15 /For=$($Volume.Path)</Arguments>
        <WorkingDirectory>%systemroot%\system32</WorkingDirectory>
    </Exec>
    </Actions>
</Task>
"@

            Write-Verbose "Registering VSS task '$TaskName' on $env:COMPUTERNAME" -Verbose:$Using:VerbosePreference
    
            Register-ScheduledTask -Xml $ScheduledTaskXml -TaskName $TaskName -Force > $null

            Write-Verbose 'Running scheduled task...' -Verbose:$Using:VerbosePreference
    
            Start-ScheduledTask -TaskName $TaskName

            while ( (Get-ScheduledTask -TaskName $TaskName).State -ne 'Ready' ) {

                Write-Verbose 'Waiting for scheduled task to finish...' -Verbose:$Using:VerbosePreference
                Start-Sleep -Seconds 2

            }

            if ( ( Get-ScheduledTask -TaskName $TaskName | Get-ScheduledTaskInfo ).LastTaskResult -eq 0 ) {

                Write-Verbose 'Scheduled task finished successfully!' -Verbose:$Using:VerbosePreference

            } else {

                Write-Error "Failed to run VSS task '$TaskName' on $env:COMPUTERNAME"

            }
        }
    }

}