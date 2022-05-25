<#

	PowerShell, SqlBulkCopy and RunSpaces Speed Test
	
	-- To be used for speed testing purposes with million.csv --
	-- Will drop and recreate specified database if it exists --
	
	This script will
	- Automatically download the million row dataset if it doesn't exist
	- Drop the specified database if it exists
	- Recreate it with import optimized settings
	- Create a table suitable for the dataset
	- Import really quickly

#>
# Set variables
$sqlserver = "sql2012-super"
$database = "pssqlbulkcopy"
$table = "longsandlats"
$csvfile = "$([Environment]::GetFolderPath('MyDocuments'))\million.csv"

# Check for CSV
if ((Test-Path $csvfile) -eq $false) {
	Write-Output "Going grab the 20MB CSV zip file from onedrive"
	Add-Type -Assembly "System.Io.Compression.FileSystem"
	$zipfile = "$([Environment]::GetFolderPath('MyDocuments'))\million.zip"
	Invoke-WebRequest -Uri http://1drv.ms/1QZybEo -OutFile $zipfile 
	[Io.Compression.ZipFile]::ExtractToDirectory($zipfile, [Environment]::GetFolderPath('MyDocuments'))
	Remove-Item $zipfile
}

<#

	SQL Section. Drops database, and recreates database.

#>

# Build the SQL Server Connection
$sqlconn = New-Object System.Data.SqlClient.SqlConnection
$sqlconn.ConnectionString = "Data Source=$sqlserver;Integrated Security=true;Initial Catalog=master;"
$sqlconn.Open()

$dbsql = "IF  EXISTS (SELECT name FROM master.dbo.sysdatabases WHERE name = N'$database')
BEGIN
	ALTER DATABASE [$database] SET  SINGLE_USER WITH ROLLBACK IMMEDIATE
	DROP DATABASE [$database]
END
CREATE DATABASE  [$database]
ALTER DATABASE [$database] MODIFY FILE ( NAME = N'$database', SIZE = 4GB )
ALTER DATABASE [$database] SET RECOVERY SIMPLE WITH NO_WAIT
ALTER DATABASE [$database] SET PAGE_VERIFY NONE
ALTER DATABASE [$database] SET AUTO_UPDATE_STATISTICS OFF
ALTER DATABASE [$database] SET AUTO_CREATE_STATISTICS OFF
"

Write-Output "Recreating database"
$dbcmd = New-Object System.Data.SqlClient.SqlCommand
$dbcmd.CommandTimeout = 60
$dbcmd.connection = $sqlconn
$dbcmd.commandtext = $dbsql
$dbcmd.executenonquery() > $null

Write-Output "Creating table"
$tablesql = "CREATE TABLE [dbo].[$table](
	[GeoNameId] [int],
	[Name] [nvarchar](200),
	[AsciiName] [nvarchar](200),
	[AlternateNames] [nvarchar](max),
	[Latitude] [float],
	[Longitude] [float],
	[FeatureClass] [char](1),
	[FeatureCode] [varchar](10),
	[CountryCode] [char](2),
	[Cc2] [varchar](255),
	[Admin1Code] [varchar](20),
	[Admin2Code] [varchar](80),
	[Admin3Code] [varchar](20),
	[Admin4Code] [varchar](20),
	[Population] [bigint],
	[Elevation] [varchar](255),
	[Dem] [int],
	[Timezone] [varchar](40),
	[ModificationDate] [smalldatetime]
)
"

$sqlconn.ChangeDatabase($database)
$tablecmd = New-Object System.Data.SqlClient.SqlCommand
$tablecmd.Connection = $sqlconn
$tablecmd.CommandText = $tablesql
$tablecmd.ExecuteNonQuery() > $null
$sqlconn.Close()
$sqlconn.Dispose()

<#

	Data processing section

#>
# Set some vars
$delimiter = "`t"
$batchsize = 2000

# Setup datatable since SqlBulkCopy.WriteToServer can consume it
$datatable = New-Object System.Data.DataTable
$columns = (Get-Content $csvfile -First 1).Split($delimiter)
foreach ($column in $columns) { 
	$null = $datatable.Columns.Add()
}

# Setup runspace pool and the scriptblock that runs inside each runspace
$pool = [RunspaceFactory]::CreateRunspacePool(1,5)
$pool.Open()
$jobs = @()
 
$scriptblock = {
   Param (
	[string]$connectionString,
	[string]$table,
    [object]$dtbatch
	  
   )   	
	$bulkcopy = New-Object Data.SqlClient.SqlBulkCopy($connectionstring, @("TableLock","KeepNulls"))
	$bulkcopy.DestinationTableName = $table
	$bulkcopy.BatchSize = 2000
	$bulkcopy.WriteToServer($dtbatch)
	$bulkcopy.Close()
	$dtbatch.Clear()
}

Write-Output "Starting insert"
$elapsed = [System.Diagnostics.Stopwatch]::StartNew()

# Use StreamReader to process csv file. Efficiently add each row to the datatable.
# Once batchsize is reached, send it off to a runspace to be processed, then empty the datatable.
 
$reader = New-Object System.IO.StreamReader($csvfile)
$connectionString = "Data Source=$sqlserver;Integrated Security=true;Initial Catalog=$database;"

while (($line = $reader.ReadLine()) -ne $null)  {
	$null = $datatable.Rows.Add($line.Split($delimiter))
	
	if ($datatable.rows.count % $batchsize -eq 0) {
	   $job = [PowerShell]::Create()
	   $null = $job.AddScript($scriptblock)
	   $null = $job.AddArgument($connectionString)
	   $null = $job.AddArgument($table)
	   $null = $job.AddArgument($datatable.Copy())
	   $job.RunspacePool = $pool
	   $jobs += [PSCustomObject]@{ Status = $job.BeginInvoke() }
	   $datatable.Clear()
	}
}

$reader.close()

# Process any remaining rows
if ($datatable.rows.count -gt 0) {
	$bulkcopy = New-Object Data.SqlClient.SqlBulkCopy($connectionstring, [System.Data.SqlClient.SqlBulkCopyOptions]::TableLock)
	$bulkcopy.DestinationTableName = $table
	$bulkcopy.BulkCopyTimeout = 0
	$bulkcopy.WriteToServer($datatable)
	$bulkcopy.Close()
	$datatable.Clear()
}

# Wait for runspaces to complete
while ($jobs.Status.IsCompleted -notcontains $true) {}
$secs = $elapsed.Elapsed.TotalSeconds

# Write out stats for million row csv file
$rs = "{0:N0}" -f [int](1000000 / $secs)
$rm = "{0:N0}" -f [int](1000000 / $secs * 60)
$mill = "{0:N0}" -f 1000000
Write-Output "$mill rows imported in $([math]::round($secs,2)) seconds ($rs rows/sec and $rm rows/min)"