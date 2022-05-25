$hactool = "$PSScriptRoot\hactool.exe"
$prodkeys = "$PSScriptRoot\prod.keys"
$firmware = "$PSScriptRoot\Firmware 10.1.0\"
$files = Get-ChildItem $firmware -Filter *.nca
$numfiles = 0
foreach ($file in $files) {
    $hacout = & $hactool -k $prodkeys -i $firmware$file | Out-String
    if($hacout -like '*Content Type:                       Meta*') {
        Get-Item $firmware$file | Rename-Item -Path $firmware$file -NewName { $_.Name -replace '.nca','.cnmt.nca' }
        $numfiles++
    }
}
Write-Host "Renamed "$numfiles " ncas"