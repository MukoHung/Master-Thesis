param([string] $PfxFilePath, $Password)

# You may provide a [string] or a [SecureString] for the $Password parameter.

$absolutePfxFilePath = Resolve-Path -Path $PfxFilePath
Write-Output "Importing store certificate '$absolutePfxFilePath'..."

Add-Type -AssemblyName System.Security
$cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2
$cert.Import($absolutePfxFilePath, $Password, [System.Security.Cryptography.X509Certificates.X509KeyStorageFlags]"PersistKeySet")
$store = new-object system.security.cryptography.X509Certificates.X509Store -argumentlist "MY", CurrentUser
$store.Open([System.Security.Cryptography.X509Certificates.OpenFlags]::"ReadWrite")
$store.Add($cert)
$store.Close()