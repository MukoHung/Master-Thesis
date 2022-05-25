#https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_execution_policies?view=powershell-6&viewFallbackFrom=powershell-Microsoft.PowerShell.Core

<#

#>

#Get-ExecutionPolicy
#Get-ExecutionPolicy -Scope CurrentUser
#Set-ExecutionPolicy -Scope CurrentUser 
#Set-ExecutionPolicy Unrestricted -Scope CurrentUser 

#Get-Content -Path .\Examples2.txt
#Get-Content -Path .\Examples3.txt

#Initialize Path
pushd D:\me\Dropbox\Programming\Powershell


Get-Content -Path .\Examples2.txt | ForEach-Object 
{ 
    if ((Test-Connection -Computername $_ -Quiet -Count 1) -eq $true)
    {
            'Machine is online' 
    }   
}


Get-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion
ProgramFilesDir          : C:\Program Files
CommonFilesDir           : C:\Program Files\Common Files
ProgramFilesDir (x86)    : C:\Program Files (x86)
CommonFilesDir (x86)     : C:\Program Files (x86)\Common Files
CommonW6432Dir           : C:\Program Files\Common Files
DevicePath               : C:\WINDOWS\inf
MediaPathUnexpanded      : C:\WINDOWS\Media
ProgramFilesPath         : C:\Program Files
ProgramW6432Dir          : C:\Program Files
SM_ConfigureProgramsName : Set Program Access and Defaults
SM_GamesName             : Games
PSPath                   : Microsoft.PowerShell.Core\Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion
PSParentPath             : Microsoft.PowerShell.Core\Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows
PSChildName              : CurrentVersion
PSDrive                  : HKLM
PSProvider               : Microsoft.PowerShell.Core\Registry


Get-ItemProperty -path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion -name "ProgramFilesDir"
ProgramFilesDir : C:\Program Files
PSPath          : Microsoft.PowerShell.Core\Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion
PSParentPath    : Microsoft.PowerShell.Core\Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows
PSChildName     : CurrentVersion
PSDrive         : HKLM
PSProvider      : Microsoft.PowerShell.Core\Registry


Get-ItemProperty -path HKLM:\SOFTWARE\Microsoft\PowerShell\1\PowerShellEngine
ApplicationBase         : C:\Windows\System32\WindowsPowerShell\v1.0
ConsoleHostAssemblyName : Microsoft.PowerShell.ConsoleHost, Version=1.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35, ProcessorArchitecture=msil
ConsoleHostModuleName   : C:\Windows\System32\WindowsPowerShell\v1.0\Microsoft.PowerShell.ConsoleHost.dll
PowerShellVersion       : 2.0
PSCompatibleVersion     : 1.0, 2.0
RuntimeVersion          : v2.0.50727
PSPath                  : Microsoft.PowerShell.Core\Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\PowerShell\1\PowerShellEngine
PSParentPath            : Microsoft.PowerShell.Core\Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\PowerShell\1
PSChildName             : PowerShellEngine
PSDrive                 : HKLM
PSProvider              : Microsoft.PowerShell.Core\Registry



Get-ItemProperty .\CopyFilesDirs\ | get-member


   TypeName: System.IO.DirectoryInfo

