#Reference: http://michaellwest.blogspot.com/2013/03/add-font-to-powershell-console.html
#Reference: http://support.microsoft.com/default.aspx?scid=KB;EN-US;Q247815 This explains why we name it 000
Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Console\TrueTypeFont' #Get the properties of TTF
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Console\TrueTypeFont' -Name 000 -Value 'Source Code Pro' #Set it to SCP
Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Console\TrueTypeFont' #Check to see if we properly set it so that SCP is an option