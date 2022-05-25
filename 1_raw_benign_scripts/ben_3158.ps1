function Remove-FromPSModulePath{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true)][String]$Path="C:\admin\modules"
    )
    if ($env:PSModulePath.split(";") -contains $Path){
        $NewValue = (($env:PSModulePath).Split(";") | ? { $_ -ne $Path }) -join ";"
        [Environment]::SetEnvironmentVariable("PSModulePath", $NewValue, "Machine")
        $env:PSModulePath = [System.Environment]::GetEnvironmentVariable("PSModulePath","Machine")
        write-verbose "$Path removed. Restart the prompt for the changes to take effect." 
    }else{
        write-verbose "$Path is not present in $env:psModulePath"
    }

}

Function Add-TooPSModulePath {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true)][String]$Path
    )
    if (!($env:PSModulePath.split(";") -contains $Path)){
        $Current = $env:PSModulePath
        [Environment]::SetEnvironmentVariable("PSModulePath",$Current + ";" + $Path, "Machine")
        $env:PSModulePath = [System.Environment]::GetEnvironmentVariable("PSModulePath","Machine")
    }else{
        write-verbose "$Path is already present in psMOdulePath $env:psModulePath"
    }
}

Function Set-PSModulePathDefaults{
    [cmdletbinding()]
    Param()

    [Environment]::SetEnvironmentVariable("PSModulePath","","Machine")
    $env:PSModulePath = [Environment]::GetEnvironmentVariable("PSModulePath","Machine")
}