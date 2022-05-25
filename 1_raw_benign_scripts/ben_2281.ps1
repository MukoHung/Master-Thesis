# Create registry Key
New-Item -Path "HKCU:\Software\Locky" -ItemType Key

# Setting ACL
$a = whoami
$acl = Get-Acl HKCU:\SOFTWARE\Locky
$rule = New-Object System.Security.AccessControl.RegistryAccessRule ($a,"FullControl","Deny")
$acl.SetAccessRule($rule)
$acl | Set-Acl -Path HKCU:\SOFTWARE\Locky
