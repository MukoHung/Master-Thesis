Set-StrictMode -Off

# SHOW
Set-Alias show Get-ChildItem

# ALIASES FOR ANDROID DEVELOPMENT ENVIRONMENT
Set-Alias env-android (Resolve-Path "$env:powershell\AndroidEnvironment.ps1")
Set-Alias env-and (Resolve-Path "$env:powershell\AndroidEnvironment.ps1")
Set-Alias env-a (Resolve-Path "$env:powershell\AndroidEnvironment.ps1")

# ALIASES FOR NODE DEVELOPMENT ENVIRONMENT
Set-Alias env-node (Resolve-Path "$env:powershell\NodeEnvironment.ps1")
Set-Alias env-n (Resolve-Path "$env:powershell\NodeEnvironment.ps1")

#VISUAL STUDIO
# C:\Program Files (x86)\Windows Kits\8.1\Windows Performance Toolkit\;

#SQL ENVIRONMENT V9
# c:\Program Files (x86)\Microsoft SQL Server\90\Tools\binn\;
#SQL ENVIRONMENT V10
# c:\Program Files\Microsoft SQL Server\100\Tools\Binn\;
# c:\Program Files (x86)\Microsoft SQL Server\100\DTS\Binn\;
# c:\Program Files (x86)\Microsoft SQL Server\100\Tools\Binn\;
# c:\Program Files (x86)\Microsoft SQL Server\100\Tools\Binn\VSShell\Common7\IDE\;
#SQL ENVIRONMENT V11
# C:\Program Files\Microsoft SQL Server\110\Tools\Binn\;
#SQL ENVIRONMENT V12
# C:\Program Files\Microsoft SQL Server\120\Tools\Binn\;

# LOCAL VARIABLES
# $msBuildPath = "$env:SystemRoot\Microsoft.NET\Framework\v4.0.30319"
# $basePath = "d:\bin;$env:SystemRoot\System32;C:\ProgramData\chocolatey\bin;$msbuildPath;$env:SystemRoot\syswow64\WindowsPowerShell\v1.0\;C:\Program Files\dotnet"

# ENVIRONMENT VARIABLES
# $env:HOME = $HOME
# $env:TMP = $env:TEMP = [system.io.path]::gettemppath()
# $env:PYTHON = "C:\Python27"

# SET PATH
# $env:PATH = "$basePath;$env:PSModulePath;$env:PYTHON;"

# SETUP ENVIRONMENTS
. (Resolve-Path "$env:powershell\GitEnvironment.ps1")
. (Resolve-Path "$env:powershell\NodeEnvironment.ps1")
# . (Resolve-Path "$env:powershell\AndroidEnvironment.ps1")
# . (Resolve-Path "$env:powershell\RustEnvironment.ps1")

# COLORIZE OUTPUT
. (Resolve-Path "$env:powershell\ColorOutput.ps1")
