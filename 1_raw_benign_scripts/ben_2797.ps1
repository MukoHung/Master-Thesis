# Backup postgres databases to s3
# requires AWS cli tools for windows to be initialized and installed

$transcripts = "C:\transcripts"
$s3Bucket = "s3://s3-bucket-name/s3-bucket-path/"
$csv = "output.csv"
$pguser = "postgres"
$pgpass = Get-Content "C:\Scripts\pg_pass.txt"


$timestamp = Get-Date -Format yyyy-MM-dd-hh-mm-ss

# Delete all Files in C:\transcripts older than 30 day(s)
$Daysback = "-5"
 
$CurrentDate = Get-Date
$DatetoDelete = $CurrentDate.AddDays($Daysback)
Get-ChildItem $transcripts | Where-Object { $_.LastWriteTime -lt $DatetoDelete } | Remove-Item

# start log file
Start-Transcript -Path "$transcripts\pg-backup.$timestamp.transcript.txt"

# get databases
$env:PGPASSWORD = $pgpass
psql -U $pguser -l -A -F "," > $csv

# remove first line 
get-content $csv |
    select -Skip 1 |
    set-content "$csv-temp"
move "$csv-temp" $csv -Force

$result = Import-Csv $csv
Remove-Item $csv

Write-Host "Databases queried: $($result.length)"


# async upload task
# delete it when done
$s3UploadTask = {
    param ($filePath, $s3Path)
    aws s3 cp $filePath $s3Path
}

ForEach($row in $result){
    $db = $row.Name
    Write-Host "Processing database $(1 + $result::IndexOf($result, $row)) of $($result.length): $db"

    # skip rows that aren't databases
    if(!$db.Contains('/') -and !$db.Contains(')')){

        $dumpfile = "$($env:TEMP)\$timestamp.$($db).dump"

        # dump it 
        Write-Host "Creating Dump File: $dumpfile"
        pg_dump -U $pguser --format=t --file=$dumpfile $db 
        Write-Host "Dump File Created."

        # back it up to s3
        Write-Host "Uploading to S3..."
        Start-Job -ScriptBlock $s3UploadTask -ArgumentList @($dumpfile,$s3Bucket)

        Get-Job
    } else {
        Write-Host "Skipping invalid entry $db"
    }
}

# wait for jobs to finish
Write-Host "Waiting for jobs to finish..."
Wait-Job -Any 

# clean up old dump files
Write-Host "Cleaning up dump files..."
Get-ChildItem $env:TEMP | Where-Object { $_ -like '*.dump' } | Remove-Item

Write-Host "Script Complete."

Stop-Transcript