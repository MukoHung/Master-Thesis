$Gfile = Read-Host "GPACKER's Unpacker, please enter a filename, no extension: "
$UnpackLocation = Read-Host "Directory to unpack in: "
$Gfile = $Gfile + ".gpacker"
# PREPERATION
"$file_data_listdownloader = Get-Content " + $Gfile | Out-File -FilePath C:\gpacker.ps1
"cd " + $UnpackLocation | Out-File -FilePath C:\gpacker.ps1 -Append
$file_data_listdownloader = Get-Content "gpackerlist"
"wget " + $file_data_listdownloader[0] | Out-File -FilePath C:\gpacker.ps1 -Append
"$file_data_listdownloader = Get-Content 'gpackerlist'" | Out-File -FilePath C:\gpacker.ps1 -Append
"$lineno = 0" | Out-File -FilePath C:\gpacker.ps1 -Append
"DO" | Out-File -FilePath C:\gpacker.ps1 -Append
"{" | Out-File -FilePath C:\gpacker.ps1 -Append
"if ($line -eq 'EXIT') {" | Out-File -FilePath C:\gpacker.ps1 -Append
"echo 'End of list...'" | Out-File -FilePath C:\gpacker.ps1 -Append
"}" | Out-File -FilePath C:\gpacker.ps1 -Append
"else {" | Out-File -FilePath C:\gpacker.ps1 -Append
"$dload = $file_data_listdownloader[" + $lineno + "]" + " | Out-File -FilePath C:\gpacker.ps1" | Out-File -FilePath C:\gpackerx.ps1 -Append
"wget " + $dload | Out-File -FilePath C:\gpackerx.ps1 -Append
"}" | Out-File -FilePath C:\gpacker.ps1 -Append
"gpackerx.ps1" | Out-File -FilePath C:\gpackerx.ps1 -Append
"$lineno = $lineno + 1" | Out-File -FilePath C:\gpacker.ps1 -Append
"} Until ($line -eq 'EXIT')" | Out-File -FilePath C:\gpacker.ps1 -Append
# PREPERATION



