
#---------------------------------------------------------------------
# Challenges for PowerShell 4 Foundations: Scripting - Getting Started
#---------------------------------------------------------------------


#I: Set the execution policy to Restricted, verify the setting, and execute the test-remote.ps1 
#   script locally, what happens?

#region

Set-ExecutionPolicy -ExecutionPolicy Restricted
Get-ExecutionPolicy

.\test-remote.ps1

#endregion


#II: Set the execution policy to RemoteSigned and execute the test-remote.ps1 script, attempt to execute the 
#    canPing function from outside of the script. execute test-remote.ps1 using dot-sourcing and execute
#    the canPing function from outside of the script. What did dot-sourcing the script do?


#region

Set-ExecutionPolicy -ExecutionPolicy RemoteSigned

.\test-remote.ps1
canPing

. .\test-remote.ps1
canPing

#endregion


#III: Set the execution policy to AllSigned and execute the test-remote.ps1 script, generate a self-signed 
#     certificate and sign the test-remote.ps1 script, view the script definition to verify the signature
#     and execute test-remote.ps1.
#
#  1. Set the execution policy to AllSigned and execute the test-remote.ps1 script... this should fail.
#  2. Generate a self-signed certificate using makecert.exe
#  3. Local CA: makecert -n "CN=PowerShell Local Certificate Root" -a sha1 -eku 1.3.6.1.5.5.7.3.3 -r -sv root.pvk root.cer -ss Root -sr localMachine
#  4. Self Cert: makecert -pe -n "CN=PowerShell User" -ss MY -a sha1 -eku 1.3.6.1.5.5.7.3.3 -iv root.pvk -ic root.cer
#  5. Sign the script using Set-AuthenticodeSignature and the certificate (retrive using cert provider)

#region

Set-ExecutionPolicy -ExecutionPolicy AllSigned
.\test-remote.ps1

makecert -n "CN=PowerShell Local Certificate Root" -a sha1 -eku 1.3.6.1.5.5.7.3.3 -r -sv root.pvk root.cer -ss Root -sr localMachine
makecert -pe -n "CN=PowerShell User" -ss MY -a sha1 -eku 1.3.6.1.5.5.7.3.3 -iv root.pvk -ic root.cer

$cert = @(Get-ChildItem cert:\CurrentUser\My -CodeSigningCert)[0]
Set-AuthenticodeSignature .\test-remote.ps1 $cert

.\test-remote.ps1

#endregion
