# Run this script as Administrator
# Set the following to other values if desired
$version = '7.15.0'
$logstash_host = ''

if ( $logstash_host -eq '' )
{
  $logstash_host = Read-Host -Prompt "Please enter the logstash host URI (i.e. localhost:5044)"
}

$winlogbeat_config = @"
winlogbeat.event_logs:
  - name: Application
    ignore_older: 72h
    
  - name: System
  
  - name: Security
  
  - name: Microsoft-Windows-Sysmon/Operational
  
  - name: Windows PowerShell
    event_id: 400, 403, 600, 800
    
  - name: Microsoft-Windows-PowerShell/Operational
    event_id: 4103, 4104, 4105, 4106
    
  - name: ForwardedEvents
    tags: [forwarded]
    
setup.template.settings:
  index.number_of_shards: 1
  
output.logstash:
  hosts: ["$logstash_host"]
  
processors:
  - add_host_metadata:
      when.not.contains.tags: forwarded
"@

$outdir = "$HOME\AppData\Local\Temp"

# Downloads winlogbeat, extract and move output
Write-Output "Downloading Winlogbeat"
Invoke-WebRequest "https://artifacts.elastic.co/downloads/beats/winlogbeat/winlogbeat-oss-$version-windows-x86_64.zip" -o $outdir\winlogbeat.zip

Write-Output "Extracting Winlogbeat"
Expand-Archive -LiteralPath $outdir\winlogbeat.zip -DestinationPath "$outdir\winlogbeat-out"
Move-Item "$outdir\winlogbeat-out\winlogbeat*-windows*" "C:\Program Files\Winlogbeat"

# Clean old stuff
Write-Output "Removing downloaded/extracted files"
Remove-Item -Force $outdir\winlogbeat.zip
Remove-Item -Force -Recurse $outdir\winlogbeat-out

# Install Service
Write-Output "Installing Winlogbeat service"
Powershell.exe -ExecutionPolicy Bypass -File 'C:\Program Files\Winlogbeat\install-service-winlogbeat.ps1'

# Stop winlogbeat in case it is running
Write-Output "Stopping Winlogbeat"
Stop-Service -Name winlogbeat

# Set winlogbeat to start on boot
Write-Output "Setting Winlogbeat to start on boot"
Set-Service -Name winlogbeat -StartupType Automatic

# Inject configuration into Winlogbeat config
Write-Output "Writing Winlogbeat configuration to file"
Write-Output $winlogbeat_config > 'C:\Program Files\Winlogbeat\winlogbeat.yml'

# Restart the winlogbeat service
Write-Output "Restarting Winlogbeat"
Restart-Service -Name winlogbeat
