<#
.SYNOPSIS
    New-ScriptInit -ScriptName [String]
.DESCRIPTION
    Tworzy i wstępnie wypełnia plik skryptu oraz inicjalny pakiet plików towarzyszących jednostkę skryptu zgodnie z przyjętymi przeze mnie standadrami.
    W szczególności:
    1) Podpina skrypt do loggera,
    2) Tworzy inicjalny zewnętrzny plik pomocy,
    3) Tworzy inicjalny zewnętrzny plik określający wykorzystywane w skrypcie ciągi znaków w polskiej wersji językowej,
    4) Inicjuje plik przeznaczony do definicji testów jednostkowych,
.PARAMETER  <ScriptName>
    ScriptName 
    
    Nazwa skryptu (bez rozszerzenia).
.EXAMPLE
    New-ScriptInit -ScriptName NowySkrypt
.EXAMPLE
    New-ScriptInit -SN NowySkrypt
.EXAMPLE
    "NowySkrypt" | New-ScriptInit
.INPUTS
    Nazwa skryptu (bez rozszerzenia).
.OUTPUTS
    Obiekt związany z utworzonym plikiem.
.NOTES
    Brak
.LINK
    http://www.utom.pl
.COMPONENT
    Brak
.ROLE
    Brak
.FUNCTIONALITY
    Skrypt służący do tworzenia i wstępnego wypełnienia podstawowych elementów skryptu zgodnie z przyjętymi przeze mnie standadrami.
#>
param
    (
    [Parameter(Mandatory=$true, ValueFromPipeline=$true, HelpMessage="Nazwa skryptu.")]
    [Alias("SN")]
    [ValidateLength(1,254)]
    [ValidateNotNullOrEmpty()]
    [ValidatePattern("^\S([a-z]|[A-Z]|[0-9]|\.|-|_)*")]
    [String]$ScriptName
    )

Set-StrictMode -Version Latest

$ScriptContent = "## .ExternalHelp $(Get-Location)\$ScriptName.ps1-help.xml`n" + @'
Param
  (
    [Parameter(Mandatory=$true, ValueFromPipeline=$false, HelpMessage="P1Msg?")]
    [Alias("p1")]
    [ValidateLength(1,254)]
    [ValidateNotNullOrEmpty()]
    [ValidatePattern("^\S([a-z]|[A-Z]|[0-9]|\.|-|_)*")]
    [String]$Param1,
    
    [Parameter(Mandatory=$true, ValueFromPipeline=$false, HelpMessage="P2Msg?")]
    [Alias("p2")]
    [ValidateLength(1,254)]
    [ValidateNotNullOrEmpty()]
    [ValidatePattern("^\S([a-z]|[A-Z]|[0-9]|\.|-|_)*")]
    [String]$Param2
  )
  
Set-StrictMode -Version Latest

Import-LocalizedData -BindingVariable MsgTable

function Main
{
  Clear-History
  Clear-Host
  
  Init-Modules
  
'@ + "`$RootLog = Start-LoggerSvc -Configuration "".\$ScriptName.ps1.config""" + @'
  
  $RootLog.Info($MsgTable.StartMsg)
  
  Write-Output "Hello World"

  $RootLog.Info($MsgTable.StopMsg)

  Stop-LoggerSvc
  Clear-Modules
}

function Helper-Function{
Param
  (
    [Parameter(Mandatory=$true, ValueFromPipeline=$false, HelpMessage="P1Msg?")]
    [Alias("p1")]
    [ValidateLength(1,254)]
    [ValidateNotNullOrEmpty()]
    [ValidatePattern("^\S([a-z]|[A-Z]|[0-9]|\.|-|_)*")]
    [String]$Param1,
    
    [Parameter(Mandatory=$true, ValueFromPipeline=$false, HelpMessage="P2Msg?")]
    [Alias("p2")]
    [ValidateLength(1,254)]
    [ValidateNotNullOrEmpty()]
    [ValidatePattern("^\S([a-z]|[A-Z]|[0-9]|\.|-|_)*")]
    [String]$Param2
  )
$NewScriptLog = Get-Logger -ln HlpFncLoggerName

$NewScriptLog.Info($MsgTable.HlpFncStartMsg)
# <-- tu piszę dalej kod
$NewScriptLog.Info($MsgTable.HlpFncStopMsg)
}

function Init-Modules {
  try{
    $Script:ModList = New-Object System.Collections.ArrayList
    [void] $ModList.Add(@(Import-Module -Name PSLog -ArgumentList "..\..\Libs\log4net\bin\net\3.5\release\log4net.dll" -Force -PassThru))
  }
  catch [System.Management.Automation.RuntimeException] {
    switch($_.Exception.Message){
      "Log4net library cannot be found on the path" {
        Write-Error $MsgTable.Log4NetPathMsg
      }
      default {
        Write-Error $MsgTable.DefaultNegMsg
      }
    }
  }
  catch {
    "*"*80
    $_.Exception.GetType().FullName
    $_.Exception.Message
    "*"*80
    Exit
  }
}

function Clear-Modules{
  $ModList | %{Remove-Module $_}
}

. Main
'@

New-Item -Path . -Name $ScriptName".ps1" -ItemType "file" -Value $ScriptContent
& "$Home\Documents\WindowsPowerShell\Add-Signature.ps1" ".\$ScriptName.ps1" | Out-Null

$HelpContent = . "$Home\Documents\WindowsPowerShell\Modules\PsMAML\New-Maml.ps1" ".\$ScriptName.ps1"
$HelpContent.Declaration.ToString() | out-file ".\$ScriptName.ps1-help.xml" -encoding "UTF8"
$HelpContent.ToString() | out-file ".\$ScriptName.ps1-help.xml" -encoding "UTF8" -append

