#Requires -Version 4.0
[CmdletBinding(DefaultParameterSetName = 'add')]
param
(
    [switch]
    [Parameter(ParameterSetName="add", Position=0, Mandatory=$true)]
    $add,
    [switch]
    [Parameter(ParameterSetName="remove", Position=0, Mandatory=$true)]
    $remove,
    [switch]
    [Parameter(ParameterSetName="add", Mandatory=$false)]
    $deploy,

    [String[]]
    [Parameter(ParameterSetName="add", Mandatory=$true)]
    [Parameter(ParameterSetName="remove", Mandatory=$true)]
    $agents = "",
    [String[]]
    [Parameter(ParameterSetName="add", Mandatory=$false)]
    [Parameter(ParameterSetName="remove", Mandatory=$false)]
    $agentprefix = "Agent",
    [string]
    [Parameter(ParameterSetName="add", Mandatory=$true)]
    [Parameter(ParameterSetName="remove", Mandatory=$true)]
    $token = "",
    [string]
    [Parameter(ParameterSetName="add", Mandatory=$true)]
    $url = "",
    [string]
    [Parameter(ParameterSetName="add", Mandatory=$true)]
    [Parameter(ParameterSetName="remove", Mandatory=$true)]
    $work = "",
    [switch]
    [Parameter(ParameterSetName="add", Mandatory=$false)]
    $runasservice
)

DynamicParam
{
    $paramDic = new-object System.Management.Automation.RuntimeDefinedParameterDictionary
    
    if ($runasservice)
    {
        $attrCollection = new-object System.Collections.ObjectModel.Collection[System.Attribute] 
        # Attribute für die Parameter definieren
        $attr = new-object System.Management.Automation.ParameterAttribute
            
        # Zugehörigkeit zum ParameterSet definieren
        $attr.ParameterSetName = "add"
        $attr.Mandatory = $true
        $attrCollection.Add($attr)

        # Parameter definieren
        $dynParam1 = new-object System.Management.Automation.RuntimeDefinedParameter("windowslogonaccount", [String], $attrCollection)
        $dynParam2 = new-object System.Management.Automation.RuntimeDefinedParameter("windowslogonpassword", [String], $attrCollection)
            
        # Parameter zum Dictionary hinzufügen
        $paramDic.Add("windowslogonaccount", $dynParam1)
        $paramDic.Add("windowslogonpassword", $dynParam2)
    }

    if ($add -and -not $deploy)
    {
        $attrCollection = new-object System.Collections.ObjectModel.Collection[System.Attribute] 
        # Attribute für die Parameter definieren
        $attr = new-object System.Management.Automation.ParameterAttribute
            
        # Zugehörigkeit zum ParameterSet definieren
        $attr.ParameterSetName = "add"
        $attr.Mandatory = $false
        $attrCollection.Add($attr)

        # Parameter definieren
        $poolParam = new-object System.Management.Automation.RuntimeDefinedParameter("pool", [String], $attrCollection)
        $PSBoundParameters["pool"] = "default"
            
        # Parameter zum Dictionary hinzufügen
        $paramDic.Add("pool", $poolParam)
    }

    if ($add -and $deploy)
    {
        $attrCollection = new-object System.Collections.ObjectModel.Collection[System.Attribute] 
        # Attribute für die Parameter definieren
        $attr = new-object System.Management.Automation.ParameterAttribute
            
        # Zugehörigkeit zum ParameterSet definieren
        $attr.ParameterSetName = "add"
        $attr.Mandatory = $true
        $attrCollection.Add($attr)

        # Parameter definieren
        $projectParam = new-object System.Management.Automation.RuntimeDefinedParameter("project", [String], $attrCollection)
        $groupParam = new-object System.Management.Automation.RuntimeDefinedParameter("group", [String], $attrCollection)
            
        # Parameter zum Dictionary hinzufügen
        $paramDic.Add("project", $projectParam)
        $paramDic.Add("group", $groupParam)
    }

    return $paramDic
}

