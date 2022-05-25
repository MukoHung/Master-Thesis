#Requires -Version 5 -Module NetSecurity -RunAsAdministrator
<#
.SYNOPSIS
Create-MitigationFirewallRules - Creates Windows Firewall rules to mitigate certain app whitelisting bypasses and to prevent command interpreters from accessing the Internet

.DESCRIPTION 
A script to automatically generate Windows Firewall with Advanced Security outbound rules
to prevent malware from being able to dial home.

These programs will only be allowed to communicate to IP addresses within the private IPv4 RFC1918 ranges:
https://en.wikipedia.org/wiki/Private_network#Private_IPv4_address_spaces

The method I used to blacklist everything other than RFC1918 addresses was copied from a blog post by https://twitter.com/limpidweb
https://limpidwebblog.blogspot.com.au/2016/10/a-shower-leads-to-powershell-puking.html

Application Whitelisting bypasses sourced from Casey Smith's list here:
https://github.com/subTee/ApplicationWhitelistBypassTechniques/blob/master/TheList.txt

This script could be modified to write these rules to an existing GPO using the -GPOSession parameter on New-NetFirewallRule

PowerShell 5.0 is required because I'm using Classes

.OUTPUTS
Nothing

.EXAMPLE
Create-MitigationFirewallRules

.LINK
https://gist.github.com/dstreefkerk/800a9e0a22a6242a28b058be423cf0ba

.NOTES
Written By: Daniel Streefkerk
Website:	http://daniel.streefkerkonline.com
Twitter:	http://twitter.com/dstreefkerk
Todo:       Nothing at the moment

Change Log
v1.0, 24/10/2017 - Initial version
#>

$rules = @()

Class FirewallRule {
    [string]$DisplayName
    [string]$Program
    [string]$Description
    [string]$Action = 'Block'
    [string]$LocalAddress = 'Any'
    [string]$Direction = 'Outbound'
    [string[]]$RemoteAddress = @('0.0.0.0-9.255.255.255','11.0.0.0-172.15.255.255','172.32.0.0-192.167.255.255','192.169.0.0-255.255.255.255')
}

# 32 and 64 bit versions of cmd.exe
$rules += New-Object FirewallRule -Property @{DisplayName='Block Internet Access - cmd.exe';Program='%SystemRoot%\SysWOW64\cmd.exe'}
$rules += New-Object FirewallRule -Property @{DisplayName='Block Internet Access - cmd.exe (x64)';Program='%SystemRoot%\System32\cmd.exe'}

# conhost.exe - not sure if this is needed, but blocking anyway
$rules += New-Object FirewallRule -Property @{DisplayName='Block Internet Access - conhost.exe (x64)';Program='%SystemRoot%\System32\conhost.exe'}

# 32 and 64 bit versions of cscript.exe
$rules += New-Object FirewallRule -Property @{DisplayName='Block Internet Access - cscript.exe';Program='%SystemRoot%\SysWOW64\cscript.exe'}
$rules += New-Object FirewallRule -Property @{DisplayName='Block Internet Access - cscript.exe (x64)';Program='%SystemRoot%\System32\cscript.exe'}

# 32 and 64 bit versions of wscript.exe
$rules += New-Object FirewallRule -Property @{DisplayName='Block Internet Access - wscript.exe';Program='%SystemRoot%\SysWOW64\wscript.exe'}
$rules += New-Object FirewallRule -Property @{DisplayName='Block Internet Access - wscript.exe (x64)';Program='%SystemRoot%\System32\wscript.exe'}

# 32 and 64 bit versions of mshta.exe
$rules += New-Object FirewallRule -Property @{DisplayName='Block Internet Access - mshta.exe';Program='%SystemRoot%\SysWOW64\mshta.exe'}
$rules += New-Object FirewallRule -Property @{DisplayName='Block Internet Access - mshta.exe (x64)';Program='%SystemRoot%\System32\mshta.exe'}

# PowerShell ISE
$rules += New-Object FirewallRule -Property @{DisplayName='Block Internet Access - powershell_ise.exe';Program='%SystemRoot%\SysWOW64\WindowsPowerShell\v1.0\powershell_ise.exe'}
$rules += New-Object FirewallRule -Property @{DisplayName='Block Internet Access - powershell_ise.exe (x64)';Program='%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell_ise.exe'}

# PowerShell
$rules += New-Object FirewallRule -Property @{DisplayName='Block Internet Access - powershell.exe';Program='%SystemRoot%\SysWOW64\WindowsPowerShell\v1.0\powershell.exe'}
$rules += New-Object FirewallRule -Property @{DisplayName='Block Internet Access - powershell.exe (x64)';Program='%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe'}

# 32 and 64 bit versions of regsvr32.exe - application whitelisting bypass
$rules += New-Object FirewallRule -Property @{DisplayName='Block Internet Access - regsvr32.exe';Program='%SystemRoot%\SysWOW64\regsvr32.exe'}
$rules += New-Object FirewallRule -Property @{DisplayName='Block Internet Access - regsvr32.exe (x64)';Program='%SystemRoot%\System32\regsvr32.exe'}