$LocalizedDataContent = "ConvertFrom-StringData @'`n`tStartMsg = ""Msg;Start""`n`tStopMsg = ""Msg;Stop""`n`tDefaultNegMsg = ""Wrrr""`n`tLog4NetPathMsg = ""Sprawdź poprawność ścieżki dostępu do biblioteki DLL log4net.dll""`n'@"
New-Item -Path . -Name "pl-PL" -ItemType "directory"
New-Item -Path .\pl-PL -Name $ScriptName".psd1" -ItemType "file" -Value $LocalizedDataContent

$UnitTestsContent = "`$here = Split-Path -Parent `$MyInvocation.MyCommand.Path`n" + @'
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\$sut"

Describe 
'@ + """$ScriptName"" {`n" + @'
    It "does something useful" {
        $true | Should Be $false
    }
}
'@
New-Item -Path . -Name $ScriptName".Tests.ps1" -ItemType "file" -Value $UnitTestsContent
& "$Home\Documents\WindowsPowerShell\Add-Signature.ps1" "$ScriptName.Tests.ps1" | Out-Null

New-Item -Path . -Name "Logs" -ItemType "directory"

$LoggerCfgContent = @'
<?xml version="1.0" encoding="utf-8" ?>
<configuration>
    <configSections>
        <section name="log4net" type="System.Configuration.IgnoreSectionHandler" />
    </configSections>
    <log4net>
        <appender name="LogFileAppender" type="log4net.Appender.FileAppender">
            <param name="File" value=
'@ + """$(Get-Location)\Logs\LogTest01.txt"" />`n" + @'
            <param name="AppendToFile" value="true" />
            <layout type="log4net.Layout.PatternLayout">
                <param name="ConversionPattern" value="%date [%thread] %-5level %logger [%ndc] - %message%newline" />
            </layout>
        </appender>
        <root>
            <level value="ALL" />
            <appender-ref ref="LogFileAppender" />
        </root>
        <logger name=
'@ + """$ScriptName"">`n" + @'
            <level value="ALL" />
        </logger>
    </log4net>
</configuration>
'@

New-Item -Path . -Name "$ScriptName.ps1.config" -ItemType "file" -Value $LoggerCfgContent

# SIG # Begin signature block
# MIIEQgYJKoZIhvcNAQcCoIIEMzCCBC8CAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUMrRaY9OCyTULJMwYJ0CwwkwI
# bKWgggJHMIICQzCCAbCgAwIBAgIQ3f+Nv7Gjdp5EG9kLIuImiTAJBgUrDgMCHQUA
# MDExLzAtBgNVBAMTJlRFU1QgUG93ZXJTaGVsbCBMb2NhbCBDZXJ0aWZpY2F0ZSBS
# b290MB4XDTEyMDUyMjE5NTMzN1oXDTM5MTIzMTIzNTk1OVowGjEYMBYGA1UEAxMP
# VGVzdDRQb3dlclNoZWxsMIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQC8uPjk
# Yiuy3DST6IMqob9uJkMqlRBCsdhBmsSMAPycmx7f4F5JFu0rNcdhfKh48GyVwvCQ
# Yklw4U7y7boD8pEsPxgADmb7OlGa0fR7vHqWCgPbQt1S6BygIFJr3DiDLj5gQSET
# 2MpLTH8WmySpiD1h9pRTKUPGKX6UeBpfwO9D3QIDAQABo3sweTATBgNVHSUEDDAK
# BggrBgEFBQcDAzBiBgNVHQEEWzBZgBBtVMj5oVjqAkNYQ2wydotDoTMwMTEvMC0G
# A1UEAxMmVEVTVCBQb3dlclNoZWxsIExvY2FsIENlcnRpZmljYXRlIFJvb3SCEOOM
# uAY77AqXTygp5eIzi8cwCQYFKw4DAh0FAAOBgQAPEO+k+tGvNiZj5kbRo81b5fbh
# tbkUC1PSCDCq9oRgtxGOQvrXzoyxNN9KasfStHIOSWgr/txtuvR6ufK1aMNiIc+c
# IZxjQ7JfXg8AL2W41OXgqR6IdEcJeoGuYtFlh8Cip+gUIqXIvWcyS3xk1AF8M6vF
# nN2P1yWQ/nJCrPBpqzGCAWUwggFhAgEBMEUwMTEvMC0GA1UEAxMmVEVTVCBQb3dl
# clNoZWxsIExvY2FsIENlcnRpZmljYXRlIFJvb3QCEN3/jb+xo3aeRBvZCyLiJokw
# CQYFKw4DAhoFAKB4MBgGCisGAQQBgjcCAQwxCjAIoAKAAKECgAAwGQYJKoZIhvcN
# AQkDMQwGCisGAQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUw
# IwYJKoZIhvcNAQkEMRYEFJq6XqGamPlKi2a5PQp55XeAPOouMA0GCSqGSIb3DQEB
# AQUABIGAdzYnZ5tVykLoXdXZxJUtRLHeYLGl3U5dNC3qMT7Q6hV67ZdXYGKOak+/
# 0SQATcVIoO1th/zJeeb60hy0wsMP3o5fy3NKrBgnoegWhwptpiL1EfpiY1Cz4Jt+
# DKQte429bIl/7+x4xB4Wh7XIG6N4XKZ4JKeDOQBvejYn1zxLYK8=
# SIG # End signature block
