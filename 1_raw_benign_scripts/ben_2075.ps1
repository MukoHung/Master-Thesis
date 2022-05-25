$root = "HKCU:\Software\Borland\Delphi\7.0"
$rootDir = (ls $root\.. -Include  "7.0" -Recurse).GetValue("RootDir")

$here = Split-Path -Parent $MyInvocation.MyCommand.Path

function Update-DccLib {
    $reg = ls $root -Include "Environment Variables" -Recurse | select -First 1

    $envVars = @{ '$(DELPHI)' = $rootDir }
    $reg.Property | %{ $envVars.Add([string]::Format('$({0})',$_), $reg.Getvalue($_)) }

    $paths =
        foreach ($p in (ls $root -Include "Library" -Recurse | select -First 1).getvalue("Search Path").split(";")) {
            foreach ($k in $envVars.Keys) {
                $p = $p.Replace($k, $envVars[$k])
            }
            $p
        }

    
    $paths | Out-File -encoding default "$here/dcc-lib.txt"
}

function Invoke-Dcc {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [IO.FileInfo[]]$ProjectFiles,
       
        [string]$OutDir,
         
        [switch]$Quiet,
        
        [switch]$Update
    )
    
    begin {
        $configPath = "$here/dcc-lib.txt"
        
        if ($update -or (-not (Test-Path $configPath))) {
            Update-DccLib
        }
        
        $curDir = pwd
        
        $paths = Get-Content $configPath
        
        function ReadIncludes([IO.FileInfo]$path) {
            $includes = 
                foreach ($m in (Select-String -Path $path.FullName -Pattern "SearchPath=(.+)$" | %{ $_.Matches })) {
                    $m.Groups[1].Value
                }
            
            @{ I=($includes -join ';'); U=($includes -join ';') }
        }
        function PrepareParams {
            if ($OutDir) {
                if (-not (Test-Path $OutDir)) {
                    mkdir $OutDir > $null
                }
                
                @{ E=(Resolve-Path "$($curDir.Path)/$($OutDir)") }
            }
            if ($Quiet) { "-Q" }
            
            @{ U=($paths -join ';') }
        }
        $commonArgs = (PrepareParams)
        $command = "$rootDir/Bin/Dcc32.exe"
    }
    
    process {
        foreach ($project in $ProjectFiles) {
            cd "$($project.Directory.FullName)"
                       
            $includes = ReadIncludes ([IO.Path]::ChangeExtension($project.FullName, 'dof'))
            
            $args = 
                foreach ($a in ($commonArgs + @($includes) | %{ $_.GetEnumerator() } | Group Name)) {
                    $values = $a.Group | %{ $_.Value }
                    if ($values.Length) { '"-{0}{1}"' -F $a.Name, ($values -join ';') }
                }

            Write-Verbose "$rootDir/Bin/Dcc32 $args $project"

            & "$command" "$args" "$($project.FullName)" 
        }
    }
    end {
        cd "$curDir"
    }
}
