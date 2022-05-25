$prefix = "customer-sitecorelogin-"
$packagePath = "R:\"
$packageFilter = "*Core.dacpac"
$dbowner = "Sitecore"

$sqlcmd = "C:\Program Files\Microsoft SQL Server\Client SDK\ODBC\130\Tools\Binn\sqlcmd.exe"
$sqlpackage = "C:\Program Files (x86)\Microsoft SQL Server\140\DAC\bin\sqlpackage.exe"

$ErrorActionPreference = "STOP"

$files = Get-ChildItem -Path $packagePath -Filter $packageFilter
$files | ForEach-Object {
    $dacPath = $_.FullName
    $dbName = ("{0}{1}" -f $prefix, $_.BaseName.Replace("Sitecore.", "sc_"))
    Write-Host "Deploy $dacPath to $dbName"

    & $sqlpackage /Action:Publish /SourceFile:$dacPath /TargetServerName:. /TargetDatabaseName:$dbName

    & sqlcmd -d $dbName -Q "EXEC sp_changedbowner '${dbowner}'"
}

