# Using properties inside strings
$now = get-date
$shortId = "$($now.Millisecond)$($now.Day)$($now.Month)"

# Parameters, eg .\myscript.ps1 -arg1 value1 -arg2 value2 -force
param (
  [Parameter(Mandatory=$true)]
  [string] 
  $arg1 = "defaultvalue",
  [string] $arg2 = $(throw "-arg2 is required."),
  [switch] $force #switch is a toggle, like a -force
)

# Powershell's wacky function invocation (Test-IisInstalled returns $true)
# - always use brackets
if ((Test-IisInstalled) -eq $False) # this will return false
if (Test-IisInstalled -eq $False)  # this will return true

# Equality checks, they're a bit SQLy (but based on Bash as "<" and ">" are used for piping)
if(-not $something -or $somethingElse)
}

if($anotherThing -ne "hmm" 
   -and $otherThing -eq "yep"
   -and $anumber -gt 4
   -and $number2 -lt 3)
}

# Check for null
if ($something -eq $null)
{
}

# Check an empty string, the robust way
if ([string]::IsNullOrEmpty($mystring) -eq $false)
{
}

# Write to a file without UTF-8 issues
$contents = "blah blah blha"
[System.IO.File]::WriteAllText("c:\foo.txt", $contents);

# Create a grep, e.g. dir | grep "foo"
new-alias grep Select-String 

# Restarting a service and waiting
& sc.exe stop "My service"
Sleep -Seconds 10
& sc.exe start "My service"

# Reload environmental variables (e.g. after choco install git)
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User") 

# Split a string
$branches = "item1
item2
item3"
$branchList = $branches.split("`n")

# Redirect errors
$output = git pull 2>&1

# Foreach
$trees = @("Alder","Ash","Birch","Cedar","Chestnut","Elm")
foreach ($tree in $trees)
{
  Write-host $tree
}

# List all modules exports by a module file
 get-module MyModule
 
# Sort 
get-verb | foreach { $_.Verb } | sort
dir | sort Name, Length

# A progress bar
for ($i = 1; $i -le 100; $i++ ) {write-progress -activity "Search in Progress" -status "$i% Complete:" -percentcomplete $i;}

# Get a users credentials by prompting
$creds = Get-Credential

# Get a users credentials without prompting
$username = "administrator"
$password = "MyPassword"
$securePassword = convertto-securestring -AsPlainText -Force -String $password
$creds = new-object -typename System.Management.Automation.PSCredential -argumentlist $username, $securePassword

# Enter a remote session
$ip = "10.10.1.22"
$creds = Get-Credential
Enter-PSSession -Computername $ip -Port 55985  -credential $creds

# Invoke a file and script block on a remote server
$ip = "10.10.1.22"
$creds = Get-Credential
$session = new-pssession -computername $ip -credential $creds # use  -Authentication Basic with Packer
invoke-command -Session $session -FilePath .\myscript.ps1

$someArg = "test"
invoke-command -Session $session -ScriptBlock { Do-Something $args[0] } -ArgumentList $someArg

# List all installed features (Powershell 5 or Win10/2012R2 upwards)
Get-WindowsFeature
Install-WindowsFeature -Name RSAT-DNS-Server # allow you to remotely update DNS records

# View and update DNS records
Get-DnsServerResourceRecord -RRType CName -ZoneName "mydomain.com" -ComputerName "domaincontroller.mydomain.com" | where-object { $_.HostName.Contains("SOME-HOST") }

# e.g. point docs.mydomain.com to the server 'horrible-long-name-t-123123'
Add-DnsServerResourceRecordCName -Name "docs" -HostNameAlias "horrible-long-name-t-123123.mydomain.com" -ZoneName "mydomain.com" -ComputerName "domaincontroller.mydomain.com"

# View your ip addresses
ipconfig | where {$_.Contains("IPv4") }