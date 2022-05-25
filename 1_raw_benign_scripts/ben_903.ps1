<#
.SYNOPSIS
Converts a file to BASE64 encoding and displays the encoded content.

.PARAMETER InputFile
The file to be converted to Base64. Displays the encoded string to output (see -ToJson)

.PARAMETER ToJson
Instead of displaying the raw Base64, it outputs a JSON-formatted object.


.EXAMPLE
C:\PS>Convert-ToBase64 -InputFile test.txt
dGVzdA0K

.EXAMPLE
C:\PS>Convert-ToBase64 test.txt
dGVzdA0K

.EXAMPLE
C:\PS>Convert-ToBase64 -InputFile test.txt -ToJson
{"content":"dGVzdA0K"}

.EXAMPLE
C:\PS>Convert-ToBase64 -InputFile test.txt | Out-File -Encoding ascii c:\temp\test.txt.base64
# => writes output to file

.EXAMPLE
C:\PS>Convert-ToBase64 test.txt -ToJson | Set-Clipboard
# => copies JSON to clipboard

#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory, Position = 0)]
    [string]$InputFile,

    [switch]$ToJson
)

if (-not (Test-Path -LiteralPath $InputFile)) {
    Write-Warning "Couldn't find file: $InputFile"
    exit 1
}

$outputString = [System.Convert]::ToBase64String([System.IO.File]::ReadAllBytes($InputFile))
if ($ToJson) {
    Add-Type -AssemblyName System.Web.Extensions
    # [System.Reflection.Assembly]::LoadWithPartialName("System.Web.Extensions")
    $jsonSerializer = New-Object System.Web.Script.Serialization.JavaScriptSerializer 
    $outputString = $jsonSerializer.Serialize(@{ content = $outputString })
}

$outputString