##-----[ SCRIPT BY AMAR ]-------###

$URL = "https://www.sslshopper.com/ssl-checker.html#hostname=216.58.199.174"
$iexplorer = New-Object -ComObject "internetexplorer.application"
$iexplorer.visible = $true
$iexplorer.navigate($URL)
Start-Sleep -Seconds 10
$Output = $iexplorer.Document.getElementsByTagName("td") | ?{$_.innerText -imatch "Common name:"} | Select outerText
$Output
