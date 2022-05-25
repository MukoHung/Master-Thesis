<#
.SYNOPSIS
Kurzbeschreibung: Skript fr�gt Anmeldebezogene Events abs
.DESCRIPTION
Ausf�hrliche Beschreibung. 
Dieses Skript erm�glicht die Abfrage von Anmelde- und Abmeldevents sowie fehlgeschlagene Anwendungen
.PARAMETER EventId
Mit diesem Parameter muss die EventID angegeben werden.
4624 AnmeldeEvents
4625 fehlgeschlagene Anmeldungen
4634 AbmeldeEvents
.EXAMPLE
Get-Eventlog.ps1 -EventId 4624

Index Time          EntryType   Source                 InstanceID Message
----- ----          ---------   ------                 ---------- -------
39264 Jul 29 13:56  SuccessA... Microsoft-Windows...         4624 Ein Konto wurde erfolgreich angemeldet....
39259 Jul 29 13:56  SuccessA... Microsoft-Windows...         4624 Ein Konto wurde erfolgreich angemeldet....
39256 Jul 29 13:56  SuccessA... Microsoft-Windows...         4624 Ein Konto wurde erfolgreich angemeldet....
39252 Jul 29 13:56  SuccessA... Microsoft-Windows...         4624 Ein Konto wurde erfolgreich angemeldet....
39250 Jul 29 13:56  SuccessA... Microsoft-Windows...         4624 Ein Konto wurde erfolgreich angemeldet....

Bei dieser Verwendung werden die aktuellesten 5 Anmeldevents vom Eventlog abgefragt
.EXAMPLE
zweites Beispiel
.LINK
https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_comment_based_help?view=powershell-5.1#comment-based-help-keywords
#>
[cmdletBinding(PositionalBinding=$false)] 
param(

[ValidateScript({Test-NetConnection -ComputerName $PSItem -CommonTCPPort WinRM -InformationLevel Quiet })]
[Parameter(Position=0)]
[string]$ComputerName = "localhost",

[ValidateSet(4624,4625,4634)]
[Parameter(Mandatory=$true)]
[int]$EventId,

[ValidateRange(5,10)]
[int]$Newest = 2
)


<#
PositionalBinding = $false | deaktiviert die Standard Nummierung der Parameter. Sodass dieses Skript nur �ber sogenannte benannte Parameter aufgerufen werden kann

Dokumentation zu cmdletBinding:
https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_functions_cmdletbindingattribute?view=powershell-5.1
---------------------
Position = 0 | wei�t einem Parameter die Position 0 zu sodass dieser als Positionaler Parameter verwendet werden kann.
Mandatory = $true | Sorgt daf�r das der Parameter zu einem Pflicht Parameter wird

Dokumentation zu Advanced Parametern
https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_functions_advanced_parameters?view=powershell-5.1#attributes-of-parameters

#>

#Optionale Ausgabe wenn Skript mit dem Parameter -Verbose gestartet wird
Write-Verbose -Message "Das Skript wurde mit folgenden Werten gestartet EventID: $eventID"

#Debughaltepunkt der ausgef�hrt wird wenn das Skript mit dem Parameter -debug gestartet wird
Write-Debug -Message "Vor der Abfrage"

Get-eventlog -LogName Security -ComputerName $ComputerName | Where-Object EventId -eq $EventId | Select-Object -First $Newest

