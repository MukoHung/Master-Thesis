# allow powershell to run scripts
# find the printer port => Get-PrinterPort / $COMportList = [System.IO.Ports.SerialPort]::getportnames() 
# create a virtual port pair printer and your virtual port using VSPD
# use your virtual port to ReadLine from printer port and save data into a text file
# then read all data from text file after one sec and WriteLine them to printer port
# BoOOOm U HAVE YOUR FOOD PAPER!!!!  
# USAGE: ./com.ps1 > C:\temp\foodLog.txt

# -----------------------------
# GETTING DATA FROM COM PRINTER 
# -----------------------------
$port = new-Object System.IO.Ports.SerialPort COM2,9600,None,8,one
$port.open()
try
{
  while($message = $port.ReadLine())
  {
    Write-Output $message
  }
}

catch [TimeoutException]
{
# Error handling code here
}

finally
{
# Any cleanup code goes here
} 


# -------------------------------------
# APP IS WRITING SOME DATA INTO PRINTER
# -------------------------------------
# PS C:\Users\VOCFU> $port = new-Object System.IO.Ports.SerialPort COM1,9600,None,8,one        
# PS C:\Users\VOCFU> $port.open()                                                                                                   
# PS C:\Users\VOCFU> $port.WriteLine("food info!") 
