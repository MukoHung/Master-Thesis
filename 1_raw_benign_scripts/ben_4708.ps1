[CmdletBinding()]
Param()

$Function = {
  Function RunScript {
    Param(
        [Parameter(Mandatory=$True)]
        $ScriptPath,
        $Arguments
        )
    Try {
      $Error.Clear()
      If(Test-Path $ScriptPath) {
        If($Arguments) {
          $ScriptString = [ScriptBlock]::Create("$ScriptPath $Arguments")
          Invoke-Command -ScriptBlock $ScriptString
        } Else {
          & $ScriptPath
        }
      } Else {
        Write-Error "$ScriptPath was not found"
        Break
      }
    } Catch {
      $ThisError = $Error
      Write-Error "Failed to complete $ScriptPath"
      Write-Error ($ThisError | Out-String)
      Break
    }
  }
}

# The RunScript function was declared within a scriptblock above
#  so that it can be passed to a backgroun job.
#  Here we are running that script block to pull the function into
#  this particular session to it can be used locally in the script too.
. $Function

$ConfigFile = "$PSScriptRoot\Config.json"
$Config = Get-Content $ConfigFile | Out-String | ConvertFrom-JSON

$RequiredConfigKeys = @('UserNameToAddToBatchJob')
Foreach($ConfigKey in $RequiredConfigKeys) {
  If((!$Config.$ConfigKey) -Or ($Config.$ConfigKey -eq $Null)) {
    Throw "$ConfigKey is not set in the config file: $ConfigFile"
  }
}

$IncludeDir = "$PSScriptRoot\include"

# Configure SQL Server Management Studio
Write-Verbose "Configuring SQL Server Management Studio"
$SSMS_Job = Start-Job -InitializationScript $Function -ScriptBlock { RunScript $Args[0] } -ArgumentList "$IncludeDir\Get-SSMS-Installer.ps1"

# Configure RDP
Write-Verbose "Configuring RDP"
RunScript "$IncludeDir\Configure-RDP.ps1"

# Configure E: Drive
Write-Verbose "Configuring E Drive"
RunScript "$IncludeDir\Configure-WSUSServerDrives.ps1"

# We don't want to continue with any more configuration until the E: drive is accessible. So we'll loop until we can access it.
$i = 0
While( !(Test-Path "E:\") ) {
  Write-Verbose "Waiting for E Drive configuration to complete"
  If($i -gt 10) {
    Write-Verbose "You may need to check for a minimized Disk Management window..."
  }
  Sleep 15
  $i++
}

# Configure WSUS Windows Features
Write-Verbose "Configuring WSUS Windows Features"
RunScript "$IncludeDir\Configure-WSUSWindowsFeatures.ps1"

# Add Server to Domain
Write-Verbose "Adding server to domain"
RunScript "$IncludeDir\WSUS_Domain.bat"

# Add WSUS Service Account to run Batch Job
Write-Verbose "Adding WSUS Service account to run batch jobs"
If($UsertoAdd = $Config.UserNameToAddToBatchJob) {
  RunScript "$IncludeDir\AddUserToBatchJob.ps1" -Arguments '-UserToAdd', $UsertoAdd
} Else {
  Write-Verbose "[SKIPPED]: No username configured to be added to batch job. Skipping this step."
}

# Add WSUS Service Account to local WSUS Reporters and WSUS Administrators groups
Write-Verbose "Adding WSUS Service account to local WSUS Reporters and WSUS Administrators groups"
RunScript "$IncludeDir\WSUS-AddWSUSAdmin.ps1"

# Setup Scripts Directory
If(! (Test-Path "$env:SystemDrive\Scripts") ) {
  # Create the scripts directory
  Write-Verbose "Creating scripts directory"
  New-Item -Path "$env:SystemDrive" -Name 'Scripts' -ItemType 'Directory'
} Else {
  Write-Verbose "Scripts directory already exists"
  # Scripts directory already exists
}

If(Test-Path "$env:SystemDrive\Scripts") {
  Write-Verbose "Copying maintenance utilities to Scripts directory"
  Copy-Item "$IncludeDir\maintenance_utils\*" "$env:SystemDrive\Scripts" -Recurse -Force
} Else {
  Write-Error "Scripts directory does not exist. Cannot copy over maintenance utilities."
}

# Create Scheduled Task for WSUS - Reboot RestartPending Computers
Write-Verbose "Creating Scheduled Task: 'WSUS - Reboot RestartPending Computers'"
RunScript "$IncludeDir\Configure-WSUSRebootRestartPendingTask.ps1"

# Waiting for the SQL Server Management Studio job to complete
Write-Verbose "Waiting for the SQL Server Management Studio job to complete."
$SSMS_Job_Result = Wait-Job $SSMS_Job | Receive-Job

If( ($SSMS_Job | Get-Job).State -eq 'Completed' ) {
  RunScript "$IncludeDir\Configure-SSMS.ps1"
} Else {
  Write-Verbose "The SQL Server Management Studio installer did not download properly"
  Throw "SSMS did not install properly. Cannot run WSUS-AutomatedMaintenance without it."
}

# Run WSUS-AutomatedMaintenance -FirstRun
If(Test-Path "$env:SystemDrive\Scripts\WSUS-AutomatedMaintenance.ps1") {
  Try {
    $SQLCmd = Invoke-Command -ScriptBlock { sqlcmd /? }
    If($SQLCmd) {
      RunScript "$env:SystemDrive\Scripts\WSUS-AutomatedMaintenance.ps1" -Arguments '-FirstRun'
    } Else {
      Throw "sqlcmd did not install properly. Cannot run WSUS-AutomatedMaintenance without it."
    }
  } Catch {
    Write-Error "The installation did not complete properly. 'sqlcmd.exe /?' does not run."
  }
} Else {
  Write-Error "Scripts directory does not exist. Cannot run WSUS-AutomatedMaintenance.ps1"
}

# Pin items to taskbar
Write-Verbose "Pinning WSUS Console to taskbar"
RunScript "$IncludeDir\Set-TaskBarItems.ps1"

# Check for Windows Updates
Write-Verbose "Checking for available Windows Updates"
RunScript "$IncludeDir\Get-WindowsUpdates.ps1"


# Set upstream server
Write-Verbose "Checking if upstream server needs to be set"
RunScript "$IncludeDir\Configure-WSUSUpstream.ps1"

