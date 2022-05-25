# Deploy and install Windows Service for NServiceBus host

# Get parameters from Octopus
$serviceName = $OctopusParameters['service.name']
$serviceDisplayName = $OctopusParameters['service.display_name']
$serviceBusProfile = $OctopusParameters['service.profile']
$installDirectory = $OctopusActionPackageCustomInstallationDirectory

# Check to see if the service exists.
$fullPath = Resolve-Path "$installDirectory\NServiceBus.Host.exe"

Write-Host "Installing service => $($serviceName)"
  & "$fullPath" /install /serviceName:"$serviceName" /displayName:$serviceDisplayName $serviceBusProfile | Write-Host

# Try and start the service by name
try {
    Write-Host "Starting service => $($serviceName)"
    Start-Service $serviceName
} catch {
    Write-Host "$($_.Exception.Message)"  -ForegroundColor Red
    Write-Host "$($_.InvocationInfo.PositionMessage)" -ForegroundColor Red
    exit 1
}