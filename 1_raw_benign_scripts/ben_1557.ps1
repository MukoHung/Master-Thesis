<# 
    Script schema from a database into SQL

    Example:

    PowerShell.exe .\GenerateSqlSchema.ps1
#>

Param(

    [string] $DatabaseServerInstanceName,
    [string] $DatabaseName,
    [string] $OutputFile
)

Set-PsDebug -Strict
$ErrorActionPreference = 'Stop'

[reflection.assembly]::LoadWithPartialName("Microsoft.SqlServer.Smo")  | Out-Null

$SqlInstance = New-Object ('Microsoft.SqlServer.Management.Smo.Server') $DatabaseServerInstanceName

If ($SqlInstance.Version -eq  $Null ) {
    Throw "Can't find the instance $DatabaseServerInstanceName"
}

$SqlDatabase = $SqlInstance.Databases[$DatabaseName] 

If ($SqlDatabase.Name -ne $DatabaseName) {
    Throw "Can't find the database '$DatabaseName' on server '$DatabaseServerInstanceName'"
}

$Script = New-Object('Microsoft.SqlServer.Management.Smo.Scripter') $SqlInstance

# Export options

$Script.Options.FileName = $OutputFile
$Script.Options.AnsiFile = $True
$Script.Options.ToFileOnly = $True

# Options top to bottom from SMS Advanced Scripting Options
# Taken from : https://msdn.microsoft.com/en-us/library/microsoft.sqlserver.management.smo.scriptingoptions.aspx 
# General List
$Script.Options.AnsiPadding = $True
$Script.Options.AppendToFile = $False
$Script.Options.ContinueScriptingOnError = $False
$Script.Options.ConvertUserDefinedDataTypesToBaseType = $False
$Script.Options.WithDependencies = $False
$Script.Options.IncludeHeaders = $False
$Script.Options.IncludeIfNotExists = $True
# Include System Constraint Names False
# Include Unsupported Statements False
$Script.Options.SchemaQualify = $True
$Script.Options.Bindings = $False
$Script.Options.NoCollation = $True # Script Collation False
# Script Defaults True
# Script Drop and Create Script Create
$Script.Options.ScriptDrops = $False
$Script.Options.ExtendedProperties = $False
# SQL Server 2008 R2 - https://msdn.microsoft.com/en-us/library/microsoft.sqlserver.management.smo.sqlserverversion.aspx
$Script.Options.TargetServerVersion = [Microsoft.SqlServer.Management.Smo.SqlServerVersion]::Version105 
$Script.Options.TargetDatabaseEngineType = 'SqlAzureDatabase'
$Script.Options.LoginSid = $False
$Script.Options.Permissions = $False
$Script.Options.Statistics = $True
# Script Use Database False
$Script.Options.ScriptSchema = $True
$Script.Options.ScriptData = $False
$Script.Options.ScriptOwner = $False

# Table/View Options List
$Script.Options.ChangeTracking = $False
$Script.Options.DriAllConstraints = $True
$Script.Options.ScriptDataCompression = $False
$Script.Options.DriForeignKeys = $True
$Script.Options.FullTextIndexes = $False
$Script.Options.Indexes = $True
$Script.Options.DriPrimaryKey = $True
$Script.Options.Triggers = $True
$Script.Options.DriUniqueKeys = $True

# Go !!!
Measure-Command { $Script.EnumScript(@($SqlDatabase.Tables)) }
