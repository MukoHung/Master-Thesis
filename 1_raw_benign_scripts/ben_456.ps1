# Windows AMIs don't have WinRM enabled by default -- this script will enable WinRM
# AND install the CloudInit.NET service, 7-zip, curl and .NET 4 if its missing.
# Then use the EC2 tools to create a new AMI from the result, and you have a system 
# that will execute user-data as a PowerShell script after the instance fires up!
# This has been tested on Windows 2008 R2 Core x64 and Windows 2008 SP2 x86 AMIs provided
# by Amazon
# 
# To run the script, open up a PowerShell prompt as admin
# PS> Set-ExecutionPolicy Unrestricted
# PS> icm $executioncontext.InvokeCommand.NewScriptBlock((New-Object Net.WebClient).DownloadString('https://raw.github.com/gist/1672426/Bootstrap-EC2-Windows-CloudInit.ps1'))
# Alternatively pass the new admin password and encryption password in the argument list (in that order)
# PS> icm $executioncontext.InvokeCommand.NewScriptBlock((New-Object Net.WebClient).DownloadString('https://raw.github.com/gist/1672426/Bootstrap-EC2-Windows-CloudInit.ps1')) -ArgumentList "adminPassword cloudIntEncryptionPassword"
# The script will prompt for a a new admin password and CloudInit password to use for encryption
param(
	[Parameter(Mandatory=$true)]
	[string]
	$AdminPassword,

	[Parameter(Mandatory=$true)]
	[string]
	$CloudInitEncryptionPassword
)

Start-Transcript -Path 'c:\bootstrap-transcript.txt' -Force
Set-StrictMode -Version Latest
Set-ExecutionPolicy Unrestricted

$log = 'c:\Bootstrap.txt'

while (($AdminPassword -eq $null) -or ($AdminPassword -eq ''))
{
	$AdminPassword = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR((Read-Host "Enter a non-null / non-empty Administrator password" -AsSecureString)))
}

while (($CloudInitEncryptionPassword -eq $null) -or ($CloudInitEncryptionPassword -eq ''))
{
	$CloudInitEncryptionPassword= [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR((Read-Host "Enter a non-null / non-empty password to use for encrypting CloudInit.NET scripts" -AsSecureString)))
}

Import-Module BitsTransfer

$systemPath = [Environment]::GetFolderPath([Environment+SpecialFolder]::System)
$sysNative = [IO.Path]::Combine($env:windir, "sysnative")
#http://blogs.msdn.com/b/david.wang/archive/2006/03/26/howto-detect-process-bitness.aspx
$Is32Bit = (($Env:PROCESSOR_ARCHITECTURE -eq 'x86') -and ($Env:PROCESSOR_ARCHITEW6432 -eq $null))
Add-Content $log -value "Is 32-bit [$Is32Bit]"

#http://msdn.microsoft.com/en-us/library/ms724358.aspx
$coreEditions = @(0x0c,0x27,0x0e,0x29,0x2a,0x0d,0x28,0x1d)
$IsCore = $coreEditions -contains (Get-WmiObject -Query "Select OperatingSystemSKU from Win32_OperatingSystem" | Select -ExpandProperty OperatingSystemSKU)
Add-Content $log -value "Is Core [$IsCore]"

cd $Env:USERPROFILE

#change admin password
net user Administrator $AdminPassword
Add-Content $log -value "Changed Administrator password"

