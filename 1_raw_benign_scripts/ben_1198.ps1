# param to take in server os type
param([String]$serverOS="windows")

function getServerOS {
    $osCheck = docker version | Select-String OS/ARCH | Select-String linux

    if ($osCheck) {
        return "linux"
    }
    else {
        return "windows"
    }
}

## MAIN() ##

$currentServerOS = getServerOS

# switch to the windows server os if not already
if ($serverOS -eq "windows") {
    if ($currentServerOS -eq "linux") {
        Write-Host "Current Docker Host linux switching to windows" -ForegroundColor "yellow"

        & 'C:\Program Files\Docker\Docker\DockerCli.exe' -SwitchDaemon

        Write-Host "Docker Host is now windows" -ForegroundColor "green"
    }
    else {
        Write-Host "Docker Host is already windows" -ForegroundColor "green"
    }
}
# switch to the linux server os if not already
elseif ($serverOS -eq "linux") {
    if ($currentServerOS -eq "windows") {
        Write-Host "Current Host windows switching to linux" -ForegroundColor "yellow"

        & 'C:\Program Files\Docker\Docker\DockerCli.exe' -SwitchDaemon

        Write-Host "Docker Host is now linux" -ForegroundColor "green"
    }
    else {
        Write-Host "Host is already linux" -ForegroundColor "green"
    }
}
# unknown server type, error out
else {
    Write-Host "ERROR: unknown server OS" -ForegroundColor "red"
}