Name                      MemberType     Definition
----                      ----------     ----------
LinkType                  CodeProperty   System.String LinkType{get=GetLinkType;}
Mode                      CodeProperty   System.String Mode{get=Mode;}
Target                    CodeProperty   System.Collections.Generic.IEnumerable`1[[System.String, mscorlib, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089]] Target{ge...
Create                    Method         void Create(), void Create(System.Security.AccessControl.DirectorySecurity directorySecurity)
CreateObjRef              Method         System.Runtime.Remoting.ObjRef CreateObjRef(type requestedType)
CreateSubdirectory        Method         System.IO.DirectoryInfo CreateSubdirectory(string path), System.IO.DirectoryInfo CreateSubdirectory(string path, System.Security.AccessControl.D...
Delete                    Method         void Delete(), void Delete(bool recursive)
EnumerateDirectories      Method         System.Collections.Generic.IEnumerable[System.IO.DirectoryInfo] EnumerateDirectories(), System.Collections.Generic.IEnumerable[System.IO.Directo...
EnumerateFiles            Method         System.Collections.Generic.IEnumerable[System.IO.FileInfo] EnumerateFiles(), System.Collections.Generic.IEnumerable[System.IO.FileInfo] Enumerat...
EnumerateFileSystemInfos  Method         System.Collections.Generic.IEnumerable[System.IO.FileSystemInfo] EnumerateFileSystemInfos(), System.Collections.Generic.IEnumerable[System.IO.Fi...
Equals                    Method         bool Equals(System.Object obj)
GetAccessControl          Method         System.Security.AccessControl.DirectorySecurity GetAccessControl(), System.Security.AccessControl.DirectorySecurity GetAccessControl(System.Secu...
GetDirectories            Method         System.IO.DirectoryInfo[] GetDirectories(), System.IO.DirectoryInfo[] GetDirectories(string searchPattern), System.IO.DirectoryInfo[] GetDirecto...
GetFiles                  Method         System.IO.FileInfo[] GetFiles(string searchPattern), System.IO.FileInfo[] GetFiles(string searchPattern, System.IO.SearchOption searchOption), S...
GetFileSystemInfos        Method         System.IO.FileSystemInfo[] GetFileSystemInfos(string searchPattern), System.IO.FileSystemInfo[] GetFileSystemInfos(string searchPattern, System....
GetHashCode               Method         int GetHashCode()
..............................



Get-ItemProperty .\CopyFilesDirs\ -name Mode
Mode         : da----
PSPath       : Microsoft.PowerShell.Core\FileSystem::D:\me\Dropbox\Programming\Powershell\CopyFilesDirs\
PSParentPath : Microsoft.PowerShell.Core\FileSystem::D:\me\Dropbox\Programming\Powershell
PSChildName  : CopyFilesDirs
PSDrive      : D
PSProvider   : Microsoft.PowerShell.Core\FileSystem

(Get-ItemProperty .\CopyFilesDirs\).PSProvider

Name                 Capabilities                                                                        Drives
----                 ------------                                                                        ------
FileSystem           Filter, ShouldProcess, Credentials                                                  {C, D}






PS D:\me\Dropbox\Programming\Powershell> (Get-ItemProperty .\CopyFilesDirs\)


    Directory: D:\me\Dropbox\Programming\Powershell


Mode                LastWriteTime         Length Name
----                -------------         ------ ----
da----        6/22/2018  11:49 AM                CopyFilesDirs






(Get-ItemProperty .\CopyFilesDirs\).PSDriveName           Used (GB)     Free (GB) Provider      Root                                                                                                                    CurrentLocation
----           ---------     --------- --------      ----                                                                                                                    ---------------
D                  18.57         30.26 FileSystem    D:\                                                                                                   me\Dropbox\Programming\Powershell

PS D:\me\Dropbox\Programming\Powershell> (Get-ItemProperty .\CopyFilesDirs\).PSChildName
CopyFilesDirs
PS D:\me\Dropbox\Programming\Powershell> (Get-ItemProperty .\CopyFilesDirs\).PSParentName
PS D:\me\Dropbox\Programming\Powershell> (Get-ItemProperty .\CopyFilesDirs\).FullName
D:\me\Dropbox\Programming\Powershell\CopyFilesDirs\
PS D:\me\Dropbox\Programming\Powershell> $result = (Get-ItemProperty .\CopyFilesDirs\).FullName
PS D:\me\Dropbox\Programming\Powershell> $result
D:\me\Dropbox\Programming\Powershell\CopyFilesDirs\
PS D:\me\Dropbox\Programming\Powershell>



PS D:\me\Dropbox\Programming\Powershell> Get-ItemProperty -path HKLM:\SOFTWARE\Microsoft\PowerShell\1\PowerShellEngine | Get-Member


   TypeName: System.Management.Automation.PSCustomObject

Name                    MemberType   Definition
----                    ----------   ----------
Equals                  Method       bool Equals(System.Object obj)
GetHashCode             Method       int GetHashCode()
GetType                 Method       type GetType()
ToString                Method       string ToString()
ApplicationBase         NoteProperty string ApplicationBase=C:\Windows\System32\WindowsPowerShell\v1.0
ConsoleHostAssemblyName NoteProperty string ConsoleHostAssemblyName=Microsoft.PowerShell.ConsoleHost, Version=1.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35, ProcessorArchite...
ConsoleHostModuleName   NoteProperty string ConsoleHostModuleName=C:\Windows\System32\WindowsPowerShell\v1.0\Microsoft.PowerShell.ConsoleHost.dll
PowerShellVersion       NoteProperty string PowerShellVersion=2.0
PSChildName             NoteProperty string PSChildName=PowerShellEngine
PSCompatibleVersion     NoteProperty string PSCompatibleVersion=1.0, 2.0
PSDrive                 NoteProperty PSDriveInfo PSDrive=HKLM
PSParentPath            NoteProperty string PSParentPath=Microsoft.PowerShell.Core\Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\PowerShell\1
PSPath                  NoteProperty string PSPath=Microsoft.PowerShell.Core\Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\PowerShell\1\PowerShellEngine
PSProvider              NoteProperty ProviderInfo PSProvider=Microsoft.PowerShell.Core\Registry
RuntimeVersion          NoteProperty string RuntimeVersion=v2.0.50727


#Get script properties of event log objects
Get-Service| Get-Member -View Extended


$A = "Get-Process", "Get-Service", "Get-Culture", "Get-PSDrive", "Get-ExecutionPolicy"
ForEach ($Cmdlet in $A) {Invoke-Command $Cmdlet | Get-Member -Name MachineName}

    
#Get members for an array
$A = Get-Member - InputObject @(1)
$A.Count
$A = Get-Member -InputObject 1,2,3
$A.Count

#Determine which object properties you can set
$File = Get-Item c:\test\textFile.txt
$File.psobject.properties | Where-Object {$_.issettable} | Format-Table -Property name




$S = Get-Service
$S | Get-Member
Get-Member -InputObject $S




#https://www.slideshare.net/sandunangelo/windows-power-shell-49205867
$ine
$

Write-Host "Hello World";

${my Test_3#} = "Hello World";
${my Test_3#}

[string] $test = "";

cls

function myFirstfn2([string] $test)
{
    Write-Output "Hello";
    Write-Output $test;
}

myFirstfn2("yesMe");

function myFirstfn($test)
{
    Write-Output "Hello";
    Write-Output $test;
}

[string] $test = "try me";
myFirstfn($test);


$fn = "Ha";
$mn = "oo";
$ln = "Mo";

[string] $mytest;
$mytest = $fn + " " + $mn + " " + $ln;
myFirstfn($mytest);

if ($Error.Count eq 0)
{
    #Handle logic here
    #Access $Error object like $Error[0]
    throw New-Object($Error[0]);
}