#.net 4
if ((Test-Path "${Env:windir}\Microsoft.NET\Framework\v4.0.30319") -eq $false)
{
    $netUrl = if ($IsCore) {'http://download.microsoft.com/download/3/6/1/361DAE4E-E5B9-4824-B47F-6421A6C59227/dotNetFx40_Full_x86_x64_SC.exe' } `
    else { 'http://download.microsoft.com/download/9/5/A/95A9616B-7A37-4AF6-BC36-D6EA96C8DAAE/dotNetFx40_Full_x86_x64.exe' }

    Start-BitsTransfer $netUrl dotNetFx40_Full.exe
    Start-Process -FilePath 'dotNetFx40_Full.exe' -ArgumentList '/norestart /q  /ChainingPackage ADMINDEPLOYMENT' -Wait -NoNewWindow
    del dotNetFx40_Full.exe
    Add-Content $log -value "Found that .NET4 was not installed and downloaded / installed"
}

#configure powershell to use .net 4
$config = @'
<?xml version="1.0" encoding="utf-8" ?>
<configuration>
  <!-- http://msdn.microsoft.com/en-us/library/w4atty68.aspx -->
  <startup useLegacyV2RuntimeActivationPolicy="true">
    <supportedRuntime version="v4.0" />
    <supportedRuntime version="v2.0.50727" />
  </startup>
</configuration>
'@

if (Test-Path "${Env:windir}\SysWOW64\WindowsPowerShell\v1.0\powershell.exe")
{
    $config | Set-Content "${Env:windir}\SysWOW64\WindowsPowerShell\v1.0\powershell.exe.config"
    Add-Content $log -value "Configured 32-bit Powershell on x64 OS to use .NET 4"
}
if (Test-Path "${Env:windir}\system32\WindowsPowerShell\v1.0\powershell.exe")
{
    $config | Set-Content "${Env:windir}\system32\WindowsPowerShell\v1.0\powershell.exe.config"
    Add-Content $log -value "Configured host OS specific Powershell at ${Env:windir}\system32\ to use .NET 4"
}

#winrm
if ($Is32Bit)
{
    #this really only applies to oses older than 2008 SP2 or 2008 R2 or Win7
    #this uri is Windows 2008 x86 - powershell 2.0 and winrm 2.0
    #Start-BitsTransfer 'http://www.microsoft.com/downloads/info.aspx?na=41&srcfamilyid=863e7d01-fb1b-4d3e-b07d-766a0a2def0b&srcdisplaylang=en&u=http%3a%2f%2fdownload.microsoft.com%2fdownload%2fF%2f9%2fE%2fF9EF6ACB-2BA8-4845-9C10-85FC4A69B207%2fWindows6.0-KB968930-x86.msu' Windows6.0-KB968930-x86.msu 
    #Start-Process -FilePath "wusa.exe" -ArgumentList 'Windows6.0-KB968930-x86.msu /norestart /quiet' -Wait
    #Add-Content $log -value ""
}

#check winrm id, if it's not valid and LocalAccountTokenFilterPolicy isn't established, do it
$id = &winrm id
if (($id -eq $null) -and (Get-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System -name LocalAccountTokenFilterPolicy -ErrorAction SilentlyContinue) -eq $null)
{
    New-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System -name LocalAccountTokenFilterPolicy -value 1 -propertyType dword
    Add-Content $log -value "Added LocalAccountTokenFilterPolicy since winrm id could not be executed"
}

#enable powershell servermanager cmdlets (only for 2008 r2 + above)
if ($IsCore)
{
    DISM /Online /Enable-Feature /FeatureName:MicrosoftWindowsPowerShell /FeatureName:ServerManager-PSH-Cmdlets /FeatureName:BestPractices-PSH-Cmdlets
    Add-Content $log -value "Enabled ServerManager and BestPractices Cmdlets"

    #enable .NET flavors - on server core only -- errors on regular 2008
    DISM /Online /Enable-Feature /FeatureName:NetFx2-ServerCore /FeatureName:NetFx2-ServerCore-WOW64 /FeatureName:NetFx3-ServerCore /FeatureName:NetFx3-ServerCore-WOW64
    Add-Content $log -value "Enabled .NET frameworks 2 and 3 for x86 and x64"
}

#7zip
$7zUri = if ($Is32Bit) { 'http://sourceforge.net/projects/sevenzip/files/7-Zip/9.22/7z922.msi/download' } `
    else { 'http://sourceforge.net/projects/sevenzip/files/7-Zip/9.22/7z922-x64.msi/download' }

Start-BitsTransfer $7zUri 7z922.msi
Start-Process -FilePath "msiexec.exe" -ArgumentList '/i 7z922.msi /norestart /q INSTALLDIR="c:\program files\7-zip"' -Wait
SetX Path "${Env:Path};C:\Program Files\7-zip" /m
$Env:Path += ';C:\Program Files\7-Zip'
del 7z922.msi
Add-Content $log -value "Installed 7-zip from $7zUri and updated path"

#vc 2010 redstributable
$vcredist = if ($Is32Bit) { 'http://download.microsoft.com/download/5/B/C/5BC5DBB3-652D-4DCE-B14A-475AB85EEF6E/vcredist_x86.exe'} `
    else { 'http://download.microsoft.com/download/3/2/2/3224B87F-CFA0-4E70-BDA3-3DE650EFEBA5/vcredist_x64.exe' }

Start-BitsTransfer $vcredist 'vcredist.exe'
Start-Process -FilePath 'vcredist.exe' -ArgumentList '/norestart /q' -Wait
del vcredist.exe
Add-Content $log -value "Installed VC++ 2010 Redistributable from $vcredist and updated path"

#vc 2008 redstributable
$vcredist = if ($Is32Bit) { 'http://download.microsoft.com/download/d/d/9/dd9a82d0-52ef-40db-8dab-795376989c03/vcredist_x86.exe'} `
    else { 'http://download.microsoft.com/download/d/2/4/d242c3fb-da5a-4542-ad66-f9661d0a8d19/vcredist_x64.exe' }

Start-BitsTransfer $vcredist 'vcredist.exe'
Start-Process -FilePath 'vcredist.exe' -ArgumentList '/norestart /q' -Wait
del vcredist.exe
Add-Content $log -value "Installed VC++ 2008 Redistributable from $vcredist and updated path"

#curl
$curlUri = if ($Is32Bit) { 'http://www.paehl.com/open_source/?download=curl_724_0_ssl.zip' } `
    else { 'http://curl.haxx.se/download/curl-7.23.1-win64-ssl-sspi.zip' }
Start-BitsTransfer $curlUri curl.zip
&7z e curl.zip `-o`"c:\program files\curl`"
if ($Is32Bit) 
{
    Start-BitsTransfer 'http://www.paehl.com/open_source/?download=libssl.zip' libssl.zip
    &7z e libssl.zip `-o`"c:\program files\curl`"
    del libssl.zip
}
SetX Path "${Env:Path};C:\Program Files\Curl" /m
$Env:Path += ';C:\Program Files\Curl'
del curl.zip
Add-Content $log -value "Installed Curl from $curlUri and updated path"

#vim
curl -# -G -k -L ftp://ftp.vim.org/pub/vim/pc/vim73_46rt.zip -o vim73_46rt.zip 2>&1 > "$log"
curl -# -G -k -L ftp://ftp.vim.org/pub/vim/pc/vim73_46w32.zip -o vim73_46w32.zip 2>&1 > "$log"
Get-ChildItem -Filter vim73*.zip | 
    % { &7z x `"$($_.FullName)`"; del $_.FullName; }

SetX Path "${Env:Path};C:\Program Files\Vim" /m
$Env:Path += ';C:\Program Files\Vim'

Move-Item .\vim\vim73 -Destination "${Env:ProgramFiles}\Vim"
Add-Content $log -value "Installed Vim text editor and updated path"

#cloudinit.net
curl http://cloudinitnet.codeplex.com/releases/83697/download/351123 `-L `-d `'`' `-o cloudinit.zip
&7z e cloudinit.zip `-o`"c:\program files\CloudInit.NET`"
del cloudinit.zip
Add-Content $log -value 'Downloaded / extracted CloudInit.NET'

$configFile = 'c:\program files\cloudinit.net\install-service.ps1'
(Get-Content $configFile) | % { $_ -replace "3e3e2d3848336b7d3b547b2b55",$CloudInitEncryptionPassword } | Set-Content $configFile
cd 'c:\program files\cloudinit.net'
. .\install.ps1
Start-Service CloudInit
Add-Content $log -value "Updated config file with CloudInit encryption password and ran installation scrpit"

#chocolatey - standard one line installer doesn't work on Core b/c Shell.Application can't unzip
if (-not $IsCore)
{
    Invoke-Expression ((new-object net.webclient).DownloadString('http://bit.ly/psChocInstall'))
}
else
{
    $tempDir = Join-Path $env:TEMP "chocInstall"
    if (![System.IO.Directory]::Exists($tempDir)) {[System.IO.Directory]::CreateDirectory($tempDir)}
    $file = Join-Path $tempDir "chocolatey.zip"
    (new-object System.Net.WebClient).DownloadFile("http://chocolatey.org/api/v1/package/chocolatey", $file)

    &7z x $file `-o`"$tempDir`"
    Add-Content $log -value 'Extracted Chocolatey'
    $chocInstallPS1 = Join-Path (Join-Path $tempDir 'tools') 'chocolateyInstall.ps1'

    & $chocInstallPS1

    Add-Content $log -value 'Installed Chocolatey / Verifying Paths'
    [Environment]::SetEnvironmentVariable('ChocolateyInstall', 'c:\nuget', [System.EnvironmentVariableTarget]::User)

    if ($($env:Path).ToLower().Contains('c:\nuget\bin') -eq $false) {
      $env:Path = [Environment]::GetEnvironmentVariable('Path', [System.EnvironmentVariableTarget]::Machine);
    }


    Import-Module -Name 'c:\nuget\chocolateyInstall\helpers\chocolateyinstaller.psm1'
    & C:\NuGet\chocolateyInstall\chocolatey.ps1 update
    Add-Content $log -value 'Updated chocolatey to the latest version'

   [Environment]::SetEnvironmentVariable('Chocolatey_Bin_Root', '\tools', 'Machine')
   $Env:Chocolatey_bin_root = '\tools'
}

Add-Content $log -value "Installed Chocolatey"

#this script will be fired off after the reboot
#http://www.codeproject.com/Articles/223002/Reboot-and-Resume-PowerShell-Script
@'
$log = 'c:\Bootstrap.txt'
$systemPath = [Environment]::GetFolderPath([Environment+SpecialFolder]::System)
Remove-ItemProperty -path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run -name 'Restart-And-Resume'

&winrm quickconfig `-q
Add-Content $log -value "Ran quickconfig for winrm"

#run SMRemoting script to enable event log management, etc - available only on R2
$remotingScript = [IO.Path]::Combine($systemPath, 'Configure-SMRemoting.ps1')
if (-not (Test-Path $remotingScript)) { $remotingScript = [IO.Path]::Combine($sysNative, 'Configure-SMRemoting.ps1') }
Add-Content $log -value "Found Remoting Script: [$(Test-Path $remotingScript)] at $remotingScript"
if (Test-Path $remotingScript)
{
    . $remotingScript -force -enable
    Add-Content $log -value 'Ran Configure-SMRemoting.ps1'
}

#wait 15 seconds for CloudInit Service to start / fail
Start-Sleep -m 15000

#clear event log and any cloudinit logs
wevtutil el | % {Write-Host "Clearing $_"; wevtutil cl "$_"}
del 'c:\cloudinit.log' -ErrorAction SilentlyContinue
del 'c:\afterRebootScript.ps1' -ErrorAction SilentlyContinue
'@ | Set-Content 'c:\afterRebootScript.ps1'

Set-ItemProperty -path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run -name 'Restart-And-Resume' `
    -value "$(Join-Path $env:windir 'system32\WindowsPowerShell\v1.0\powershell.exe') c:\afterRebootScript.ps1"

Write-Host "Press any key to reboot and finish image configuration"
[void]$host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')

Restart-Computer