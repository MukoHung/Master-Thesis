# Hostname
$myhost=$env:COMPUTERNAME
# Script Name
$myname=[string] ($MyInvocation.MyCommand.Name)
# Script Path
$mypath=[string] ($MyInvocation.MyCommand.Definition)
# Script Directory
$scriptdir="$($mypath.substring(0,$mypath.LastIndexOf('\')))\.."