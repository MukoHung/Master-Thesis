[CmdletBinding()]
param (
    [Parameter(Position = 0)]
    [String]
    $Command
)
Write-Host "It started"
if (Get-Service 'Docker' -ErrorAction SilentlyContinue) {
    Write-Host "Checking Docker"
    if ((Get-Service Docker).Status -ne 'Running') { Start-Service Docker }
    while ((Get-Service Docker).Status -ne 'Running') { Start-Sleep -s 5 }
    
    Write-Host "Running command"
    Start-Process -NoNewWindow -FilePath "docker.exe" -ArgumentList "$($Command)"
    exit 0
}
else {
    Write-Host "Docker Service was not found!"
    exit 1
}