# 32 and 64 bit versions of rundll32.exe - application whitelisting bypass
$rules += New-Object FirewallRule -Property @{DisplayName='Block Internet Access - rundll32.exe';Program='%SystemRoot%\SysWOW64\rundll32.exe'}
$rules += New-Object FirewallRule -Property @{DisplayName='Block Internet Access - rundll32.exe (x64)';Program='%SystemRoot%\System32\rundll32.exe'}

# 32 and 64 bit versions of msdt.exe - application whitelisting bypass
$rules += New-Object FirewallRule -Property @{DisplayName='Block Internet Access - msdt.exe';Program='%SystemRoot%\SysWOW64\msdt.exe'}
$rules += New-Object FirewallRule -Property @{DisplayName='Block Internet Access - msdt.exe (x64)';Program='%SystemRoot%\System32\msdt.exe'}

# .Net-based application whitelisting bypasses
$rules += New-Object FirewallRule -Property @{DisplayName='Block Internet Access - dfsvc.exe - 2.0.50727';Program='%SystemRoot%\Microsoft.NET\Framework\v2.0.50727\dfsvc.exe'}
$rules += New-Object FirewallRule -Property @{DisplayName='Block Internet Access - dfsvc.exe - 2.0.50727 (x64)';Program='%SystemRoot%\Microsoft.NET\Framework64\v2.0.50727\dfsvc.exe'}
$rules += New-Object FirewallRule -Property @{DisplayName='Block Internet Access - dfsvc.exe - 4.0.30319';Program='%SystemRoot%\Microsoft.NET\Framework\v4.0.30319\dfsvc.exe'}
$rules += New-Object FirewallRule -Property @{DisplayName='Block Internet Access - dfsvc.exe - 4.0.30319 (x64)';Program='%SystemRoot%\Microsoft.NET\Framework64\v4.0.30319\dfsvc.exe'}
$rules += New-Object FirewallRule -Property @{DisplayName='Block Internet Access - ieexec.exe - 2.0.50727';Program='%SystemRoot%\Microsoft.NET\Framework\v2.0.50727\IEExec.exe'}
$rules += New-Object FirewallRule -Property @{DisplayName='Block Internet Access - ieexec.exe - 2.0.50727 (x64)';Program='%SystemRoot%\Microsoft.NET\Framework64\v2.0.50727\IEExec.exe'}
$rules += New-Object FirewallRule -Property @{DisplayName='Block Internet Access - MSBuild.exe - 2.0.50727';Program='%SystemRoot%\Microsoft.NET\Framework\v2.0.50727\MSBuild.exe'}
$rules += New-Object FirewallRule -Property @{DisplayName='Block Internet Access - MSBuild.exe - 2.0.50727 (x64)';Program='%SystemRoot%\Microsoft.NET\Framework64\v2.0.50727\MSBuild.exe'}
$rules += New-Object FirewallRule -Property @{DisplayName='Block Internet Access - MSBuild.exe - 3.5';Program='%SystemRoot%\Microsoft.NET\Framework\v3.5\MSBuild.exe'}
$rules += New-Object FirewallRule -Property @{DisplayName='Block Internet Access - MSBuild.exe - 3.5 (x64)';Program='%SystemRoot%\Microsoft.NET\Framework64\v3.5\MSBuild.exe'}
$rules += New-Object FirewallRule -Property @{DisplayName='Block Internet Access - MSBuild.exe - 4.0.30319';Program='%SystemRoot%\Microsoft.NET\Framework\v4.0.30319\MSBuild.exe'}
$rules += New-Object FirewallRule -Property @{DisplayName='Block Internet Access - MSBuild.exe - 4.0.30319 (x64)';Program='%SystemRoot%\Microsoft.NET\Framework64\v4.0.30319\MSBuild.exe'}
$rules += New-Object FirewallRule -Property @{DisplayName='Block Internet Access - InstallUtil.exe - 2.0.50727';Program='%SystemRoot%\Microsoft.NET\Framework\v2.0.50727\InstallUtil.exe'}
$rules += New-Object FirewallRule -Property @{DisplayName='Block Internet Access - InstallUtil.exe - 2.0.50727 (x64)';Program='%SystemRoot%\Microsoft.NET\Framework64\v2.0.50727\InstallUtil.exe'}
$rules += New-Object FirewallRule -Property @{DisplayName='Block Internet Access - InstallUtil.exe - 4.0.30319';Program='%SystemRoot%\Microsoft.NET\Framework\v4.0.30319\InstallUtil.exe'}
$rules += New-Object FirewallRule -Property @{DisplayName='Block Internet Access - InstallUtil.exe - 4.0.30319 (x64)';Program='%SystemRoot%\Microsoft.NET\Framework64\v4.0.30319\InstallUtil.exe'}

# Add more of your own rules by copying and uncommenting the line below
# $rules += New-Object FirewallRule -Property @{DisplayName='';Program=''}

# Create all of the rules using New-NetFirewallRule
foreach ($rule in $rules) {
    New-NetFirewallRule -DisplayName $rule.DisplayName -Direction $rule.Direction -Description $rule.Description -Action $rule.Action `
                        -LocalAddress $rule.LocalAddress -RemoteAddress $rule.RemoteAddress -Program $rule.Program
}