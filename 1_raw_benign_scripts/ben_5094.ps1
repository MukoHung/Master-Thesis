 # Get the ID and security principal of the current user account
 $myWindowsID=[System.Security.Principal.WindowsIdentity]::GetCurrent()
 $myWindowsPrincipal=new-object System.Security.Principal.WindowsPrincipal($myWindowsID)
  
 # Get the security principal for the Administrator role
 $adminRole=[System.Security.Principal.WindowsBuiltInRole]::Administrator
  
 # Check to see if we are currently running "as Administrator"
 if ($myWindowsPrincipal.IsInRole($adminRole)) {
    # We are running "as Administrator" - change the title to indicate this
    $Host.UI.RawUI.WindowTitle = $myInvocation.MyCommand.Definition + "(Elevated)"
    clear-host
 } else {
    # We are not running "as Administrator" - so relaunch as administrator
    
    # Create a new process object that starts PowerShell
    $newProcess = new-object System.Diagnostics.ProcessStartInfo "PowerShell";
    
    # Specify the current script path and name as a parameter
    $newProcess.Arguments = $myInvocation.MyCommand.Definition;
    
    # Indicate that the process should be elevated
    $newProcess.Verb = "runas";
    
    # Start the new process
    [System.Diagnostics.Process]::Start($newProcess);
    
    # Exit from the current, unelevated, process
    exit
}
  

function Install-With-Winget {
    # winget downloads and installs even if a package is already installed,
    # so check first. Also, winget can only install one program per invocation.
    foreach ($pkg in $args) {
        winget list --accept-source-agreements --exact -q $pkg | Out-Null
        if ($?) {
            Write-Host "Already installed (winget): $pkg"
        } else {
            Write-Host "Installing (winget): $pkg"
            winget install --exact --silent  --accept-package-agreements $pkg 
        }
    }
}

function Install-With-Choco {
    # Chocolatey prints annoying warnings if pkg already installed.
    $installed = (choco list --local --idonly --limitoutput)
    [array]$needed = $args | Where-Object { $_ -notin  $installed}
    [array]$notNeeded = $args | Where-Object { $_ -notin $needed}
    Write-Host "Already installed (choco): $notNeeded"
    if ($needed.Count -ne 0) {
        Write-Host "Installing (choco): $needed"
        choco install @needed -y --limitoutput
    }
}


# Install chocolatey.
Set-ExecutionPolicy Bypass -Scope Process -Force;
if (-not (Get-Command "choco.exe" -ErrorAction SilentlyContinue)) {
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072;
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
}
# We use chocolatey by preference, but resort to winget if a package is
# available only there, or is kept more up to date there, or if it's
# a Microsoft tool.

Install-With-Choco git cascadia-code-nerd-font gsudo keepass keepass-plugin-keeanywhere keepass-plugin-keepassotp npiperelay
Install-With-Winget JanDeDobbeleer.OhMyPosh Microsoft.PowerShell Microsoft.WindowsTerminal Microsoft.OneDrive

# Also needed: KeeAgent plugin

Read-Host "Press ENTER to continue"
