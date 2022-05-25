$OFS = "`r`n"
$updateLogDir = "~/.swupdates"

if (!(Test-Path -Path "$updateLogDir")) {
    New-Item -Path "$updateLogDir" -ItemType Directory
}

function SetLastRun([string]$key, [DateTime] $lastRun) {
    if (!(Test-Path -Path "$updateLogDir")) {
        New-Item -Path "$updateLogDir" -ItemType Directory
    }
    Set-Content -Path "$updateLogDir/$key" -Value $lastRun.ToString("o")
}

function GetLastRun([string]$key) {
    if (Test-Path -Path "$updateLogDir/$key") {
        $val = Get-Content -Path  "$updateLogDir/$key"
        if ($val) {
            $result = [datetime]::Parse($val)
            return $result
        }
    }
    $result = [datetime]::MinValue
    return $result
}


function Update() {
    $logFile = "$updateLogDir/scoop-update.log"
    $header = "Running update: " + $(Get-Date -format "o") + $OFS
    Add-Content -Path $logFile -Value $header
    scoop update * | Out-File -FilePath $logFile -Append -Encoding UTF8
    $finished = Get-Date
    if ($LASTEXITCODE -eq 0) {
        SetLastRun "scoop-update" $finished
        $footer = "Update finished: " + $finished.ToString("o") + $OFS
    }
    else {
        $footer = "Update failed: " + $finished.ToString("o") + $OFS
    }
    Add-Content -Path $logFile -Value $footer
}

function Clean() {
    $logFile = "$updateLogDir/scoop-clean.log"
    $header = "Running clean: " + $(Get-Date -format "o") + $OFS
    Add-Content -Path $logFile -Value $header
    scoop cleanup * --cache | Out-File -FilePath $logFile -Append -Encoding UTF8
    $finished = Get-Date
    if ($LASTEXITCODE -eq 0) {
        SetLastRun "scoop-clean" $finished
        $footer = "Clean finished: " + $finished.ToString("o") + $OFS
    }
    else {
        $footer = "Clean failed: " + $finished.ToString("o") + $OFS
    }
    Add-Content -Path $logFile -Value $footer
}

$now = Get-Date

# if no update in last week (check registry)
$lastUpdate = GetLastRun "scoop-update"
if ($lastUpdate.AddDays(6) -lt $now) {
    Update
}

# if not cleaned in last month
$lastUpdate = GetLastRun "scoop-update"
$lastClean = GetLastRun "scoop-clean"
if ($lastUpdate.AddDays(6) -gt $now) {
    if ($lastClean.AddDays(30) -lt $now) {
        Clean
    }
}
