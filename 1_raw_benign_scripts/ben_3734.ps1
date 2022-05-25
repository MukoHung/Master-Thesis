# Michael Maher
# 25/9/15
# Sign Script
# Usage: signScript.ps1 <path to script>

param (
$myScript = $(throw "Please specify a path to the script
For Example: .\signScript c:\scripts\archiveSecLog.ps1")
)

 If(!(Test-path $myScript)) {Write-Host "Path not found:" $myScript 
 Exit}

$cert=(dir cert:currentuser\my\ -CodeSigningCert)
Set-AuthenticodeSignature $myScript $cert -TimestampServer http://timestamp.verisign.com/scripts/timstamp.dll


