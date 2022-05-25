# Connect to web-box
Enter-PsSession -ComputerName 192.0.32.10 -Credential "WS0114\Administrator"

# Prepare dependencies
Import-Module ServerManager
Import-Module WebAdministration
Import-Module BitsTransfer

# Install IIS
Add-WindowsFeature Web-Server

# Setup .NET 4.0
Start-BitsTransfer http://download.microsoft.com/download/9/5/A/95A9616B-7A37-4AF6-BC36-D6EA96C8DAAE/dotNetFx40_Full_x86_x64.exe
Start-Process .\dotNetFx40_Full_x86_x64.exe -ArgumentList "/q /norestart" -Wait

# Set IIS to user .NET 4.0 by default
Set-WebConfigurationProperty /system.applicationHost/applicationPools/applicationPoolDefaults -name managedRuntimeVersion -value v4.0

# Lets create example site

New-Item "C:\inetpub\example" -ItemType Directory
New-WebSite Example -Port:8080 -PhysicalPath:"C:\inetpub\example"
Get-Url example.com -ToFile "C:\inetpub\example\index.html"
Get-Url localhost:8080/

# Bye!
Exit-PsSession
