<#    
    .SYNOPSIS
    Stands up a mongo replica set that consists of 1 primary, 1 secondary, 1 hidden secondary and 1 arbiter.

    .DESCRIPTION 
            
    .PARAMETER  mongoPath
    Path to mongo /bin dir.

    .PARAMETER dbRoot
    Path to dir where mongo database and logs will be stored.

    .PARAMETER replSetName
    Replica set name.

    .EXAMPLE
    PS C:\> .\StartReplicaSet-2nod-1arb.ps1 -mongodPath "C:\Program Files\MongoDB\Server\3.2\bin" 
                -dbRoot "C:\mongodb"
                -replSetName "rs0" -initReplicaSet

#>
[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)] $mongoPath,
    [Parameter(Mandatory=$true)] $dbRoot,
    [Parameter(Mandatory=$true)] $replSetName,
    [switch] $initReplicaSet
)

function Get-NodCfg($path, [string[]]$nodes){
    [System.Collections.ArrayList]$pathList = @()
    $port = 27018
    $portIndex = 0
    foreach($node in $nodes){
        $nodePort = $port + $portIndex
        Write-Debug "Checking path for $path`\$node" | Out-Null
        $nodeRoot = Join-Path -Path $path -ChildPath $node
        $nodeDataPath = Join-Path -Path $nodeRoot -ChildPath "data"
        $nodeLogPath = Join-Path -Path $nodeRoot -ChildPath "log"
        if(!(Test-Path -PathType Container -Path $nodeDataPath)){
            New-Item -ItemType Directory -Path $nodeDataPath -Force | Out-Null
            Write-Output "Created dir path: $nodeDataPath" | Out-Null
        }
        if(!(Test-Path -PathType Container -Path $nodeLogPath)){
            New-Item -ItemType Directory -Path $nodeLogPath -Force | Out-Null
            Write-Output "Created dir path: $nodeLogPath" | Out-Null
        }
        $pathList.Add(@{Name="$node";DataDir="$nodeDataPath";LogPath="$nodeLogPath\mongod.log";Port=$nodePort}) | Out-Null
        $portIndex = $portIndex + 1
    }
    # use Out-Null to suppress output from other commands
    return $pathList
}

# ensure directory path for replica set nodes
$NODE_NAMES = @("1","2","3","arb")
$nodePaths = Get-NodCfg $(Join-Path $dbRoot $replSetName) $NODE_NAMES

# fire up mongod instance for node1
$replSetMemebersCfg = "{_id:0,host:'localhost:$($nodePaths[0].Port)'}"
Start-Process "cmd.exe" "/c `"`"$mongoPath\\mongod.exe`" --port $($nodePaths[0].Port) --dbpath `"$($nodePaths[0].DataDir)`" --logpath `"$($nodePaths[0].LogPath)`" --replSet $replSetName`""
# fire up mongod instance for node2
$replSetMemebersCfg = $replSetMemebersCfg + ",{_id:1,host:'localhost:$($nodePaths[1].Port)'}"
Start-Process "cmd.exe" "/c `"`"$mongoPath\\mongod.exe`" --port $($nodePaths[1].Port) --dbpath `"$($nodePaths[1].DataDir)`" --logpath `"$($nodePaths[1].LogPath)`" --replSet $replSetName`""
# fire up mongod instance for hidden node
$replSetMemebersCfg = $replSetMemebersCfg + ",{_id:2,host:'localhost:$($nodePaths[2].Port)',hidden:true,priority:0}"
Start-Process "cmd.exe" "/c `"`"$mongoPath\\mongod.exe`" --port $($nodePaths[2].Port) --dbpath `"$($nodePaths[2].DataDir)`" --logpath `"$($nodePaths[2].LogPath)`" --replSet $replSetName`""
# fire up mongod instance for arbiter
$replSetMemebersCfg = $replSetMemebersCfg + ",{_id:3,host:'localhost:$($nodePaths[3].Port)',arbiterOnly:true}"
Start-Process "cmd.exe" "/c `"`"$mongoPath\\mongod.exe`" --port $($nodePaths[3].Port) --dbpath `"$($nodePaths[3].DataDir)`" --logpath `"$($nodePaths[3].LogPath)`" --replSet $replSetName`""

if ($initReplicaSet) {
    $mongoExe = "$mongoPath\\mongo.exe"
    $primaryNode = "localhost:$($nodePaths[0].Port)"
    $replSetInitCmd = "db.adminCommand({'replSetInitiate':{_id:'$replSetName',members:[$replSetMemebersCfg]}})"
    $rsConfCmd = "rs.conf()"
    $statsCmd = "db.adminCommand({'replSetGetStatus':1})"
    Write-Debug "$replSetInitCmd"
    # use /k param to persist open cmd window
    Start-Process "cmd.exe" "/c `"`"$mongoExe`" $primaryNode --eval $replSetInitCmd & timeout /T 2 & `"$mongoExe`" $primaryNode --eval $rsConfCmd & timeout /T 10 & `"$mongoExe`" $primaryNode --eval $statsCmd & PAUSE`""
}