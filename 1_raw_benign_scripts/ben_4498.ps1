#requires -module ActiveDirectory

# Input computers.
$threshold = (Get-Date).AddDays(-180)
$computers = Get-ADComputer -Filter { OperatingSystem -notlike "*server*" -and OperatingSystem -like "*windows*" -and PasswordLastSet -gt $threshold } |
    Select-Object -ExpandProperty Name |
        Sort-Object -Property Name

# Make sure there are not existing jobs.
Get-Job |
    Remove-Job -Force

# Counters and settings
$throttle = 20
$timeout = 10
$jobs = @()
$count = 0

# Start the jobs.
while ($count -lt $computers.Count) {
    if ((Get-Job -State Running).Count -lt $throttle) {
        $jobs += Start-Job -ScriptBlock { try { .\Get-EternalBlueVulnerabilityStatistics.ps1 -Name $args[0] -ErrorAction Stop } catch { throw $_ } } -Name $computers[$count] -ArgumentList @($computers[$count])
        Write-Progress -Activity "Gathering EternalBlue statistics accross $($computers.Count) systems. Jobs are throttled to $throttle concurrent jobs" -Status "Job started for $($computers[$count].ToString())" -PercentComplete ($jobs.Count / $computers.Count * 100)
        $count++
    }
}
Write-Progress -Activity "Testing for WannaCry vulnerability accross $($computers.Count) systems" -Completed

# Wait for remaining jobs to finish.
while (($runningJobs = Get-Job -State Running).Count -ne 0) {
    Write-Progress -Activity "Waiting for remaining jobs to finish" -Status "$($runningJobs.Count) jobs remaining"
    foreach ($runningJob in $runningJobs) {
        if ($runningJob.PSBeginTime -lt (Get-Date).AddMinutes(-$timeout)) {
            Stop-Job -Job $runningJob
        }
    }
}
Write-Progress -Activity "Waiting for remaining jobs to finish" -Completed

# Clean up the jobs and export the results to CSVs.
foreach ($job in (Get-Job)) {
    switch ($job.State) {
        "Completed" {
            $receivedJob = Receive-Job -Job $job
            $completedOutput = [PSCustomObject]@{
                PSComputerName = $job.Name
                OperatingSystemCaption = $receivedJob.OperatingSystemCaption
                OperatingSystemVersion = $receivedJob.OperatingSystemVersion
                LastBootUpTime = $receivedJob.LastBootUpTime
                AppliedHotFixID = $receivedJob.AppliedHotFixID
                SMB1FeatureEnabled = $receivedJob.SMB1FeatureEnabled
                SMB1ProtocolEnabled = $receivedJob.SMB1ProtocolEnabled
                Port139Enabled = $receivedJob.Port139Enabled
                Port445Enabled = $receivedJob.Port445Enabled
            }

            Export-Csv -InputObject $completedOutput -Path .\WannaCryVulnerability_Servers.csv -Append -NoTypeInformation
            Remove-Job -Job $job
        }

        "Failed" {
            Receive-Job -Job $job -ErrorAction SilentlyContinue
            $failedOutput = [PSCustomObject]@{
                PSComputerName = $job.Name
                FailureReason = $Error[0].Exception.Message
            }

            Export-Csv -InputObject $failedOutput -Path .\WannaCryVulnerability_Servers_Failures.csv -Append -NoTypeInformation
            Remove-Job -Job $job
        }

        default { continue }
    }
}