Begin
{
    Write-Verbose "Parameter Values:"
    foreach ($key in $PSBoundParameters.Keys) {
        Write-Verbose ("    $key = $($PSBoundParameters[$key])")
    }

    function Test-IsAdmin {
        ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
    }
    if ($runasservice -and !(Test-IsAdmin))
    {
        throw "Please run this script with admin priviliges when using '-runasservice'!"
    }

    $windowslogonaccount = $PSBoundParameters.windowslogonaccount
    $windowslogonpassword = $PSBoundParameters.windowslogonpassword
    $pool = $PSBoundParameters.pool
    $project = $PSBoundParameters.project
    $group = $PSBoundParameters.group

    if ($deploy -and ([string]::IsNullOrWhiteSpace($project) -or [string]::IsNullOrWhiteSpace($group)))
    {
        throw "Please provide 'group' and 'project' when using '-deploy'!"
    }
}

Process
{
    Function Add-Agent([string] $agent)
    {
        $agentname = "$agentprefix-$agent"
        $workfolder = "$work$agent"

        if (Test-Path "$PWD\$agentname")
        {
            Write-Error "Agent folder (""$PWD\$agentname"") allready exists!"
            exit 1
        }

        if (Test-Path "$workfolder")
        {
            Write-Error "Work folder (""$workfolder"") allready exists!"
            exit 1
        }

        Write-Output "Adding agent ""$agentname""..."

        Write-Output "    Unzip agent..."

        $zip = Get-ChildItem $PWD\ -name vsts-agent-win-x64-*.zip
        if(-Not $zip)
        {
            Write-Error "Agent zip not found!"
            exit 1
        }
    
        Add-Type -Assembly "System.IO.Compression.FileSystem"
        [System.IO.Compression.ZipFile]::ExtractToDirectory("$PWD\$zip", "$PWD\$agentname")
        Write-Output "        Done."

        Write-Output "    Setup agent..."

        $addcommand = ""
        if (-not $deploy)
        {
            $addcommand = "& $PWD\$agentname\config.cmd --unattended --url $url --auth PAT --token $token --pool $pool --agent $agentname --work ""$workfolder"" --replace"
        }
        else
        {
            $addcommand = "& $PWD\$agentname\config.cmd --unattended --url $url --auth PAT --token $token --agent $agentname --work ""$workfolder"" --replace --deploymentgroup --deploymentgroupname ""$group"" --projectname ""$project"""            
        }
        
        if ($runasservice)
        {
            Write-Output "        Run as service"
            $addcommand += " --runasservice"
            if (-Not [string]::IsNullOrWhiteSpace($windowslogonaccount))
            {
                Write-Output "            Using account: $windowslogonaccount"
                $addcommand += " --windowslogonaccount $windowslogonaccount --windowslogonpassword ""$windowslogonpassword"""
            }
        }

        Write-Output $addcommand

        Invoke-Expression $addcommand

        Write-Output "        Done."
        Write-Output "    Done."
    }

    Function Remove-Agent([string] $agent)
    {
        $agentname = "$agentprefix-$agent"
        $workfolder = "$work$agent"

        if(Test-Path "$PWD\$agentname\config.cmd")
        {
            Write-Output "Removing Agent ""$agentname""..."
            Invoke-Expression "& $PWD\$agentname\config.cmd remove --unattended --auth PAT --token $token"
            Write-Output "    Done."
        }

        Write-Output "Cleanup..."
        if(Test-Path "$PWD\$agentname")
        {
            Write-Output "    Agent folder..."
            Remove-Item $PWD\$agentname -Force -Recurse
            Write-Output "        Done."
        }
    
        if(Test-Path "$workfolder")
        {
            Write-Output "    Work folder..."
            Remove-Item $workfolder -Force -Recurse
            Write-Output "        Done."
        }

        Write-Output "    Done."
    }

    $work = "$($work.TrimEnd('\'))\"
    foreach ($agent in $agents)
    {
        if ($add)
        {
            Add-Agent($agent)
        }
        elseif ($remove)
        {
            Remove-Agent($agent)
        }
    }
}
