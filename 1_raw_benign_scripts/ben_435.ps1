# Copy the text below to BeatSaberLauncher.ps1

# You may need to edit the path below
# The default Beat Saber location for Steam version:
Set-Location -Path "C:\Program Files\Steam\steamapps\common\Beat Saber" 
# The default Beat Saber location for Oculus version:
# Set-Location -Path "C:\Program Files\Oculus\Software\Software\hyperbolic-magnetism-beat-saber" 
Start-Process -FilePath "Beat Saber.exe"
Write-Output "Beat Saber started."

$processName = "Beat Saber"
$priorityClass = "High"
$processorAffinity = 15*2 # 11110
$monitorTime = 60 # Seconds
$checkInterval = 10 # Seconds

for ($i = 0; $i -lt $monitorTime; $i += $checkInterval) {
    Start-Sleep $checkInterval
    Write-Output "Looking for Beat Saber processes..."
    $ps = Get-Process | Where-Object {($_.ProcessName -eq $processName) -and ($_.HandleCount -gt 0)}
    foreach ($p in $ps) {
        if (($p.ProcessorAffinity -eq $processorAffinity) -and ($p.PriorityClass -eq $priorityClass)) {
            continue;
        }
        $p.PriorityClass = $priorityClass
        $p.ProcessorAffinity = $processorAffinity
        Write-Output "Just updated parameters of:"
        $p | Format-List -Property Id,ProcessName,CPU,PriorityClass,ProcessorAffinity
    }
}