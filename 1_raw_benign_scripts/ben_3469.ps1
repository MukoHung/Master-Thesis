function global:Script-Database([string]$server, [string]$dbname, [string]$filename) {
	add-type -AssemblyName "Microsoft.SqlServer.ConnectionInfo, Version=11.0.0.0, Culture=neutral, PublicKeyToken=89845dcd8080cc91" | out-null
	add-type -AssemblyName "Microsoft.SqlServer.Smo, Version=11.0.0.0, Culture=neutral, PublicKeyToken=89845dcd8080cc91" | out-null
	add-type -AssemblyName "Microsoft.SqlServer.SMOExtended, Version=11.0.0.0, Culture=neutral, PublicKeyToken=89845dcd8080cc91" | out-null

	$SMOserver = New-Object ('Microsoft.SqlServer.Management.Smo.Server') -argumentlist $server

	$db = $SMOserver.databases[$dbname]

	$opts = New-Object ('Microsoft.SqlServer.Management.Smo.ScriptingOptions')
	$opts.AppendToFile = $True
	$opts.ScriptSchema = $True
	$opts.ScriptData = $True
	$opts.ScriptDrops = $False
	$opts.TargetServerVersion = [Microsoft.SqlServer.Management.Smo.SqlServerVersion]::Version105
	$opts.Triggers = $True
	$opts.ClusteredIndexes = $True
	$opts.NonClusteredIndexes = $True
	$opts.Indexes = $True
	$opts.FullTextIndexes = $True
	$opts.DriAll = $True
	$opts.ToFileOnly = $True

	$opts.FileName = $filename

	echo '' | Out-File $opts.FileName

	foreach($tb in $db.Tables | where {!($_.IsSystemObject)}) {
		echo $tb.Name
		$tb.EnumScript($opts)
	}
}
