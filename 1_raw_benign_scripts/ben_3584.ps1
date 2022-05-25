.<#
.SYNOPSIS
  PowerShell Script Analyser

.DESCRIPTION
  Notes on installing and use of PSScriptAnalyzer

.OUTPUTS

.EXAMPLE

.LINK
  https://www.powershellmagazine.com/2015/10/12/powershell-tools-for-the-advanced-use-cases-part-1/
  https://devblogs.microsoft.com/scripting/psscriptanalyzer-deep-dive-part-1-of-4/
  https://argonsys.com/microsoft-cloud/library/using-psscriptanalyzer-to-check-powershell-version-compatibility/
#>

# Install
Find-Module -Name PSScriptAnalyzer | Select-Object Version, Name, Description | Format-List *
<#
Version     : 1.19.1
Name        : PSScriptAnalyzer
Description : PSScriptAnalyzer provides script analysis and checks for potential code defects in the scripts by
              applying a group of built-in or customized rules on the scripts being analyzed.
#>
Install-Module -Name PSScriptAnalyzer

Get-Module -Name PSScriptAnalyzer -ListAvailable
<#
ModuleType Version    Name                                ExportedCommands
---------- -------    ----                                ----------------
Script     1.19.1     PSScriptAnalyzer                    {Get-ScriptAnalyzerRule, Invoke-ScriptAnalyzer, Invoke-For...
#>

Get-Command -Module PSScriptAnalyzer

<#
CommandType     Name                                               Version    Source
-----------     ----                                               -------    ------
Cmdlet          Get-ScriptAnalyzerRule                             1.19.1     PSScriptAnalyzer
Cmdlet          Invoke-Formatter                                   1.19.1     PSScriptAnalyzer
Cmdlet          Invoke-ScriptAnalyzer                              1.19.1     PSScriptAnalyzer
#>

Invoke-ScriptAnalyzer ./

<#
RuleName                            Severity     ScriptName Line  Message
--------                            --------     ---------- ----  -------
TerminatorExpectedAtEndOfString     ParseError   investigat 18    The string is missing the terminator: ".
                                                 e_disk_iss
                                                 ues.ps1
PSUseBOMForUnicodeEncodedFile       Warning      investigat       Missing BOM encoding for non-ASCII encoded file
                                                 e_disk_iss       'investigate_disk_issues.ps1'
                                                 ues.ps1
MissingEndParenthesisInMethodCall   ParseError   ntlm_proxy 5     Missing ')' in method call.
                                                 .ps1
UnexpectedToken                     ParseError   ntlm_proxy 5     Unexpected token 'â€œuser-agentâ€

investigate_disk_issues.ps1 (Line:18)
Get-WinEvent –FilterHashtable @{logname="System"; id=129,153} | Group-Object {$_.TimeCreated.ToString("yyyy-MM")} | Select-Object Name, Count
#>

Invoke-ScriptAnalyzer -path .\investigate_disk_issues.ps1

<#
Not obvious in the editor but some hidden special characters were present
cat .\investigate_disk_issues.ps1
Get-WinEvent â€“FilterHashtable @{logname="System"; id=129,153} | Group-Object {$_.TimeCreated.ToString("yyyy-MM")} | Select-Object Name, Count

cat .\ntlm_proxy.ps1
#https://kimconnect.com/powershell-winhttp-proxy/

# Method 1: Set PowerShell User Agent to be recognized by the proxy and authenticate via Default AD credential
$webClient = new-object System.Net.WebClient
$webClient.Headers.Add(â€œuser-agentâ€

$webClient.Headers.Add(â€œuser-agentâ€

#>

Invoke-ScriptAnalyzer .\ntlm_proxy.ps1

<#
RuleName                            Severity     ScriptName Line  Message
--------                            --------     ---------- ----  -------
PSAvoidUsingConvertToSecureStringWi Error        ntlm_proxy 10    File 'ntlm_proxy.ps1' uses ConvertTo-SecureString
thPlainText                                      .ps1             with plaintext. This will expose secure information.
                                                                  Encrypted standard strings should be used instead.

$Password = ConvertTo-SecureString "Password" -AsPlainText -Force

$Password = Read-Host -Prompt "Enter your password" -AsSecureString
#>
