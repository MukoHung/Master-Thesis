# 
#  Copyright (c) Microsoft Corporation. All rights reserved. 
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#  http://www.apache.org/licenses/LICENSE-2.0
#  
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#  

$global:restart = $false
$sleep = 100
$counter = 0

function Test-IsWebserverRunning {
    if(-not (((netstat -o -n -a ) -match "0.0.0.0:80").length -gt 0 ) ){
        return $false
    }
    return $true
}

if( Test-IsWebserverRunning )  {
    write-warning "There is a webserver already running on port 80" 
    return;
}

#run this elevated (because we use port 80)
If (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    $CommandLine = $MyInvocation.Line.Replace($MyInvocation.InvocationName, $MyInvocation.MyCommand.Definition)
    Start-Process -FilePath PowerShell.exe -Verb Runas -WorkingDirectory (pwd)  -ArgumentList "$CommandLine"
    return 
}

#serve content from the content folder.
$base = "$PSScriptRoot\content"  
  
Get-EventSubscriber | Unregister-Event

# track if this script changes so we can restart.
$fsw = New-Object IO.FileSystemWatcher $PSScriptRoot, $MyInvocation.MyCommand.Name -Property @{IncludeSubdirectories = $false;NotifyFilter = [IO.NotifyFilters]'FileName, LastWrite';EnableRaisingEvents = $true } 
$null = Register-ObjectEvent $fsw Changed -SourceIdentifier FileChanged -Action { 
    $global:restart = $true
}  
       
Write-Host "`n---------------------[Listening on http://localhost]-----------------" 

$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add('http://*:80/')
$listener.Start()

function Make-Safe {
    param ([string]$str ) 
    
    return ($str  -replace '/','\' -replace '\\\\','\' -replace '[^\d\w\[\]_\-\.\\]','-' -replace '--','-').Trim("\/- ")
}

function Get-LocalFilename {
    param(  [Uri]$url )
    $h = make-safe $url.host 
    $path = make-safe $url.LocalPath 
    # $query = make-safe $url.Query
 
    $local = "$base\$path" 
    $local = $local.Trim("\");
    
    if( test-path $local ) {
        return (resolve-path $local)
    }
    return $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($local)
} 

function Send-TextResponse {
    param ($response, $content)
    
    $buffer = [System.Text.Encoding]::UTF8.GetBytes($content)
    $response.ContentLength64 = $buffer.Length
    $len = $buffer.length 
    Write-Progress -Activity "Listening..." -PercentComplete $counter -CurrentOperation "Sending $len bytes " -Status "Sending Response."
    
    $response.OutputStream.Write($buffer, 0, $buffer.Length)
}

function Send-FileResponse {
  param ($response, $file)
    $content =  (get-content $file -raw -encoding byte)
    $response.ContentLength64 = $content.Length
    if( test-path "$file.ContentType" )  {
        $response.ContentType=(get-content "$file.ContentType") 
    }
    $len = $buffer.length 
    Write-Progress -Activity "Listening..." -PercentComplete $counter -CurrentOperation "Sending $len bytes " -Status "Sending Response."

    if( $content ) {
        $response.OutputStream.Write($content, 0, $content.Length)
    }
}

$task = $null

while ($listener.IsListening)
{
    Write-Progress -Activity "Listening..." -PercentComplete $counter -CurrentOperation "not busy" -Status "Waiting For Request."
    if( $task -eq $null ) {
        $task = $listener.GetContextAsync()
    }
    
    if( $task.IsCompleted ) {
        Write-Progress -Activity "Listening..." -PercentComplete $counter -CurrentOperation "processing" -Status "Request Accepted."
        $context = $task.Result
        $task = $null
        #$task = $listener.GetContextAsync()
        $requestUrl = $context.Request.Url
        $response = $context.Response
        
        Write-Host ''
        Write-Host "> $requestUrl"
     
        $localPath = $requestUrl.LocalPath
        $localPath = ($localPath) -replace '//','/' 
        
        # special cases
        if ($localPath -eq "/about" ) {
            Send-TextResponse $response "running"
            $response.Close()
            continue;
        }
        
        if ($localPath -eq "/quit" ) {
            Write-Host "`nQuitting..."
            $response.Close()
            break;
        }
        
        if ($localPath -eq "/restart" ) {
            $global:restart = $true
            $response.Close()
            break;
        }
        
        $filePath = Get-LocalFilename $requestUrl
        
        Write-Host ">>>> $filePath "
        
        if( test-path $filePath ) {
            $filePath = (resolve-path $filePath).Path
            Send-FileResponse  $response $filePath
        } else {
            $response.StatusCode = 404
        }

        $response.Close()
      
        $responseStatus = $response.StatusCode
        Write-Host "< $responseStatus"
    }
    
      
    if( $global:restart )  { 
        break;
    } else {
        $counter += 0.1
        if( $counter -gt 100 ){
            $counter = 0
        }
        Sleep -Milliseconds $sleep
    }
} 

Get-EventSubscriber | Unregister-Event
$listener.Stop()
 
if( $global:restart ) {
    Write-Host "`nRestarting" 
    . "$PSScriptRoot\$($MyInvocation.MyCommand.Name)"   
} else {
    Write-Host "`nFinished."
}

