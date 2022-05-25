<#Zawartość hi.ps1#>
$name=Read-Host "Enter your name"
Write-Host "Hi $name!"
<#Koniec zawartości hi.ps1#>

cd D:\script
hi.ps1 <#Jeśli chcemy wywołać skrypt musimy podać ścieżkę bezwzględną albo względną .\ bo inaczej wyskoczy błąd#>
.\hi.ps1 <#Tym razem też nie uruchomimy bo zabrania tego funkcja ExecutionPolicy. Uruchomić możemy tylko podpisane skrypty#>


Get-ExecutionPolicy
Set-ExecutionPolicy RemoteSigned <#RemoteSigned Pozwala na uruchomienie skryptów niepodpisanych  pod  warunkiem że są składowane lokalnie na dysku#>
.\hi.ps1

Get-ExecutionPolicy
Set-ExecutionPolicy AllSigned -Force
.\hi.ps1
 
 
 <#LAB#>

Get-WMIObject win32_Processor | Select CurrentClockSpeed <#Utwórz skrypt zawierający następujące polecenie#>
"Get-WMIObject win32_Processor | Select CurrentClockSpeed" | Out-File D:\script\MyScript.ps1 <#Zapisz skrypt na dysku w pliku#>
Get-ExecutionPolicy <#Sprawdź Execution Policy#>
Set-ExecutionPolicy AllSigned <#Zmień Execution Policy na AllSigned#>
D:\script\MyScript.ps1 <#Spróbuj uruchomić skrypt korzystając ze ścieżki bezwzględnej#>
.\MyScript.ps1 <# i względnej#>

powershell.exe -ExecutionPolicy RemoteSigned <#W cmd.exe - uruchom powershell.exe przekazując do niego parametr pozwalający na uruchamianie lokalnych niepodpisanych skryptów #>

Set-ExecutionPolicy RemoteSigned <#Zmień Execution Policy na RemoteSigned#>
D:\script\MyScript.ps1 <#Spróbuj uruchomić skrypt korzystając ze ścieżki bezwzględnej#>
.\MyScript.ps1 <# i względnej#>

<#New-SelfSignedCertificate -Type Custom -Subject "CN=PowerShell Local CA" -KeyUsage DigitalSignature -KeyAlgorithm RSA -CertStoreLocation "Cert:\LocalMachine\Root"#>