# Updates the system hosts file without overwriting whatever's already there
# To use this script, place the url of each host file to be merged in $DirectoryOfThisScript/sources.txt and run as administrator

$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if($currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator) -eq $false){
    $shell = New-Object -ComObject Wscript.Shell
    $shell.Popup("Please run this script as administrator",0,"Error",0x0)
    exit
}

$merged = New-TemporaryFile
$header = "# BEGIN AUTOMATICALLY GENERATED HOSTS FILE BY HOSTUPDATER"
$hostfile = "C:\Windows\System32\drivers\etc\hosts"
$Old = Get-Content -Path $hostfile
Clear-Content -Path $hostfile

foreach($line in $old){
    if($line -eq $header){
        break
    }
    Add-Content -Path $merged.FullName -Value $line -Encoding Ascii
}

Add-Content -Path $merged -Value $header

Get-Content -Path $PSScriptRoot/sources.txt | ForEach-Object {
    $block = (Invoke-WebRequest -UseBasicParsing -Uri $_) -replace "`n", "`r`n"
    Add-Content -Path $merged -Value $block  -Encoding Ascii
}

Copy-Item -Path $merged.FullName -Destination $hostfile
ipconfig /flushdns