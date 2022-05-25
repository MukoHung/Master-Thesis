#Requires -Version 7
#Requires -RunAsAdministrator
############################################################################
#Powershell
#
#Stefan Morf
#
#intune app packager
############################################################################
param
(
    [switch]$createTree, #create working structure for new app or version
    [switch]$packNew, #create the *.intunewin which not exist
    [switch]$removeLatest, #remove latest created *.intunewin file
    [switch]$packAll, #recreate the *.intunewin for all apps and versions
    [string]$packSpecific, #create the *.intunewin for specific executable
    [switch]$createArchive, #create zip files with all tools and versions with date tag
    #[switch]$importAllTools, #create structure and import all apps from app-downloader
    [switch]$help,
    [switch]$update,
    [switch]$version
)

## User Variables ##########################################################
#define download-directory from app-downloader.ps1 and import all files within
#$downloadFolder= "$([Environment]::GetFolderPath("MyDocuments"))\software\98_Tools"
#$Tools = Get-ChildItem $downloadFolder -File

#the automatic package creating process search in this order for the primary executable
#at the moment the count of filenames (4) is static in GetPackages function
[string[]]$fileNames = "main.ps1","main.cmd","*.msi","*.exe"
[string]$updateURI = "https://raw.githubusercontent.com/xSTMx/powershell-lib/main/app-packer.ps1"

#check for config file and import
$packageFolder = "$([Environment]::GetFolderPath("MyDocuments"))"
try
{
    $configFile = Get-Item "./app-packer.config" -ErrorAction Stop
    $config = Get-Content -Path $configFile | ConvertFrom-Json
    $packageFolder = $config.config.workingDirectory
}
catch{}

#check for IntuneWinAppUtil.exe existence and try to download if not
if(!(Test-Path "./IntuneWinAppUtil.exe" -ErrorAction SilentlyContinue)){Start-BitsTransfer "https://github.com/microsoft/Microsoft-Win32-Content-Prep-Tool/raw/master/IntuneWinAppUtil.exe"}
#check again for IntuneWinAppUtil.exe existence
$intunePackager = try{Get-Item "./IntuneWinAppUtil.exe" -ErrorAction Stop}catch{Throw "`n  IntuneWinAppUtil.exe not found"}

## System Variables ########################################################
$scriptversion = "0.1"
Add-Type -AssemblyName System.Web
Add-Type -AssemblyName System.Net
Add-Type -AssemblyName System.Windows.Forms
Import-Module BitsTransfer

## System Functions ########################################################
Function help()
{
    Write-Host "`nParameters:`n"
    Write-Host "   -help                show this info"
    Write-Host "   -update              update this script from github"
    Write-Host "   -version             show version"
    Write-Host "   -createTree          create working tree for new tool or version (interactive)"
    Write-Host "   -packNew             create *.intunewin which not exist"
    Write-Host "   -removeLatest        delete the latest *.intunewin file in all subfolders"
    Write-Host "   -packAll             recreate all *.intunewin files"
    Write-Host "   -packSpecific        create *.intunewin from specific executable"
    Write-Host "   -createArchive       create *.zip file for each version of each tool with date tag to selected folder"
#    Write-Host "   -importAllTools      create folder structure and import all exetutables from app-downloader"
    Write-Host
    Write-Host "Example: app-packager.ps1 -packSpecific `"$packageFolder\test1\2.4.3\source\main.ps1`"`n"
}

Function CheckRequirements
{
    try #check signature and version from IntuneWinAppUtil.exe
    {
        $signatureCheck = (Get-AuthenticodeSignature $intunePackager -ErrorAction Stop).Status
        $iwauVersion = $null
        $iwauVersion = [System.Diagnostics.FileVersionInfo]::GetVersionInfo($($intunePackager.FullName)).FileVersion
        Write-Host "`n`n  IntuneWinAppUtil.exe version $iwauVersion will be used" -ForegroundColor Green
        if($signatureCheck -eq "Valid"){Write-Host "  IntuneWinAppUtil.exe signature is Valid`n" -ForegroundColor Green}
        else{Write-Host "  IntuneWinAppUtil.exe signature is Invalid`n" -ForegroundColor Red}
    }
    catch
    {
        Write-Host "`n`n  IntuneWinAppUtil.exe version not found" -ForegroundColor Red
        Write-Host "  IntuneWinAppUtil.exe signature is Invalid`n" -ForegroundColor Red
    }
}

Function WriteConfig([string]$workingDirectory)
{
     $json = [ordered]@{
         config= @{
             workingDirectory = "$workingDirectory"
         }
     }
     $json | ConvertTo-Json | Out-File "./app-packer.config" -Force
}

