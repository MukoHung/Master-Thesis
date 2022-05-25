# Get all running process name and it's network port number
Get-NetTCPConnection | select OwningProcess,LocalPort | Sort | % { 
  $process = Get-Process -Id $_.OwningProcess;  
  New-Object PSObject -Property @{Name = $process.Name; Port = $_.LocalPort } 
} |  Format-Table -Verbose

# Remove all images whose name matches assignments
docker images | where { $_ -match 'assignments' } | % { $image = $_ -split '\s+'; $image[2] } | % { docker rmi $_}