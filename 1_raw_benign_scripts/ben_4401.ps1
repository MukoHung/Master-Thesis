<#
.NOTES
How to use: Open Visual Studio, go to Tools – External Tools to bring up the External Tools dialog, add a new tools menu with the following configuration:
Title: Manage User Secrets (Or whatever you want)
Command: C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe (Path to powershell.exe)
Arguments: Path-to-this-script(e.g. D:\VisualStudioTools\usersecrets.ps1)
Initial Directory: $(ProjectDir)

.PARAMETER ProjectFilePath
The csproj file's path, or keep it empty to search *.csproj file in initial directory
.PARAMETER UserSecretsId
Use the specific id instead of generating a new Guid
#>
param (
    [Parameter(Mandatory = $false, Position = 1)]
    [string] $ProjectFilePath = "",

    [Parameter(Mandatory = $false, Position = 2)]
    [string] $UserSecretsId = ""
)

function GetUserSecretsDir ($userSecretsId) {
    return "$env:APPDATA\microsoft\UserSecrets\" + $userSecretsId
}

function CreateSecretsJson($userSecretsId) {
    $dir = GetUserSecretsDir($userSecretsId)
    if (!(Test-Path -Path $dir)) {
        Write-Debug "Directory not found, create one"
        mkdir -Path $dir
    }

    $jsonPath = Join-Path $dir "secrets.json"
    if (!(Test-Path -Path $jsonPath)) {
        Write-Debug "Secrets.json not found, create one"
        Write-Output "{}" > $jsonPath
    }
}
function GenerateId {
    if ([String]::IsNullOrEmpty($UserSecretsId)) {
        return [guid]::NewGuid()
    }
    else {
        return $UserSecretsId
    }
}
# Search *.csproj in initial directory and use the first one if $ProjectFilePath is not provided
if ([String]::IsNullOrEmpty($ProjectFilePath)) {
    $csprojs = Get-ChildItem *.csproj -ErrorAction SilentlyContinue
    if ($csprojs.Length -gt 0) {
        $ProjectFilePath = $csprojs[0]
    }
    else {
        [System.Windows.Forms.MessageBox]::Show("*.csproj file not found","Error",[System.Windows.Forms.MessageBoxButtons]::OK,[System.Windows.Forms.MessageBoxIcon]::Stop)
        return
    }
}
# Read .csproj
$csprojData = [xml](Get-Content $ProjectFilePath)
$UserSecretsIdNode = $csprojData.SelectSingleNode("Project/PropertyGroup/UserSecretsId")
$TargetFramework = $csprojData.SelectSingleNode("Project/PropertyGroup/TargetFramework")
$id = ""
if ($TargetFramework -eq $null) {
    [System.Windows.Forms.MessageBox]::Show("Cannot create user secrets for old format project, please update to .NET Core csproj format","Error",[System.Windows.Forms.MessageBoxButtons]::OK,[System.Windows.Forms.MessageBoxIcon]::Stop)
    return
}
if ($TargetFramework.InnerText -like "*netstandard*") {
    [System.Windows.Forms.MessageBox]::Show("Cannot create user secrets in netstandard project","Error",[System.Windows.Forms.MessageBoxButtons]::OK,[System.Windows.Forms.MessageBoxIcon]::Stop)
    return
}

if ($UserSecretsIdNode -ne $null) {
    # Node found
    $id = $UserSecretsIdNode.InnerText
    if ([String]::IsNullOrEmpty($id)) {
        # Node found but empty, add an Id
        $id = GenerateId
        $UserSecretsIdNode.InnerText = $id
        $csprojData.Save($ProjectFilePath)
    }
}
else {
    # Node not found, create node
    $UserSecretsIdNode = $csprojData.CreateElement("UserSecretsId")
    $id = GenerateId
    $UserSecretsIdNode.InnerText = $id
    $csprojData.SelectSingleNode("Project/PropertyGroup").AppendChild($UserSecretsIdNode)
    $csprojData.Save($ProjectFilePath)
}


# Create secrets.json if not exist
CreateSecretsJson($id)

# Open explorer
Start-Process (Join-Path (GetUserSecretsDir($id)) "secrets.json")