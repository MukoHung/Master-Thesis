$startfolder = "c:\data\*"
$folders = get-childitem $startfolder | where{$_.PSiscontainer -eq "True"}
"Directory Name`tDirectory Size (MB)"
foreach ($fol in $Folders){
$colItems = (Get-ChildItem $fol.fullname -recurse | Measure-Object -property length -sum)
$size = "{0:N2}" -f ($colItems.sum / 1MB)
"$($fol.name)`t$size"
}