Function UpdateWorkingDirectory()
{
    $workingDirectory = Read-Host -Prompt "`n  please enter working directory without qotes (Default: $packageFolder)"
    if($workingDirectory)
    {
        try
        {
            $workingDirectory = Get-Item $workingDirectory -ErrorAction Stop
            Write-Host "  using $workingDirectory`n"
            WriteConfig -workingDirectory $($workingDirectory.FullName)
            return $workingDirectory.FullName
        }
        catch
        {
            Write-Host "  working directory not found...`n  default will be used...`n"
            if(!(Test-Path -Path $packageFolder)){New-Item -ItemType Directory $packageFolder | Out-Null}
            return "$packageFolder"
        }
    }
    else{return "$packageFolder"}
}

## Module Functions ########################################################
Function CreateAppStructureIneractive()
{
    [string]$name = Read-Host -Prompt "`n  please enter tool name"
    [string]$version = Read-Host -Prompt "  please enter tool version"
    [string]$import = Read-Host -Prompt "  please enter path to executable (remove `"`")"
    try{$executable = Get-Item $import}catch{$import = $null}
    Write-Host "`n  create app structure..." -ForegroundColor Blue -NoNewline
    if($name -and $version){CreateAppStructure -appName $name -appVersion $version;Write-Host "[OK]" -ForegroundColor Green}
    else{Throw "specify name and version as string-type"}
    if($import)
    {
        Write-Host "  move promoted executable to source folder..." -ForegroundColor Blue -NoNewline
        try{Move-Item -Path $executable.FullName -Destination "$packageFolder\$name\$version\source\$($executable.Name)";Write-Host "[OK]" -ForegroundColor Green}
        catch{Write-Host "[Fail]" -ForegroundColor Red}
    }
}

Function CreateAppStructure([string]$appName,[string]$appVersion)
{
    $appFolderName = "$packageFolder\$appName"
    $appVersionFolder = "$appFolderName\$appVersion"
    $appWorkFolderConfig = "$appVersionFolder\config"
    $appWorkFolderIntune = "$appVersionFolder\intune"
    $appWorkFolderSource = "$appVersionFolder\source"
    if(!(Test-Path -Path $appFolderName))
    {
        New-Item -ItemType Directory $appFolderName | Out-Null
    }
    if(!(Test-Path -Path $appVersionFolder))
    {
        New-Item -ItemType Directory $appVersionFolder | Out-Null
    }
    if(!(Test-Path -Path "$appWorkFolderConfig") -or !(Test-Path -Path "$appWorkFolderIntune") -or !(Test-Path -Path "$appWorkFolderSource"))
    {
        New-Item -ItemType Directory -Path $appWorkFolderConfig -ErrorAction SilentlyContinue | Out-Null
        New-Item -ItemType Directory -Path $appWorkFolderIntune -ErrorAction SilentlyContinue | Out-Null
        New-Item -ItemType Directory -Path $appWorkFolderSource -ErrorAction SilentlyContinue | Out-Null
    }
}

