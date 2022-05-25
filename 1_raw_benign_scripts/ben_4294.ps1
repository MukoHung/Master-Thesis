#!/usr/bin/env powershell
<#
.SYNOPSIS
    You can use this script to easly transform any XML file using XDT.
    To use this script you can just save it locally and execute it. The script
    will download its dependencies automatically.

    Created by sayediHashimi
    Modified by obscurerichard
    Thanks Stack Overflow: https://stackoverflow.com/questions/8989737/web-config-transforms-outside-of-microsoft-msbuild
#>
[cmdletbinding()]
param(
    [Parameter(
        Mandatory=$true,
        Position=0)]
    $sourceFile,

    [Parameter(
        Mandatory=$true,
        Position=1)]
    $transformFile,

    [Parameter(
        Mandatory=$true,
        Position=2)]
    $destFile,

    $toolsDir = ("$env:LOCALAPPDATA\LigerShark\tools\"),

    $nugetDownloadUrl = 'http://nuget.org/nuget.exe'
)


<#
.SYNOPSIS
    If nuget is not in the tools
    folder then it will be downloaded there.
#>
function Get-Nuget(){
    [cmdletbinding()]
    param(
        $toolsDir = ("$env:LOCALAPPDATA\LigerShark\tools\"),

        $nugetDownloadUrl = 'http://nuget.org/nuget.exe'
    )
    process{
        $nugetDestPath = Join-Path -Path $toolsDir -ChildPath nuget.exe
        
        if(!(Test-Path $nugetDestPath)){
            'Downloading nuget.exe' | Write-Verbose
            # download nuget
            $webclient = New-Object System.Net.WebClient
            $webclient.DownloadFile($nugetDownloadUrl, $nugetDestPath)

            # double check that is was written to disk
            if(!(Test-Path $nugetDestPath)){
                throw 'unable to download nuget'
            }
        }

        # return the path of the file
        $nugetDestPath
    }
}


function GetTransformXmlExe(){
    [cmdletbinding()]
    param(
        $toolsDir = ("$env:LOCALAPPDATA\LigerShark\tools\")
    )
    process{

        if(!(Test-Path $toolsDir)){ 
            New-Item -Path $toolsDir -ItemType Directory | Out-Null
        }

        $xdtExe = (Get-ChildItem -Path $toolsDir -Include 'SlowCheetah.Xdt.exe' -Recurse) | Select-Object -First 1

        if(!$xdtExe){
            'Downloading xdt since it was not found in the tools folder' | Write-Verbose
            # nuget install Microsoft.Web.Xdt Microsoft.Web.Xdt -Version 2.1.1 OutputDirectory toolsDir
            $cmdArgs = @('install','Microsoft.Web.Xdt','-Version','2.1.1','-OutputDirectory',(Resolve-Path $toolsDir).ToString())

            'Calling nuget.exe to download Microsoft.Web.XmlTransform with the following args: [{0} {1}]' -f (Get-Nuget -toolsDir $toolsDir -nugetDownloadUrl $nugetDownloadUrl), ($cmdArgs -join ' ') | Write-Verbose
            &(Get-Nuget -toolsDir $toolsDir -nugetDownloadUrl $nugetDownloadUrl) $cmdArgs | Out-Null

            $cmdArgs = @('install','SlowCheetah.Xdt','-Prerelease','-Version','1.1.7-beta','-OutputDirectory',(Resolve-Path $toolsDir).ToString())

             # nuget install SlowCheetah.Xdt -Prerelease -Version 1.1.7-beta -OutputDirectory toolsDir
            'Calling nuget.exe to download SlowCheetah.Xdt with the following args: [{0} {1}]' -f (Get-Nuget -toolsDir $toolsDir -nugetDownloadUrl $nugetDownloadUrl), ($cmdArgs -join ' ') | Write-Verbose
            &(Get-Nuget -toolsDir $toolsDir -nugetDownloadUrl $nugetDownloadUrl) $cmdArgs | Out-Null

            $xdtExe = (Get-ChildItem -Path $toolsDir -Include 'SlowCheetah.Xdt.exe' -Recurse) | Select-Object -First 1
            # copy the xdt assemlby if the xdt directory is missing it
            $xdtDllExpectedPath = (Join-Path $xdtExe.Directory.FullName 'Microsoft.Web.XmlTransform.dll')
            
            if(!(Test-Path $xdtDllExpectedPath)){
                # copy the xdt.dll next to the slowcheetah .exe
                $xdtDll = (Get-ChildItem -Path $toolsDir -Include 'Microsoft.Web.XmlTransform.dll' -Recurse) | Select-Object -First 1

                if(!$xdtDll){ throw 'Microsoft.Web.XmlTransform.dll not found' }

                Copy-Item -Path $xdtDll.Fullname -Destination $xdtDllExpectedPath | Out-Null
            }

        }

        if(!$xdtExe){
            throw ('SlowCheetah.Xdt not found. Expected location: [{0}]' -f $xdtExe)
        }

        $xdtExe
    }
}

function Transform-Xml{
    [cmdletbinding()]
    param(
        [Parameter(
            Mandatory=$true,
            Position=0)]
        $sourceFile,

        [Parameter(
            Mandatory=$true,
            Position=1)]
        $transformFile,

        [Parameter(
            Mandatory=$true,
            Position=2)]
        $destFile,

        $toolsDir = ("$env:LOCALAPPDATA\LigerShark\tools\")
    )
    process{
        # slowcheetah.xdt.exe <source file> <transform> <dest file>
        $cmdArgs = @((Resolve-Path $sourceFile).ToString(),
                     (Resolve-Path $transformFile).ToString(),
                     $destFile)

        'Calling slowcheetah.xdt.exe with the args: [{0} {1}]' -f (GetTransformXmlExe), ($cmdArgs -join ' ') | Write-Verbose
        &(GetTransformXmlExe -toolsDir $toolsDir) $cmdArgs
    }
}

Transform-Xml -sourceFile $sourceFile -transformFile $transformFile -destFile $destFile