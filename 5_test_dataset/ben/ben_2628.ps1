## Import a diff file
$d = Import-Clixml .\diff2016-05-20.xml

## Write some Html stuff
$d | ?{$_.SideIndicator -eq "=>"} | % {
  Write-Host "<li><b>$($_.outerText):</b> </li>"
}