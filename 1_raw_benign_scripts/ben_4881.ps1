$downloadZipUrl = "https://download.microsoft.com/download/B/D/8/BD821B1F-05F2-4A7E-AA03-DF6C4F687B07/dgreadiness_v3.6.zip"

$downloadPath = "$HOME\Downloads\dgreadiness_v3.6.zip"
$unzipPath = "$HOME\Downloads"

Invoke-WebRequest -Uri $downloadZipUrl -OutFile $downloadPath

Expand-Archive -LiteralPath $downloadPath -DestinationPath $unzipPath


echo R | &"$unzipPath\dgreadiness_v3.6\DG_Readiness_Tool_v3.6.ps1" -enable

