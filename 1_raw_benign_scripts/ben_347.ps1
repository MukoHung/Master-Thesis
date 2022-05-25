<#
Modified from the Microsoft Baseline-LocalInstall.ps1

.SYNOPSIS

Inspired to do this by Jason Fossen's SEC505 Class.  Using Microsofts original script as a framework, 
the modifications will create dynamic mapping of GPOs to Vars and the required collections based on GPO 
names and systemtype.  Finally, it will import a Local Group Policy to a system utilizing Hardening
 Baseline Practices (read STIG) from the Group Policy Objects created by the hardwork from GS and
 Military persons in the Department of Information Systems Agency.  ~WOPA

As long as the DISA source file naming conventions remain static this script should 
not need updated except to fix the programmatic errors that inevitably exist.

.DESCRIPTION
Applies DISA GPO STIGs to local group policy utilizing the LGPO exe tool.

REQUIREMENTS:

* PowerShell execution policy must be configured to allow script execution; for example,
  with a command such as the following:
  Set-ExecutionPolicy RemoteSigned

* LGPO.exe must be in the Tools subdirectory or somewhere in the Path. LGPO.exe is part of
  the Security Compliance Toolkit and can be downloaded from this URL:
  https://www.microsoft.com/download/details.aspx?id=55319
  #>

#########
#Removed Things below
<#
Commenting and commands out, moving to top with applicable comments.  

Modifications include Hardcoding the below ---

.PARAMETER Win10DomainJoined
Installs security configuration baseline for Windows 10, domain-joined

.PARAMETER Win10NonDomainJoined
Installs security configuration baseline for Windows 10, non-domain-joined

.PARAMETER WSMember
Installs security configuration baseline for Windows Server, domain-joined member server

.PARAMETER WSNonDomainJoined
Installs security configuration baseline for Windows Server, non-domain-joined

.PARAMETER WSDomainController
Installs security configuration baseline for Windows Server, domain controller


Execute this script with one of these required command-line switches to install
the corresponding baseline:
 -Win10DomainJoined    - Windows 10, domain-joined
 -Win10NonDomainJoined - Windows 10, non-domain-joined
 -WSMember             - Windows Server, domain-joined member server
 -WSNonDomainJoined    - Windows Server, non-domain-joined
 -WSDomainController   - Windows Server, domain controller
 
<#
----Commeting out the Parameters since it will now be menu based
param(
    [Parameter(Mandatory = $true, ParameterSetName = 'Win10DJ')]
    [switch]
    $Win10DomainJoined,

    [Parameter(Mandatory = $true, ParameterSetName = 'Win10NonDJ')]
    [switch]
    $Win10NonDomainJoined,

    [Parameter(Mandatory = $true, ParameterSetName = 'WSDJ')]
    [switch]
    $WSMember,

    [Parameter(Mandatory = $true, ParameterSetName = 'WSNonDJ')]
    [switch]
    $WSNonDomainJoined,

    [Parameter(Mandatory = $true, ParameterSetName = 'WSDC')]
    [switch]
    $WSDomainController
)
<# EDIT THIS SECTION WHEN GPO NAMES ARE UPDATED 

