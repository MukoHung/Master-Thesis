Add-Type -AssemblyName System.Security;
[Text.Encoding]::ASCII.GetString([Security.Cryptography.ProtectedData]::Unprotect([Convert]::FromBase64String((type -raw (Join-Path $env:USERPROFILE foobar))), $null, 'CurrentUser'))
