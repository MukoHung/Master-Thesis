<#
.SYNOPSIS
Converts a URL-encoded ATP Safelink to a real URL.

.DESCRIPTION
Microsoft doesn't offer a commandlet that converts an Advanced Threat Protection (ATP) SafeLink into the real target URL. This short script uses the .NET UrlDecode function and RegEx to extract it.

.PARAMETER safelink
A safelinks.protection.outlook.com link that includes the encoded target URL.

.EXAMPLE
ATP-ConvertSafelinkToUrl.ps1 -safelink https://na01.safelinks.protection.outlook.com/?url=https%3A%2F%2Fyoursite.com&data=email%40domain.com&sdata=xxxx&reserved=0

Returns: https://yoursite.com.

#>
param(
    [Parameter(Mandatory=$true)][String]$safelink
)
[Reflection.Assembly]::LoadWithPartialName("System.Web") | Out-Null
$decoded = [System.Web.HttpUtility]::UrlDecode($safelink)
$decoded -match "url=(\S+)&data=\S+"
$url = $Matches[1]
return $url