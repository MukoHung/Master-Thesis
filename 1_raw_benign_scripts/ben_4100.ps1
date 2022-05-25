Function Test-LDAPS {
[CmdletBinding()]
    param (
        [Parameter(Mandatory=$True)]
	[string]$ADServer
    )
  $LDAPS = "LDAP://" + $ADServer + ":636"
  try {
   $global:Connection = [ADSI]($LDAPS)
  } 
  Catch {
  }
  If ($Connection.Path) {
    Write-Host "Active Directory server correctly configured for SSL, test connection to $($LDAPS) completed."
  } 
  Else {
    Write-Host "Active Directory server not configured for SSL, test connection to $($LDAPS) did not work."
 }
} # End Test-LDAPS
