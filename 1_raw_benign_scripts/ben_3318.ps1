########################################################################
#  Powershell Consolidation Script#  
#  Script that runs all of the  scripts
#  Created by: Brad Voris
########################################################################

# Run GPO Report
Invoke-Command {C:\inetpub\wwwroot\scripts\gporeport.ps1}

# Run AD lockout Report
Invoke-Command {C:\inetpub\wwwroot\scripts\adloreport.ps1}

# Run ADPAM Report
Invoke-Command {C:\inetpub\wwwroot\scripts\pamreport.ps1}

# Run Last Logon Report
Invoke-Command {C:\inetpub\wwwroot\scripts\llreport.ps1}

# Run Password Expiration in 10 Days Report
Invoke-Command {C:\inetpub\wwwroot\scripts\pereport.ps1}

# Run AD Group Membership Reports
Invoke-Command {C:\inetpub\wwwroot\scripts\gmreport.ps1}

# Run Password Compliance Report
Invoke-Command {C:\inetpub\wwwroot\scripts\pcreport.ps1}

# Run AD Replication Health Report
Invoke-Command {C:\inetpub\wwwroot\scripts\adrephealthreport.ps1}

# Run DNS Health Report
Invoke-Command {C:\inetpub\wwwroot\scripts\dnshealthreport.ps1}

# Run Active Users Report
#Invoke-Command {C:\inetpub\wwwroot\scripts\aureport.ps1}

# Run DHCP Report
Invoke-Command {C:\inetpub\wwwroot\scripts\dhcpreport.ps1}