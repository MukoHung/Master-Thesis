<#
Notes:
This is not the cleanest, but working.

This script checks registry keys for presence of a RingCentral install, and if detected, exits.
If there are no matches, it downloads and executes another powershell script located at https://raw.githubusercontent.com/cgpdavid/public_files/main/func_install_rc_phone.ps1
The dropped script creates the c:\itsupport\ folders if not already present, downloads the most recent RingCentral installer, and then installs it MACHINE WIDE silently using msiexec
and writes a log of the install at C:\itsupport\logs\RingCentralPhone_install_log.txt

Running this script instead of directly https://raw.githubusercontent.com/cgpdavid/public_files/main/func_install_rc_phone.ps1
is required because if you run the direct script and a user has the DEFAULT per-user install of Ringcentral, they will wind up with two icons and some confusion. 
If that is not a concern, ignore this script and execute the one referenced above directly. 

Additional note:
Ringcentral phone for whatever reason touches the printspooler folder during install, and will fail if printnightmare ACL deny rules are in place. The above script bypasses it so that the install completes.


#>

#!ps
$productNames = @("*ringcentral*")
$UninstallKeys = @('HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall','HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall','HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall')
$results = foreach ($key in (Get-ChildItem $UninstallKeys) ) {foreach ($product in $productNames) {if ($key.GetValue("DisplayName") -like "$product") {[pscustomobject]@{KeyName = $key.Name.split('\')[-1];DisplayName = $key.GetValue("DisplayName");QuietUninstallString = $key.GetValue("QuietUninstallString");}}}}
if ($results){
	write-Output "Ringcentral installation detected - exiting"
	} else {
		write-Output "RingCentral not detected - proceeding"
		#func_install_rc_phone
		write-Output "Downloading and installing the latest RC phone application"
		remove-item $env:TEMP\func_install_rc_phone.ps1 -erroraction silentlycontinue
		powershell -exec bypass -c "Invoke-WebRequest https://raw.githubusercontent.com/cgpdavid/public_files/main/func_install_rc_phone.ps1 -OutFile $env:TEMP\func_install_rc_phone.ps1"
		powershell -c ". $env:TEMP\func_install_rc_phone.ps1;"
		write-output "Done"
		}