Function RemoveLatest()
{
    $latestIntunewinFile = Get-ChildItem -Recurse -Path $packageFolder -Filter "*.intunewin" | Sort-Object LastWriteTime | Select-Object -Last 1
    Write-Host "`n`n  remove latest *.intunewin file `"$($latestIntunewinFile.Name)`"..." -ForegroundColor Blue -NoNewline
    try
    {
        Remove-Item -Path $($latestIntunewinFile.FullName) -Force -ErrorAction Stop
        Write-Host "[OK]" -ForegroundColor Green
    }
    catch
    {
        Write-Host "[Fail]" -ForegroundColor Red
    }
}

Function GetPackages([string]$type)
{
    #types are all or new (default is new)
    #new are just the structures without .intunewin file
    #all are all executables to create all .intunewin files new
    $tools = (Get-ChildItem -Path $packageFolder | Get-ChildItem).FullName
    foreach($tool in $tools)
    {
        if(((Get-ChildItem -Path "$tool\intune" -Filter "*.intunewin" -ErrorAction SilentlyContinue | Measure-Object).Count -lt 1) -or $type -eq "all")
        {
            #search for executable
            $source = Get-ChildItem "$tool\source" -Filter $fileNames[0]
            if(!$source){$source = Get-ChildItem "$tool\source" -Filter $fileNames[1]}
            if(!$source){$source = Get-ChildItem "$tool\source" -Filter $fileNames[2]}
            if(!$source){$source = Get-ChildItem "$tool\source" -Filter $fileNames[3]}
            if(!$source)
            {
                Write-Host "  sourcefile not found" -ForegroundColor Red
            }
            else
            {
                #create package
                Write-Host "  create package $tool..." -NoNewline -ForegroundColor Blue
                CreateIntunePackage -pathToExecutable $source.FullName
                Write-Host "[OK]" -ForegroundColor Green
            }
        }
        else
        {
            Write-Host "  already created $tool..." -NoNewline -ForegroundColor Blue
            Write-Host "[OK]" -ForegroundColor Yellow
        }
    }
}

Function CreateIntunePackage([string]$pathToExecutable)
{
    #executable can also be a script
    $executable = Get-Item $pathToExecutable
    $workingFolder = ($executable.Directory).parent.FullName
    $appname = ($executable.Directory).Parent.Parent.Name
    $arguments = "-c `"$workingFolder\source`" -s `"$pathToExecutable`" -o `"$workingFolder\intune`" -q"
    Get-ChildItem -Path "$workingFolder\intune" -Filter "*.intunewin" | Remove-Item -Force
    Start-Process $intunePackager -ArgumentList $arguments -Wait -WorkingDirectory $workingFolder -WindowStyle Hidden
    Get-ChildItem -Path "$workingFolder\intune" | Rename-Item -NewName "$appname.intunewin" -ErrorAction SilentlyContinue
}

Function ImportAppLibrary ### not ready to use... ^^
{
    $appsEXE = Get-ChildItem -Path $downloadFolder -Filter "*.exe"
    $appsMSI = Get-ChildItem -Path $downloadFolder -Filter "*.msi"
    $appsOther = Get-ChildItem -Path $downloadFolder -Exclude "*.exe","*.msi","not-processed"
    foreach($app in $appsEXE)
    {
        [string]$appName = $app.BaseName
        [string]$appVersion = $app.VersionInfo.FileVersion
        $appVersion = $appVersion.Trim()
        if(!$appVersion){$appVersion = $app.VersionInfo.ProductVersion; $appVersion = $appVersion.Trim()}
        if($appVersion)
        {
            Write-Host $appName -ForegroundColor Green
            Write-Host $appVersion -ForegroundColor Blue
        }
        else
        {
            Write-Host "skip $appName because no version number embedded"
        }
    }
    return $appLibrary
}

Function CreateArchives()
{
    $readArchiveFolder = Read-Host -Prompt "`n  enter destination folder without quotes (examle: C:\test dir\data)"
    if($archiveFolder = Get-Item $readArchiveFolder)
    {
        $folders = Get-ChildItem $packageFolder -Recurse -Depth 1 -Directory | Where-Object {$_.BaseName -match '.*(\d+(\.\d+){1,3}).*'}
        $date = Get-Date -Format yyyyMMdd
        Write-Host "`n`n  create archives`n" -ForegroundColor DarkYellow
        Foreach ($folder in $folders)
        {
            if(!(Test-Path "$archiveFolder\$($folder.Parent.Parent)-$($folder.Parent)-$folder*"))
            {
                Write-Host "  $($folder.Parent.Parent)-$($folder.Parent)-$folder-$date.zip..." -ForegroundColor Blue -NoNewline
                try
                {
                    Compress-Archive -Path $folder.FullName -DestinationPath "$archiveFolder\$($folder.Parent.Parent)-$($folder.Parent)-$folder-$date.zip" -ErrorAction SilentlyContinue
                    Write-Host "[OK]" -ForegroundColor Green
                }
                catch
                {
                    Write-Host "[Fail]" -ForegroundColor Red
                }

            }
        }
    }
    else{Write-Host "  destination folder not found`n" -ForegroundColor Red}
}

Function UpdateScript()
{
    $scriptName = $MyInvocation.MyCommand
    Write-Host "`n`n  download latest version..." -ForegroundColor Blue -NoNewline
    try
    {
        Start-BitsTransfer $updateURI -Destination "$PSScriptRoot\app-packer-update.ps1"
        Write-Host "[OK]" -ForegroundColor Green
        Start-Process powershell -ArgumentList "$PSScriptRoot\app-packer-update.ps1" -Wait -WindowStyle Hidden
    }
    catch
    {
        Write-Host "[Fail]" -ForegroundColor Red
    }
}

Function CleanupUpdate()
{
    Write-Host "`n`n  cleanup update..." -ForegroundColor Blue -NoNewline
    try
    {
        Copy-Item -Path "$PSScriptRoot\app-packer-update.ps1" -Destination "$PSScriptRoot\app-packer.ps1" -ErrorAction Stop
        Write-Host "[OK]" -ForegroundColor Green
    }
    catch
    {
        Write-Host "[Fail]" -ForegroundColor Red
    }
    exit
}

## Main ####################################################################
CheckRequirements
if($($MyInvocation.MyCommand.Name) -eq "app-packer-update.ps1"){CleanupUpdate}
if($($MyInvocation.MyCommand.Name) -eq "app-packer.ps1"){if(Test-Path "$PSScriptRoot\app-packer-update.ps1"){Remove-Item -Path "$PSScriptRoot\app-packer-update.ps1" -Force | Out-Null}}
if($($MyInvocation.MyCommand.Name) -eq "app-packer.ps1"){$packageFolder = UpdateWorkingDirectory}
if($help){help}
elseif($version){return $scriptversion}
elseif($update){UpdateScript}
elseif($createTree){CreateAppStructureIneractive}
elseif($packNew){GetPackages -type "new"}
elseif($removeLatest){RemoveLatest}
elseif($packAll){GetPackages -type "all"}
elseif($packSpecific){CreateIntunePackage -pathToExecutable $packSpecific}
elseif($createArchive){CreateArchives}
#elseif($importAllTools){}
else{help}
Write-Host