#archiving script

$originalfolder="" #folder to archive
$targetfolder="" #folder to archive to
$enddate="01/01/2019" #archive everything before this date
$movecount=0

$folders = Get-ChildItem $originalfolder | 
    Where{$_.LastWriteTime -lt $enddate}

Write-Output "moving $($folders.count) objects from $originalfolder to $targetfolder ..."

foreach ($folder in $folders) {
    Move-Item -Path $folder.FullName -Destination $targetfolder

    #update progress indicator
    $movecount++
    $percentcomplete=($movecount/$folders.count)*100
    Write-Progress -Activity "moving $($folders.count-$movecount) objects from $originalfolder to $targetfolder ..." -Status "$percentcomplete% Complete" -PercentComplete $percentcomplete;
}

Write-Output "finished moving"