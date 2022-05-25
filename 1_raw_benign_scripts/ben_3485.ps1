### Which AD groups do I manage? 
get-adgroup -LD "(ManagedBy=$((Get-ADUser -id $env:username).distinguishedname))" | select name

### Edit the ISE profile
if (Test-Path -Path $profile){
    psedit $profile
}else{
    New-Item -Path $profile -ItemType file -Force -Value 
    psedit $profile
}

### Change ISE tab to "Untitled1.ps1*"
$psISE.CurrentPowerShellTab.Files.SetSelectedFile( ($psISE.CurrentPowerShellTab.Files | Where-Object {$_.DisplayName -eq "Untitled1.ps1*"}) )

### Database connection (SQL Server)
$Server   = 'localhost\sqlexpress'
$Database = 'MyDB'
$query    = 'select * from table'

$connection = New-Object -TypeName System.Data.SqlClient.SqlConnection
$connection.ConnectionString = "Server=$Server;Database=$Database;Trusted_Connection=True;"
$connection.Open()

$command = $connection.CreateCommand()
$command.CommandText = $query

$adapter = New-Object -TypeName System.Data.SqlClient.SqlDataAdapter $command
$dataset = New-Object -TypeName System.Data.DataSet
$rowCount = $adapter.Fill($dataset)
$connection.Close()
$result = $dataset.Tables

Return $result.rows