(Not req'd now, creating variables below in funct.)
Moved this to top....

GPO names expected in the current baseline set
Created function to dynamically create the Variables based off Disa GPOs

$GPO_IE11_Computer   = "MSFT Internet Explorer 11 - Computer"
$GPO_IE11_User       = "MSFT Internet Explorer 11 - User"
$GPO_Win10_BitLocker = "MSFT Windows 10 1909 - BitLocker"
$GPO_Win10_Computer  = "MSFT Windows 10 1909 - Computer"
$GPO_Win10_User      = "MSFT Windows 10 1909 - User"
$GPO_All_DefenderAV  = "MSFT Windows 10 1909 and Server 1909 - Defender Antivirus"
$GPO_All_DomainSec   = "MSFT Windows 10 1909 and Server 1909 - Domain Security"
$GPO_CredentialGuard = "MSFT Windows 10 1909 and Server 1909 Member Server - Credential Guard"
$GPO_WS_DC           = "MSFT Windows Server 1909 - Domain Controller"
$GPO_WS_DC_VBS       = "MSFT Windows Server 1909 - Domain Controller Virtualization Based Security"
$GPO_WS_Member       = "MSFT Windows Server 1909 - Member Server"
#>
##########
$scriptRoot = $PSScriptRoot
$scriptDir = $scriptRoot
cd $scriptRoot
cd ..\
$rootDir = pwd
cd $scriptDir
$tempDir = "$scriptDir\temp"
$toolsDir = "$scriptDir\Tools"
$name = Get-ChildItem -Path $rootDir -Filter "*U_STIG*" 
$GPOsDir = Get-ChildItem -Path $scriptDir -Filter "*DISA STIG GPO*" | %{$_.fullname}

<#########################################################
#
### Do not allow this script to run on a domain controller.
### Reference re detection logic: 
### https://docs.microsoft.com/en-au/windows/win32/cimwin32prov/win32-operatingsystem
#
##########################################################>

if ((Get-WmiObject Win32_OperatingSystem).ProductType -eq 2)
{
    $errmsg = "`r`n" +
              "###############################################################################################`r`n" +
              "###  Execution of this local-policy script is not supported on domain controllers. Exiting. ###`r`n" +
              "###############################################################################################`r`n"
    Write-Error $errmsg
    return
}

$GpoArray =  Import-Clixml $tempDir\GPOGUIDmap.xml

$bMissingGPO = $false


<#Dynamically Create Vars and Main Collections. Win8 
looks wacky because of removal of the . in 8.1,
But req'd because of powershell thinking it is 
a frickin property of an object. Crazy ways to go about
different versions of concat, += , whatever #>



 


function GPO_Vars(){
$GPOVars = Import-Csv $tempDir\GPOGUIDmap.csv
#if items exit remove, recreate, and enter first line comment
Remove-Item $tempDir\GPO_Vars.ps1 -ErrorAction SilentlyContinue
Remove-Item $tempDir\GPOCollection.ps1 -ErrorAction SilentlyContinue
#write-host / echo alias to write first comment
echo "#Var Creation based on GPOs in folders" > $tempDir\GPO_Vars.ps1
echo "#AddToLibrary Var Creation based on GPOs in folders" > $tempDir\GPOCollection.ps1
$i=0;

forEach($Name in $GPOVars){
#Create and replace for each key and name ' ' with '_' 

$String = $GPOVars.Key[$i] 
$NameGPO = $GPOVars.Name[$i]

$String = $string -replace ' ','_'

$NewVar="$" 
$NewVar+=$String

#Concat the variables and names
$String = [System.String]::Concat($NewVar,"=",'"',$NameGPO,'"')
#remove '\.' in string
$String = $string -replace '\.',''

#Create and concat the library collection
$CollectionVar = [System.String]::Concat('AddToCollection',' ','$GPOs',' ',$NewVar)
$CollectionVar = $CollectionVar -replace '\.',''
$CollectionVar >> $tempDir\GPOCollection.ps1
$String >> $tempDir\GPO_Vars.ps1
$i+=1
 }
 }

function CreateLib(){
#Remove any of the matches to ommit that from the collection except for Application, where it returns
#all that aren't matched.

$Win10Collection = Get-Content $tempDir\GPOCollection.ps1 | Select-String -Pattern  "Windows_10","Internet","Firewall","Defender"
$Win10Vars = Get-Content $tempDir\GPO_Vars.ps1 | Select-String -Pattern  "Windows_10","Internet","Firewall","Defender"

$Server2016Collection = Get-Content $tempDir\GPOCollection.ps1 | Select-String -Pattern  "Windows_Server_2016","Internet","Firewall","Defender"
$Server2016Vars = Get-Content $tempDir\GPO_Vars.ps1 | Select-String -Pattern  "Windows_Server_2016","Internet","Firewall","Defender"

$Server2012Collection = Get-Content $tempDir\GPOCollection.ps1 | Select-String -Pattern  "Windows_Server_2012","Internet","Firewall","Defender"
$Server2012Vars = Get-Content $tempDir\GPO_Vars.ps1 | Select-String -Pattern  "Windows_Server_2012","Internet","Firewall","Defender"

$Server2019Collection = Get-Content $tempDir\GPOCollection.ps1 | Select-String -Pattern  "Windows_Server_2019","Internet","Firewall","Defender"
$Server2019Vars = Get-Content $tempDir\GPO_Vars.ps1 | Select-String -Pattern  "Windows_Server_2019","Internet","Firewall","Defender"

$Win8Collection = Get-Content $tempDir\GPOCollection.ps1 | Select-String -Pattern  "Windows_8","Internet","Firewall","Defender"
$Win8Vars = Get-Content $tempDir\GPO_Vars.ps1 | Select-String -Pattern  "Windows_8","Internet","Firewall","Defender"

$ApplicationGPOCollection = Get-Content $tempDir\GPOCollection.ps1 | select-string -Pattern "Windows_8","Windows_10","Windows_Server_2016","Windows_Server_2012","Windows_Server_2019","Windows_8","Internet","Firewall","Defender" -notmatch
$ApplicationGPOVars = Get-Content $tempDir\GPO_Vars.ps1 | select-string -Pattern "Windows_8","Windows_10","Windows_Server_2016","Windows_Server_2012","Windows_Server_2019","Windows_8","Internet","Firewall","Defender" -notmatch

$Win10Collection > $tempDir\WIN10Collection.ps1
$Win10Vars > $tempDir\Win10Vars.ps1

$ApplicationGPOCollection > $tempDir\ApplicationGPOCollection.ps1
$ApplicationGPOVars > $tempDir\ApplicationGPOVars.ps1

$Server2016Collection > $tempDir\Server2016Collection.ps1
$Server2016Collection > $tempDir\Server2016Collection.ps1

$Server2012Collection > $tempDir\Server2012Collection.ps1
$Server2012Vars > $tempDir\Server2012Vars.ps1

$Server2019Collection > $tempDir\Server2019Collection.ps1
$Server2019Vars > $tempDir\Server2019Vars.ps1

$Win8Collection > $tempDir\Win8Collection.ps1
$Win8Vars > $tempDir\Win8Vars.ps1
}

function AddToCollection([System.Collections.Hashtable]$ht, [System.String]$GpoName){
    $guid = $GpoArray.$GpoName
    
    if ($null -eq $guid)
    {
        $Script:bMissingGPO = $true
        Write-Error "MISSING GPO: $GpoName"
    }
    else
    {
        $ht.Add($GpoName, $guid)
        #Get-ChildItem -Path $GPOsDir -Recurse -Filter "{*" | Copy-Item -Destination "$tempDir\gpgid\" -Container -Recurse 

}

    }



GPO_Vars;
CreateLib;

$GPOs = @{}
$baselineLabel = ""

#Menus to choose Systemtype
Do {
Write-Host "

                    __________ Select Your System Type ___________"                      
write-host "         
                      1 - Windows 10, domain-joined
                      2 - Windows 10, non-domain-joined
                      3 - Windows 8, domain-joined
                      4 - Windows 8, non-domain-joined
                      5 - Windows Server, non-domain-joined
                      6 - Windows Server, domain controller
                      Q - QUIT
                      " -ForeGroundColor Yellow
write-host "                   _______________________________________________

"



$choice1 = read-host -prompt "Select number & press enter"
} until ($choice1 -eq "1" -or $choice1 -eq "2" -or $choice1 -eq "3" -or $choice1 -eq "4" -or $choice1 -eq "5"-or $choice1 -eq "6" -or $choice1 -eq "Q" -or $choice1 -eq "q")
Switch ($choice1) {

"1" {
$Win10DomainJoined = $True;

 }

"2" {
$Win10NonDomainJoined  = $True;

}
"3" {
$Win8DomainJoined = $True;
}
"4" {
$Win8NonDomainJoined = $True
}
"5" {
$WSMember = $True
Write-Host "
What Server Version is it?"
do { 
Write-Host "
The acceptable input is:
1 - Server 2012
2 - Server 2016
3 - Server 2019
"
$Year = Read-Host -prompt "Enter the Number now: (1,2,3 or Q)"
} until ($Year  -eq "1" -or $Year -eq "2" -or $Year -eq "3" -or $Year -eq "Q") 
Switch ($Year){
"1"{$SeverYear = "2012"}
"2"{$SeverYear = "2016"}
"3"{$SeverYear = "2019"}

"Q" {
Write-Host "Exiting Entire Script Now....
"exit;
 }
 }
}

"6" {
Write-Host "
Please do not run this script on a DC.
Exiting now......CBKHHAFHTTT!!!!
"
exit;
}

"Q" {
Write-Host "Exiting Now....
"
exit
 }

 }

 ### This section will determine which GPOs get pushed to the system. ###



if ($Win10DomainJoined -or $Win10NonDomainJoined)
{
    if ($Win10DomainJoined)
    {
        $baselineLabel = "Windows 10 - domain-joined"
    }
    else
    {
        $baselineLabel = "Windows 10 - non-domain-joined"
    }
    
. $tempDir\Win10Vars.ps1 
. $tempDir\ApplicationGPOVars.ps1
. $tempDir\WIN10Collection.ps1  
. $tempDir\ApplicationGPOCollection.ps1

    }

# GPOs for Windows Server (not Domain Controller)
if ($WSMember -or $WSNonDomainJoined)
{
    if ($WSMember)
    {
        $baselineLabel = "Windows Server - domain-joined"
    }
    else
    {
        $baselineLabel = "Windows Server - non-domain-joined"
    }

    if($ServerYear -eq "2019"){
    . $tempDir\Server2019Vars.ps1
    . $tempDir\Server2019Collection.ps1

    }elseif($ServerYear -eq "2016"){
    . $tempDir\Server2016Vars.ps1
    . $tempDir\Server2016Collection.ps1
    }else{
    
    . $tempDir\Server2012Vars.ps1
    . $tempDir\Server2012Collection.ps1
       
    }
    #Uncomment the next line to apply the gpo to the collectionapplications on Member Server
    #. $tempDir\ApllicationGPOCollection.ps1
    
}

# GPOs for Windows Server Domain Controller
if ($WSDomainController)
{
    $baselineLabel = "Windows Server - domain controller"
 Write-Host "Do not run this on a DC dummy"
 exit;
 }

# If any named GPOs not found, stop
#>

if ($bMissingGPO)
{
    return
}

# Get location of this script

$rootDir = [System.IO.Path]::GetDirectoryName($MyInvocation.MyCommand.Path)

# Verify availability of LGPO.exe; if not in path, but in Tools subdirectory, add Tools subdirectory to the path.
$origPath = ""
if ($null -eq (Get-Command LGPO.exe -ErrorAction SilentlyContinue))
{
    if (Test-Path -Path $rootDir\Tools\LGPO.exe)
    {
        $origPath = $env:Path
        $env:Path = "$rootDir\Tools;" + $origPath
        Write-Verbose $env:Path
        Write-Verbose (Get-Command LGPO.exe)
    }
    else
    {
$lgpoErr = @"

  ============================================================================================
    LGPO.exe must be in the Tools subdirectory or somewhere in the Path. LGPO.exe is part of
    the Security Compliance Toolkit and can be downloaded from this URL:
    https://www.microsoft.com/download/details.aspx?id=55319
  ============================================================================================
"@
        Write-Error $lgpoErr
        return
    }
}

################################################################################
# Preparatory...

# All log output in Unicode
$OutputEncodingPrevious = $OutputEncoding
$OutputEncoding = [System.Text.ASCIIEncoding]::Unicode

Push-Location $rootDir

# Log file full path
$logfile = [System.IO.Path]::Combine($rootDir, "BaselineInstall-" + [datetime]::Now.ToString("yyyyMMdd-HHmm-ss") + ".log")
Write-Host "Logging to $logfile ..." -ForegroundColor Cyan
$MyInvocation.MyCommand.Name + ", " + [datetime]::Now.ToString() | Out-File -LiteralPath $logfile


# Functions to simplify logging and reporting progress to the display
$dline = "=================================================================================================="
$sline = "--------------------------------------------------------------------------------------------------"
function Log([string] $line)
{
    $line | Out-File -LiteralPath $logfile -Append
}
function LogA([string[]] $lines)
{
    $lines | foreach { Log $_ }
}
function ShowProgress([string] $line)
{
    Write-Host $line -ForegroundColor Cyan
}
function ShowProgressA([string[]] $lines)
{
    $lines | foreach { ShowProgress $_ }
}
function LogAndShowProgress([string] $line)
{
    Log $line
    ShowProgress $line
}
function LogAndShowProgressA([string[]] $lines)
{
    $lines | foreach { LogAndShowProgress $_ }
}

LogAndShowProgress $sline
LogAndShowProgress $baselineLabel
LogAndShowProgress "GPOs to be installed:"
$GPOs.Keys | Sort-Object | foreach { 
    LogAndShowProgress "`t$_" 
}
LogAndShowProgress $dline
Log ""

################################################################################

# Wrapper to run LGPO.exe so that both stdout and stderr are redirected and
# PowerShell doesn't bitch about content going to stderr.
function RunLGPO([string] $lgpoParams)
{
    ShowProgress "Running LGPO.exe $lgpoParams"
    LogA (cmd.exe /c "LGPO.exe $lgpoParams 2>&1")
}

################################################################################

# Non-GPOs and preparatory...

LogAndShowProgress "Copy custom administrative templates..."
Get-ChildItem -Path $GPOsDir -Recurse -Filter "*.admx" |
ForEach-Object {Copy-Item $_.FullName -Destination $env:windir\PolicyDefinitions\}

Get-ChildItem -Path $GPOsDir -Recurse -Filter "*.adml" |
ForEach-Object {Copy-Item $_.FullName -Destination $env:windir\PolicyDefinitions\en-US\}
Log $dline

LogAndShowProgress "Configuring Client Side Extensions..."
RunLGPO "/v /e mitigation /e audit /e zone /e DGVBS"
Log $dline

if ($Win10DomainJoined -or $Win10NonDomainJoined)
{
    LogAndShowProgress "Disable Xbox scheduled task on Win10..."
    LogA (SCHTASKS.EXE /Change /TN \Microsoft\XblGameSave\XblGameSaveTask /DISABLE)
    Log $dline
}

# Install the GPOs
    cd $GPOsDir
$GPOs.Keys | Sort-Object | foreach {
    $gpoName = $_
    $gpoGuid = $GPOs[$gpoName]
    
    Log $sline
    LogAndShowProgress "Applying GPO `"$gpoName`"..." # ( $gpoGuid )..."
    Log $sline
    Log ""

    RunLGPO "/v /g  .\$gpoGuid"
    Log $dline
    Log ""
}

# For non-domain-joined, back out the local-account restrictions
if ($Win10NonDomainJoined -or $WSNonDomainJoined)
{
    LogAndShowProgress "Non-domain-joined: back out the local-account restrictions..."
    RunLGPO "/v /s ConfigFiles\DeltaForNonDomainJoined.inf /t ConfigFiles\DeltaForNonDomainJoined.txt"
}

# Restore original path if modified
if ($origPath.Length -gt 0)
{
    $env:Path = $origPath
}
# Restore original output encoding
$OutputEncoding = $OutputEncodingPrevious

# Restore original directory location
Pop-Location

################################################################################
$exitMessage = @"
To test properly, create a new non-administrative user account and reboot.

Detailed logs are in this file:
$logfile

"@

Write-Host $dline
Write-Host $dline
Write-Host $exitMessage
Write-Host $dline
Write-Host $dline


################################################################################>
