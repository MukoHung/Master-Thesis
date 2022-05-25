Add-Type -AssemblyName System.IO.Compression.FileSystem

Write-Host "Location: $PSScriptRoot"
Write-Host "Username: $env:UserName"
Set-Location $PSScriptRoot

$dataDir = "./mouse_manager_data"

# Get the ID and security principal of the current user account
$myWindowsID=[System.Security.Principal.WindowsIdentity]::GetCurrent()
$myWindowsPrincipal=New-Object System.Security.Principal.WindowsPrincipal($myWindowsID)

# Get the security principal for the Administrator role
$adminRole=[System.Security.Principal.WindowsBuiltInRole]::Administrator

# Check to see if we are currently running "as Administrator"
if ($myWindowsPrincipal.IsInRole($adminRole)) {
    $Host.UI.RawUI.WindowTitle = $myInvocation.MyCommand.Definition + " (Administrator)"
    $Host.UI.RawUI.BackgroundColor = "DarkRed"

    $checkWorkDir = Test-Path -Path $dataDir
    if (-Not $checkWorkDir) {
        Write-Host "Run this script from normal user before!"
        Write-Host -NoNewLine "Press any key to exit..."
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        exit
    }
    Clear-Host
} else {
    $checkWorkDir = Test-Path -Path $dataDir;

    Write-Host
    Write-Host "Creating working directory..."
    if(-Not $checkWorkDir){
        New-Item -ItemType directory -Path $dataDir | Out-Null
        Write-Host "Created!"
    } else {
        Write-Host "Already created!"
    }

    $checkPSTools = Test-Path "$dataDir/PSTools.zip"

    Write-Host
    Write-Host "Downloading PSTools..."
    if (-Not $checkPSTools) {
        Invoke-WebRequest "https://download.sysinternals.com/files/PSTools.zip" -UseBasicParsing -OutFile "$dataDir/PSTools.zip"
        Write-Host "Successfully downloaded!"
    } else {
        Write-Host "Already downloaded!"
    }

    $checkPsExec = Test-Path "$dataDir/PsExec.exe"

    Write-Host
    Write-Host "Extracting PsExec..."
    if (-Not $checkPsExec) {
        $zip = [IO.Compression.ZipFile]::OpenRead("$dataDir/PSTools.zip")
        $zip.Entries | Where-Object {$_.Name -like 'PsExec.exe'} | ForEach-Object {[System.IO.Compression.ZipFileExtensions]::ExtractToFile($_, "$dataDir/PsExec.exe", $true)}
        $zip.Dispose()
        Write-Host "Successfully extracted!"
    } else {
        Write-Host "Already extracted!"
    }

    $checkBackups = Test-Path "$dataDir/backups"

    Write-Host
    Write-Host "Backing up registry before doing anything..."
    if (-Not $checkBackups) {
        New-Item -ItemType Directory -Path "$dataDir/backups" | Out-Null
        reg.exe export "HKLM\SYSTEM\CurrentControlSet\Enum\HID" "$dataDir/backups/HID.reg"
        reg.exe export "HKLM\SYSTEM\CurrentControlSet\Enum\USB" "$dataDir/backups/USB.reg"
        Write-Host "Registry backed up to $([IO.Path]::GetFullPath((Join-Path $PSScriptRoot $dataDir)))"
    } else {
        Write-Host "Already backed up!"
    }

    Write-Host
    Write-Host "Selecting mouse..."

    $devices = Get-WmiObject -Class Win32_PointingDevice # getting mises like device manager
    $devices | Format-Table -Property Description,DeviceID
    $numOfDevices = @($devices).Length;

    if ($numOfDevices -lt 1) {
        Write-Host "Mouse not found!"
        Write-Host -NoNewLine "Press any key to exit..."
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        exit
    }

    $checkVIDPID = Test-Path "$dataDir/vidpid.txt"
    if (-Not $checkVIDPID) {

        do {
            $choice = Read-Host -Prompt "select from 1 to $numOfDevices"
        } while (($choice -lt 1) -or ($choice -gt $numOfDevices))
        if ($numOfDevices -gt 1) { # obtaining raw VID & PID
            $rawVIDPID = ($devices | Select-Object -ExpandProperty "DeviceID")[$choice - 1]
        } else {
            $rawVIDPID = $devices | Select-Object -ExpandProperty "DeviceID"
        }

        $rawVIDPID -match "(?<=\\)(.*?)(?=&)" | Out-Null # getting VID
        $VIDPID += $Matches.1
        $VIDPID += "&"
        $rawVIDPID -match "(?<=&)(.*?)(?=&)" | Out-Null # getting PID
        $VIDPID += $Matches.1

        Write-Host "Mouse with ID $VIDPID remembered. Just delete $([IO.Path]::GetFullPath((Join-Path $PSScriptRoot "$dataDir/vidpid.txt"))) to reselect."
        $VIDPID > "$dataDir/vidpid.txt" # saving VID & PID
    } else {
        Write-Host "ID already stored in $([IO.Path]::GetFullPath((Join-Path $PSScriptRoot "$dataDir/vidpid.txt")))!"
    }

    if ($checkWorkDir -and $checkPSTools -and $checkPsExec -and $checkBackups -and $checkVIDPID) {
        Write-Host "Ready to purge!"
    } else {
        $choices  = '&Yes', '&No'
        $decision = $Host.UI.PromptForChoice("Next step will remove some Registry paths.", "Are you sure you want to proceed?", $choices, 1)
        if ($decision -ne 0) { exit }
    }

    # Create a new process object that starts PowerShell through PsExec.exe
    $run = "powershell $PSScriptRoot\mouse_manager.ps1"
    $newProcess = New-Object System.Diagnostics.ProcessStartInfo([IO.Path]::GetFullPath((Join-Path $PSScriptRoot "$dataDir/PsExec.exe")), "-s -i -nobanner -accepteula $run");

    $newProcess.CreateNoWindow = $true

    # Indicate that the process should be elevated
    $newProcess.Verb = "runas";

    # Start the new process
    [System.Diagnostics.Process]::Start($newProcess);

    Start-Sleep 5
    # Exit from the current, unelevated, process
    exit
}

# Run code that needs to be elevated here
$rawVIDPID = Get-Content -Path "$dataDir/vidpid.txt"
Write-Host "Purging $rawVIDPID in"
for ($i = 3; $i -gt 0; $i--) {
    Write-Host -NoNewline "$i "
    Start-Sleep 1
}
Write-Host

$USBs = (Get-ChildItem 'HKLM:\SYSTEM\CurrentControlSet\Enum\USB').Name # getting USB records
$HIDs = (Get-ChildItem 'HKLM:\SYSTEM\CurrentControlSet\Enum\HID').Name # getting HID records

$pathsToDelete = ($HIDs + $USBs) | Where-Object {$_ -like "*$rawVIDPID*"}
$pathsToDelete | ForEach-Object {
    reg.exe delete "$_" /f
}

Write-Host "All done! Starting Rust..."
for ($i = 3; $i -gt 0; $i--) {
    Write-Host -NoNewline "$i "
    Start-Sleep 1
}
Start-Process "steam://rungameid/252490"
Start-Sleep 5
