cd C:\PShell\Labs\Lab05

# Find and review resource code
# =============================
Get-DscResource
Get-DscResource -Module PSDesiredStateConfiguration

Get-Module -Name PSDesiredStateConfiguration | fl *
dir (Get-Module -Name PSDesiredStateConfiguration).ModuleBase
dir (Join-Path (Get-Module -Name PSDesiredStateConfiguration).ModuleBase 'DSCResources')

Get-DscResource Registry | fl *
dir (Get-DscResource Registry).ParentPath
psedit (Get-DscResource Registry).Path

Find-DscResource | select -First 1 | fl *

# Install module/resource
# =======================
# First save to review code for safety
Save-Module -name xnetworking -Path .\
dir .\xNetworking -Recurse


Install-Module xNetworking -Force
Install-Module xSmbShare -Force

Get-DscResource

# Use resources example
# =====================
.\Lab_05_01_03_Configuration_Solution.ps1


# Push Modules / Mof to node
# ==========================
# Node is set to pull mode, change this to push mode
# --------------
Get-DscLocalConfigurationManager -CimSession ms1
# psedit .\Lab_05_02_01_LCM_Push.ps1
.\Lab_05_02_01_LCM_Push.ps1
Get-DscLocalConfigurationManager -CimSession ms1

# Node doesn't have special modules yet, copy these over
# -------------
$Source = 'C:\Program Files\WindowsPowerShell\Modules\[xc]*'
$Dest   = 'C:\Program Files\WindowsPowerShell\Modules\'
$pss = New-PSSession ms1
Copy-Item -Path $Source -ToSession $pss -Destination $Dest -Recurse -Force -Verbose

# Push new config to ms1
Start-DscConfiguration -Path .\FileServer -Wait -Verbose -Force

# Test
Test-DscConfiguration -CimSession ms1

# ====

get-command Start-DscConfiguration -Syntax
Start-DscConfiguration -Wait -Verbose -Force -UseExisting


# Register modules for pull
# =========================
$PullModulePath = "$Env:PROGRAMFILES\WindowsPowerShell\DscService\Modules"
dir $PullModulePath

. .\Lab_05_03_01_Publish_Modules_Function.ps1
Publish-DscResourcePull -Module xSmbShare
Publish-DscResourcePull -Module xNetworking

dir $PullModulePath


# Try the same as before, but without imperatively puhsing the modules
# =========================

#psedit .\Lab_05_03_02a_Configuration.ps1
#psedit .\Lab_05_03_02b_Staging.ps1


.\Lab_05_03_02a_Configuration.ps1  # create mof for ms2
.\Lab_05_03_02b_Staging.ps1 # rename to guid

. .\Lab_05_03_03_LCM_Pull.ps1 
LCMPull -GUID "f4d53552-cf39-4e80-bd91-068b27ba7ca7" # create lcm config and refer to the mof file generated earlier via the guid

# Apply
Set-DscLocalConfigurationManager -Path .\LCMPull -Verbose

# Check if the modules are on ms2 at the moment
# =============================================
$ModulesPath = "$Env:PROGRAMFILES\WindowsPowerShell\Modules\[xc]*"
Invoke-Command -ComputerName ms2 -ScriptBlock {dir $using:ModulesPath}

# Force immediate update
Update-DscConfiguration -CimSession ms2 -Wait -Verbose

$ModulesPath = "$Env:PROGRAMFILES\WindowsPowerShell\Modules\[xc]*"
Invoke-Command -ComputerName ms2 -ScriptBlock {dir $using:ModulesPath}