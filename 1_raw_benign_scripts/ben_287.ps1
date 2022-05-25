<#
.NOTES
Apply-SIGredMitigation.ps1, version 1.0.1
Copyright (C) 2020 Colin Cogle <colin@colincogle.name>
Downloaded from https://gist.github.com/rhymeswithmogul/36a815c3c8336bfab3b0ef3bbe7955c3

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as
published by the Free Software Foundation, either version 3 of the
License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.

.SYNOPSIS
Mitigates the SigRed attack.

.DESCRIPTION
On July 14, 2020, Microsoft released a security update for the issue described
in CVE-2020-1350 | Windows DNS Server Remote Code Execution Vulnerability. This
advisory describes a Critical Remote Code Execution vulnerability that affects
Windows servers that are configured to run the DNS Server role.  We strongly
recommend that server administrators apply the security update at their earliest
convenience.

A registry-based workaround can be leveraged to help protect an affected Windows
server, and it can be implemented without requiring an administrator to restart
the server. Because of the volatility of this vulnerability, administrators may
have to implement the workaround before applying the security update in order to
enable them to update their systems by using a standard deployment cadence.

TCP-based DNS response packets that exceed the recommended value will be dropped
without error, so it is possible that some queries may not be answered. This could
result in an unanticipated failure. A DNS server will only be negatively impacted
by this workaround if it receives valid TCP responses that are greater than allowed
in the previous mitigation (over 65,280 bytes).

The reduced value is unlikely to affect standard deployments or recursive queries,
but a non-standard use-case may be present in a given environment. To determine
whether the server implementation will be adversely affected by this workaround,
you should enable diagnostic logging and capture a sample set that is representative
of your typical business flow. Then, you will need to review the log files to
identify the presence of anomalously large TCP response packets.

.LINK
https://support.microsoft.com/en-us/help/4569509/windows-dns-server-remote-code-execution-vulnerability
#>

#Requires -Version 3
# for the -in operator

# Because this script may be run on Windows Server 2008 RTM, which
# doesn't support Windows PowerShell 5.1, I'm going to simply throw
# a warning if Get-HotFix isn't available.
If ($PSVersionTable.PSVersion -lt 5.1) {
	Write-Warning "Cannot detect hotfixes! Windows PowerShell 5.1 must be installed."
} Else {
	$UpdatesThatFixIt = @(
		"KB4565529",  # Windows Server 2008 (SP2)
		"KB4565536",  # Windows Server 2008 (SP2)
		"KB4565524",  # Windows Server 2008 R2 (SP1)
		"KB4565539",  # Windows Server 2008 R2 (SP1)
		"KB4565535",  # Windows Server 2012
		"KB4565537",  # Windows Server 2012
		"KB4565540",  # Windows Server 2012 R2
		"KB4565541",  # Windows Server 2012 R2
		"KB4565511",  # Windows Server 2016 and Windows Server, version 1607
		"KB4565499",  # Windows Server, version 1703
		"KB4565508",  # Windows Server, version 1709
		"KB4565489",  # Windows Server, version 1803
		"KB4558998",  # Windows Server 2019 and Windows Server, version 1809
		"KB4565483",  # Windows Server, versions 1903 and 1909
		"KB4565503"   # Windows Server, version 2004
	)
	If ($null -ne (Get-Hotfix | Where-Object {$_.HotfixID -In $UpdatesThatFixIt})) {
		Write-Output "This server has been patched against SIGred.  This device is protected."
		Exit
	} Else {
		Write-Output "This server has NOT been patched against SIGred."
	}
}

# If the Windows updates are missing, then apply manual mitigations.
# The DNS Server service will automatically be restarted, if required.
$RegistryPath = "HKLM:\SYSTEM\CurrentControlSet\Services\DNS\Parameters"
$ValueName    = "TcpReceivePacketSize"
$ValueData    = 65280  # 0xFF00

# Check and see if this server is already patched.
If ( `
	(Test-Path -Path $RegistryPath) `
	-and ($null -ne (Get-ItemProperty -Path $RegistryPath -Name $ValueName)) `
	-and ((Get-ItemProperty -Path $RegistryPath -Name $ValueName)."$ValueName" -eq $ValueData) `
) {
	Write-Output "SIGred is already mitigated on this device.  This device is protected."
}

Else
{
	Write-Output "Applying SIGred mitigations to this device."
	New-ItemProperty -Path $RegistryPath -Name $ValueName -Value $ValueData -PropertyType DWORD -Force -ErrorAction Stop | Out-Null
	Restart-Service -Name DNS -Force -ErrorAction Continue
	Write-Output "Done!  This device is protected."
}