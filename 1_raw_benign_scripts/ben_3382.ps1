#region script header
<# SRG - Systemhaus GmbH 
    source: 
        - https://stackoverflow.com/questions/46400234/encrypt-string-with-the-machine-key-in-powershell
#>
#endregion

[bool] $private:_royal = $true
#royal update local key
function Use-RoyalKey {
    <#
        .SYNOPSIS
            [bool] Update-RoyalKey -Hive <[hashtable] hive>
        .DESCRIPTION
            generates random unique maschine id as private key to local drive, encrypted in machine scope  
        .EXAMPLE
            Update-RoyalKey -Hive $RoyalHive | Write-Host
    #> 
    param(
        # [hashtable] hive metadata (see: documentation in royal document)
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 0)]
        [hashtable] $Hive
    )
    #runtime variables
    [bool] $assert = $true
    [bool] $new = $false
    [string] $key = $null
    try {
        if(-not (Test-Path $Hive.Key.File)){
            $new = $true
        }
        if($Hive.Develop){
            $Hive.Key.File = "$($Hive.Key.File).dev"
        }
        if($new){
            $key = (-join ((48..57) + (97..122) | Get-Random -Count 32 | ForEach-Object {[char]$_})) #random generated string
            if($Hive.Develop){
                Write-Debug "royal.update.ps1: Update-RoyalKey | KEY: $key"
                $key | Out-File "$($Hive.Key.File).raw"  
            }
            $Hive.Key.Hash = Get-Base64 -String $key 
            $key = Protect-WithMachineKey -String $key
            if($Hive.Debug -or $Hive.Develop){
                Write-Host "royal.update.ps1: Update-RoyalKey | KEY GENERATED: $key"       
            }
            $key | Out-File $Hive.Key.File
            Write-Host "royal.update.ps1: Update-RoyalKey | KEY GENERATED" 
        }
        $key = Get-Content -Path $Hive.Key.File
    }
    catch {
        Write-Warning "royal.update.ps1: Update-RoyalKey | exeption while royal key update"
        $assert = $false
    }
    finally{
        if($assert){
            Write-Debug "royal.update.ps1: Update-RoyalKey | KEY"
        }
    }
    return $key
}
#royal update hive
function Update-RoyalHive {
    <#
        .SYNOPSIS
            [bool] Update-RoyalHive -Hive <[hashtable] hive>
        .DESCRIPTION
            generates hive on local drive, encrypted in user scope  
        .EXAMPLE
            Update-RoyalHive -Hive $RoyalHive | Write-Host
    #> 
    param(
        # [hashtable] hive metadata (see: documentation in royal document)
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 0)]
        [hashtable] $Hive
    )
    #runtime variables
    [bool] $assert = $true
    try{
        [string] $key = Use-RoyalKey -Hive $Hive
        $Hive.Hash = Get-Base64 -String "$key|$(ConvertTo-Json $Hive.Royal -Depth Use-JsonDepth)"
        $Hive.Namespace = "$(Use-Namespace).$($Hive.Name.ToLowerInvariant())"
        $json = ConvertTo-Json $Hive -Depth Use-JsonDepth
        $json | Protect-WithKey | Out-File -Path $Hive.Self
    } catch{
        Write-Warning "royal.update.ps1: Update-RoyalHive | exeption while royal hive update"
        $assert = $false
    } finally{
        if($assert){
            Write-Debug "royal.update.ps1: Update-RoyalHive | OK"
        }
    }
    return $Hive
}

#royal update function
function Update-Royal{
    <#
        .SYNOPSIS
            [bool] Update-Royal -Hive <[hashtable] hive>
        .DESCRIPTION
            clones git repository to local drive
        .EXAMPLE
            Update-Royal -Hive $RoyalHive | Write-Host
    #> 
    param(
        # [hashtable] hive metadata (see: documentation in royal document)
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 0)]
        [hashtable] $Hive
    )
    #runtime variables
    [bool] $private:local = $LocalRepositoryIfPossible
    [bool] $private:run = $true
    # check folder structure
    try{
        #check folder structure, create if missing
        if(Test-Path $Hive.Path){
            foreach($item in $Hive.Structure){
                if(-not (Test-Path "$($Hive.Path)\$($item.Folder)")){
                    New-Item -Path "$($Hive.Path)\$($item.Folder)" -ItemType Directory
                }
            }
        }
        #check local repository
        if($local){
            if(Test-Path $Hive.Repository.Local){
                foreach($item in $Hive.Structure){
                    foreach($file in $item.Files){
                        if(-not (Test-Path "$($Hive.Path)\$($item.Folder)\$($file)")){
                            $local = $false
                        }
                    }
                }
            }
        }
    } catch{
        Write-Warning "royal.update.ps1: Update-Royal | exeption while structure creation and validation" #skip execution
        $run = $false
    }
    # run
    if(-not $run){
        Write-Debug "royal.update.ps1: Update-Royal | update not executed"
    } else{
        #update local
        if($local){
            try{
                foreach($item in $Hive.Structure){
                    foreach($file in $item.Files){
                        [System.IO.File]::Copy("$($Hive.Path)\$($item.Folder)\$file","$($Hive.Path)\$($item.Folder)\$file", $true) > $null
                        Write-Debug "royal.update.ps1: Update-Royal | copy $file from local repository"
                    }
                }
                Write-Debug "royal.update.ps1: Update-Royal | update executed from local repository"
            } catch{
                Write-Warning "royal.update.ps1: Update-Royal | exeption while update from local repository"
                if(-not $LocalRepositorySkipIfNotPossible){
                    $local = $false #do online update
                    Write-Debug "royal.update.ps1: Update-Royal | update from local repository failed, switched to online repository"
                }
            } 
        }
        #update online
        if(-not $local){
            try{
                #
                $uri = "$($Hive.Repository.Uri)/$($Hive.Repository.Source)/$($Hive.Repository.Branch)"
                #
                $webclient = new-object System.Net.WebClient
                #
                foreach($item in $Hive.Structure){
                    foreach($file in $item.Files){
                        $webclient.DownloadFile("$uri/$($item.Folder)/$file", "$($Hive.Path)\$($item.Folder)\$file") > $null
                        Write-Debug "royal.update.ps1: Update-Royal | fetch $file from online repository ($uri)"
                    }
                }
                Write-Debug "royal.update.ps1: Update-Royal | update executed from online repository"
            } catch{
                Write-Warning "royal.update.ps1: Update-Royal | exeption while update from online repository"
            } 
        }
    }
    #
    return $Hive 
}
#auto update on execution
try{ 
    Set-Variable -Name Royal -Value "$env:AppData\code4ward" -Option Constant #check if royal set with constant option 
    $_royal = $false #if royal is not set skip execution silently
}
catch{
    Write-Debug "$Royal\..\royal.update.ps1 update invoked" #continue execution
}
finally{
    if(-not $_royal){
        Write-Warning "$Royal\..\royal.update.ps1 update invoked without initialization" #skip execution silently
    } else{
        try{
            Set-Variable -Name RoyalHive -Value @{} -Option Constant #check if hive set with constant option
            $_royal = $false #if hive is not set skip execution silently
        }
        catch{
            Write-Debug "$Royal\..\royal.update.ps1 update initialized" #continue execution, run update
        }
        finally{
            if(-not $_royal){
                Write-Warning "$Royal\..\royal.update.ps1 update invoked without initialization" #skip execution silently
            } else{
                Update-Royal -Hive $RoyalHive #run update
                Write-Debug "$Royal\..\royal.update.ps1 update finished" #continue execution, run update
            }
        }
    }
}
#
$_royal = $null #executed, dispose