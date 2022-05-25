#Reminder to Set-ExecutionPolicy to unrestricted
#For the Teacher grading this
#This is Powershell, a scripting and coding language developed by Microsoft.


#Imports


#This is an import created by Michal Gajda used to update windows. It is free to use.
Install-module PSWindowsUpdate

#These next imports are used in the RnFrstPs script and are more like full programs than imports.
#Both must be installed and cannot be installed in the same shell they're used; the script will just fail when using
#commands from these programs unless installed in a past shell.

#The first is chocolatey, an open source package manager by Rob Reynolds. This installer code is on their website
#Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

#The second is Remote Server Administration Tools, a Microsoft created windows management utility. I got the code to install it from Nilesh Kamble in the youtube video
#https://www.youtube.com/watch?v=q7bo2u8yrzI
#As a note I don't actually end up using RSAT in this version of the script, so I probably don't have to credit it for this project.
#Get-WindowsCapability -Name RSAT* -Online | Add-WindowsCapability -Online

#Code to be fixed later or is removed
<#This creates a baseline for how to view the different processes and allows us to easily search through them
get-process | Export-Clixml c:\baseline.xml
The next line actually compares the baseline created named baseline.xml

compare-Object -ReferenceObject (Import-Clixml C:\baseline.xml) -DifferenceObject (get-process) -property Name

What's your home directory This was removed as the mode directory is a global powershell variable
$home = Read-Host -Prompt 'What is your home directory?'

#>



#Powershell password settings
$data = Get-LocalUser | Select-Object name
For ($i = 0; $i -lt $data.Count; $i++)
    {Set-LocalUser -Name $data[$i].Name -AccountNeverExpires  -PasswordNeverExpires 0 -Password (ConvertTo-SecureString -AsPlainText "Netlab123@Pogchamp" -Force)}

#Enable RDP prompt
$rdp = Read-Host -Prompt 'enable RDP?y/n'
if ($rdp -eq 'y')
    {Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -name "fDenyTSConnections" -value 0;
    Enable-NetFirewallRule -DisplayGroup "Remote Desktop"}
    else {Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -name "fDenyTSConnections" -value 1;
    Disable-NetFirewallRule -DisplayGroup "Remote Desktop"}


#Prompts user on wheather to install malwarebytes antirootkit beta
$MBarSetup = Read-Host -Prompt 'Install Malwarebytes anti rootkit?y/n'
if ($MBarSetup -eq 'y')
    {Invoke-WebRequest -Uri "https://downloads.malwarebytes.com/file/mbar/" -OutFile "C:\Users\MBSetup.exe";
    Start-Process -FilePath "C:\Users\MBSetup.exe" -ArgumentList "/NOCANCEL /NORESTART /VERYSILENT /SUPPRESSMSGBOXES";
    Start-Sleep -s 10;
    Remove-Item C:\Users\MBSetup.exe
    }
    else {Write-host 'Malwarebytes antirootkit was not installed'}


#Enable the firewall
Set-NetFirewallProfile -Profile Domain, Public, Private -Enabled True


#Enable realtime Monitoring
Set-MpPreference -DisableRealtimeMonitoring $false

#Windows Defender Update Prompt
$WDUpdate = Read-Host -Prompt 'Update Windows Defender?y/n'
if ($WDUpdate -eq 'y')
        {Update-MpSignature}
#Windows Defender Scan Prompt
$WDSC = Read-Host -Prompt 'Run a full scan with Windows Defender?y/n or q for a quickscan'
if ($WDSC -eq 'y')
        {start-MpScan -ScanType FullScan}
if ($WDSC -eq 'q')
    {start-MpScan -ScanType QuickScan}

#Threat Removal
$WDRM = Read-Host -Prompt 'do you want to remove these threats?y/n'
if ($WDRM = 'y')
    {Remove-MpThreat}
#enable removable drive scanning
Set-MpPreference -DisableRemovableDriveScanning $false
#enables netowk drive
Set-MpPreference -DisableScanningMappedNetworkDrivesForFullScan $false
#scan archives
Set-MpPreference -DisableArchiveScanning $false

#Chocolatey Package manager(Similar to a Linux Package manager EX:apt, Pacman, DNF, or RPM)
#I did not create Chocolatey, but I use the commands from it. I also gave credit at the top to the creator.
$choc = Read-Host -Prompt 'do you want chocolatey to install programs?y/n'
if ($choc = 'y')
    {
    choco install firefox -y
    choco upgrade firefox -y;
    choco install malwarebytes -y;
    choco install googlechrome -y;
    choco upgrade googlechrome -y;
    choco install libreoffice-still -y;
    }
    else {write-host 'Nothing was installed or updated'}

#install A windows Update(Annoying)
$update = Read-Host -Prompt 'Perform a Windows Update?y/n'
if ($update -eq 'y')
    {Add-WUServiceManager -MicrosoftUpdate; Install-WindowsUpdate -AcceptAll -AutoReboot}
    else {Write-host 'You have decided not to update'}

#search function

$extension = @( 'aac', 'adt', 'adts', 'accdb', 'accde', 'aif', 'aifc', 'aiff', 'aspx', 'avi', 'bat', 'bin', 'bmp', 'cab', 'cda', 'csv',
'dif', 'dll', 'doc', 'docm','docx', 'dot', 'dotx', 'eml', 'eps', 'exe', 'flv', 'gif', 'htm', 'html', 'ini', 'iso', 'jar', 'jpg', 'jpeg',
'm4a', 'mdb', 'mid', 'midi', 'mov', 'mp3', 'mp4', 'mpeg', 'mpg', 'msi', 'mui', 'pdf', 'png', 'pot', 'potm', 'potx', 'ppam', 'pps',
'ppsm', 'ppsx', 'ppt', 'pptm', 'pptx', 'psd', 'pst', 'pub', 'rar', 'rtf', 'sldm', 'sldx', 'swf', 'sys', 'tif', 'tiff', 'tmp', 'txt', 'vob', 'vsd',
'vsdm', 'vsdx', 'vss', 'vst', 'vstm', 'vstx', 'wav', 'wbk', 'wks', 'wma', 'wmd', 'wmv', 'wmd', 'wmv' ,'wmz', 'wms', 'wpd', 'wp5', 'xla', 'xlam', 'xll', 'xlm',
'xls', 'xlsm', 'xlsx', 'xlt', 'xps', 'zip')


function Get-File{
[cmdletBinding()]
param(
    [parameter(Mandatory=$True)]
    $FileType,

    [parameter()]
    [validateSet('0','1')]
    $Period,
    

    [parameter(Mandatory=$True)]
    [string]$Directory
    )

process{
    if ($period -eq 1)
        {$Filetype = $Filetype | ForEach-Object {$_.insert(0,'.')}}
    if ( $FileType.contains('..'))
        {Write-Output 'you should not have period equal 1'}
        
    $Dir = get-childitem $Directory -recurse  -Force -ErrorAction SilentlyContinue
    remove-item $home\Desktop\Get-File_Search.txt
    foreach ($file in $fileType)
        {
        
        $List = $Dir | where {$_.name -match $file}
        $List |ft fullname | out-file  $home\Desktop\Get-File_Search.txt -Append
        }
    }
}


#Default/starting Function Reference.
get-file -FileType $extension -period 1 -Directory $home
#Example for video
#get-file -FileType jpeg -Period 1 -Directory $home


