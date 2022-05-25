# On the remote node/server:
 
winrm quickconfig -q
 
winrm set winrm/config/winrs '@{MaxMemoryPerShellMB="300"}'
 
winrm set winrm/config '@{MaxTimeoutms="1800000"}'
 
# When NOT USING a domain-based authentication (i.e., from Linux/Unix to Windows node):
winrm set winrm/config/service/auth '@{Basic="true"}'
winrm set winrm/config/service '@{AllowUnencrypted="true"}'
 
# When USING a domain-based authentication (i.e., from Windows (workstation) to Windows node):
## On the remote server/node:
#winrm set winrm/config/service/auth '@{Basic="false"}'
#winrm set winrm/config/service '@{AllowUnencrypted="false"}'