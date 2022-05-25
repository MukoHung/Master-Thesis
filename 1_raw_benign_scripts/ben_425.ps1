$date = Get-Date -UFormat %Y-%m-%d;
$source = "C:\inetpub\wwwroot\site\Website"
$dest = "C:\Backup\IIS\site_$date"
$exclude = @('temp','app_data')
$destzippath = "C:\Backup\IIS\site\archive_$date.zip"

Write-Host "File backup started."

if(!(Test-Path -Path $dest)) {
    New-Item -ItemType directory -Path $dest;

Write-Host "Source: " $source 
Write-Host "Destination: " $destzippath 

Write-Host "Scanning files ..."
Write-Host "Scanning completed."

Write-Host "Copying files..."

Get-ChildItem $source -Recurse -Exclude $exclude | Copy-Item -Destination {Join-Path $dest $_.FullName.Substring($source.length)}

Add-Type -assembly "system.io.compression.filesystem"

If(Test-path $destzippath) {Remove-item $destzippath}
[io.compression.zipfile]::CreateFromDirectory($dest, $destzippath)

Remove-Item -Recurse -Force $dest

Write-Host "File backup completed."
}