# Basic PowerShell Funktionen
#   Werden automatisch mit LibGist-Update-Gists.ps1 aktuell gehalten
#
# 001, 220126, Gist@jig.ch
# 002, 220129
# 003, 220130
# 004, 220205
#


### Config
$LibGistVersion_LibGist_TomBasicFuncs_ps1 = '004'


#Region Tom-Tools


#Region Tom-Tools: Log

### ℹ Log stumm schalten
#
# [CmdletBinding(SupportsShouldProcess)]
# Param (
# 	[Switch]$Silent
# )
#
# If ($Silent) { $Script:LogDisabled = $true }

# Log
# Prüft, ob $Script:LogColors definiert ist und nützt dann dieses zur Farbgebung
# $Script:LogColors =@('Cyan', 'Yellow')
#
# !Ex
# 	Log 1 'Test1' -NoNewline; Log 1 'Test2' -Append
# 	Log 1 'Test1' -NoNewline; Log -Message 'Test2' -Append
#
#
# 0: Thema - 1: Kapitel - 2: OK - 3: Error
# 200604 175016
# 200805 103305
# 	Neu: Optional BackgroundColor
# 211129 110213
# 	Fix -ClrToEol zusammen mit -ReplaceLine
# 220102 172537
# 	Fix Für PS7: Kommt irgendwie nicht mit NoNewLine zurecht
# 220118 095129
# 	ValueFromPipeline richtig angewendet
# 220123 222224
# 	Fixed: -ReplaceLine handling
$Script:LogColors = @('Green', 'Yellow', 'Cyan', 'White', 'Red')
Function Log() {
	Param (
		[Parameter(Position = 0)]
		[Int]$Indent,

		[Parameter(Position = 1, ValueFromPipeline, ValueFromPipelineByPropertyName)]
		[String]$Message = '',

		[Parameter(Position = 2)]
		[ConsoleColor]$ForegroundColor,

		# Vor der Nachricht eine Leerzeile
		[Parameter(Position = 3)]
		[Switch]$NewLineBefore,

		# True: Die aktuelle Zeile wird gelöscht und neu geschrieben
		[Parameter(Position = 4)]
		[Switch]$ReplaceLine = $false,

		# True: Am Ende keinen Zeilenumbruch
		[Parameter(Position = 5)]
		[Switch]$NoNewline = $false,

		# Append, also kein Präfix mit Ident
		[Parameter(Position = 6)]
		[Switch]$Append = $false,

		# Löscht die Zeile bis zum Zeilenende
		[Parameter(Position = 7)]
		[Switch]$ClrToEol = $false,

		[Parameter(Position = 8)]
		[ConsoleColor]$BackgroundColor
	)

	Begin {
		If ($Script:LogDisabled -eq $true) { Return }
		# Fix für PS7
		If ($null -eq $Script:IsPS7) { $Script:IsPS7 = ($PSVersionTable).PSVersion.Major -eq 7 }
		If ($null -eq $Script:DefaultBackgroundColor) { $Script:DefaultBackgroundColor = (Get-Host).UI.RawUI.BackgroundColor }

		If ($Indent -eq $null) { $Indent = 0 }
		If ($BackgroundColor -eq $null) { $BackgroundColor = $Script:DefaultBackgroundColor }

		$WriteHostArgs = @{ }
		If ($ForegroundColor -eq $null) {
			If ($null -ne $Script:LogColors -and $Indent -le $Script:LogColors.Count -and $null -ne $Script:LogColors[$Indent]) {
				Try {
					$ForegroundColor = $Script:LogColors[$Indent]
				} Catch {
					Write-Host "Ungültige Farbe: $($Script:LogColors[$Indent])" -ForegroundColor Red
				}
			}
			If ($null -eq $ForegroundColor) {
				$ForegroundColor = [ConsoleColor]::White
			}
		}
		If ($ForegroundColor) {
			$WriteHostArgs += @{ ForegroundColor = $ForegroundColor }
		}
		$WriteHostArgs += @{ BackgroundColor = $BackgroundColor }

		If ($NoNewline) {
			$WriteHostArgs += @{ NoNewline = $true }
		}
	}

	Process {
		If ([String]::IsNullOrEmpty($Message)) { $Message = '' }

		If ($NewLineBefore) { Write-Host '' }

		If ($Append) {
			$Msg = $Message
			If ($ClrToEol) {
				$Width = (get-host).UI.RawUI.MaxWindowSize.Width
				If ($Msg.Length -lt $Width) {
					$Spaces = $Width - $Msg.Length
					$Msg = "$Msg$(' ' * $Spaces)"
				}
			}
		} Else {
			Switch ($Indent) {
				0 {
					$Msg = "* $Message"
					If ($NoNewline -and $ClrToEol) {
						$Width = (get-host).UI.RawUI.MaxWindowSize.Width
						If ($Msg.Length -lt $Width) {
							$Spaces = $Width - $Msg.Length
							$Msg = "$Msg$(' ' * $Spaces)"
						}
					}
					If (!($ReplaceLine)) {
						$Msg = "`n$Msg"
					}
				}
				Default {
					$Msg = $(' ' * ($Indent * 2) + $Message)
					If ($NoNewline -and $ClrToEol) {
						# Rest der Zeile mit Leerzeichen überschreiben
						$Width = (get-host).UI.RawUI.MaxWindowSize.Width
						If ($Msg.Length -lt $Width) {
							$Spaces = $Width - $Msg.Length
							$Msg = "$Msg$(' ' * $Spaces)"
						}
					}
				}
			}
		}

		If ($ReplaceLine) { $Msg = "`r$Msg" }
		Write-Host $Msg @WriteHostArgs
		# Fix für PS7: Den Cursor ans Ende Positionieren
		If ($Script:IsPS7 -and $NoNewline) {
			$CursorPosition = (Get-Host).UI.RawUI.CursorPosition
			$CursorPosition.X = $Msg.Length
			(Get-Host).UI.RawUI.CursorPosition = $CursorPosition
		}

		# if (!([String]::IsNullOrEmpty($LogFile))) {
		# 	"$([DateTime]::Now.ToShortDateString()) $([DateTime]::Now.ToLongTimeString())   $Message" | Out-File $LogFile -Append
		# }
	}
}


#Endregion Tom-Tools: Log

#Region Tom-Tools: UI


# Stellt die Ja / Nein-Frage und liefert die Antwort
# True = ja
Function Ask_YesNo($Question) {
	$Answer = $null
	While ($Answer -eq $null) {
		$Answer = Read-Host -Prompt $Question
		$Answer = $Answer.Trim().ToLower()
		Switch -regex ($Answer) {
			'y|j' {
				Return $true
			}
			'n' {
				Return $false
			}
			Default { $Answer = $null }
		}
	}
}

#Endregion Tom-Tools: UI

#Region Tom-Tools: IO, File-Handling


# 210626
Function Test-FileIslocked {
	Param (
		[parameter(Mandatory = $true)]
		[String]$File
	)

	If ((Get-Item $File) -is [System.IO.DirectoryInfo]) { Return $True }
	If (!(Test-Path -Path $File)) { Return $False }

	$oFile = New-Object System.IO.FileInfo $File
	Try {
		$oStream = $oFile.Open([IO.FileMode]::Open, [IO.FileAccess]::ReadWrite, [IO.FileShare]::None)
		If ($oStream) { $oStream.Close() }
		Return $False
	} Catch [System.UnauthorizedAccessException] {
		# $IsLocked = 'AccessDenied'
		Return $True
	} Catch {
		# file is locked by a process.
		Return $True
	} Finally {
		If ($oStream) { $oStream.Dispose() }
	}
}


# Holt die erste Datei in $aDir, die den Namen $aScriptName hat
Function FindFirstFileName($aDir, $aScriptName) {
	(Get-ChildItem -LiteralPath $aDir -Recurse -Filter $aScriptName | Select-Object -First 1).FullName
}

Function Backup-File($FileName, $NewExt = $null) {
	If ($NewExt) {
		$FileName = Replace-FileExt $FileName $NewExt
	}

	$BackupFile = Filename-Add-Suffix $FileName ($(get-date -f ' yyMMdd-HHmm'))
	Copy-Item -LiteralPath $FileName -Destination $BackupFile
}


Function Is-File-NewerThan() {
	Param (
		[parameter(Mandatory)]
		[String]$FileSrc,
		[parameter(Mandatory)]
		[String]$FileDst,
		[Int]$DeltaSecondsTolerance = 0,
		[Switch]$ShowInfo
	)

	# Konvertieren
	[Double]$DeltaSecondsTolerance = $DeltaSecondsTolerance

	$oFileSrc = [IO.FileInfo]($FileSrc)
	If ($oFileSrc.Exists -eq $false) {
		If ($ShowInfo) { Log 3 "Quelldatei existiert nicht:`n $($FileSrc)" }
		# Die Quelldatei ist also älter, bzw. nicht versuchen, die Zieldatei zu generieren
		Return $False
	}

	$oFileDst = [IO.FileInfo]($FileDst)
	If ($oFileDst.Exists -eq $false) {
		If ($ShowInfo) { Log 3 "Zieldatei existiert nicht:`n $($FileDst)" }
		# Die Quelldatei ist also neuer
		Return $True
	}

	# Zeitunterschied berechnen
	$dtSec = (New-TimeSpan –Start $oFileSrc.LastWriteTime –End $oFileDst.LastWriteTime).TotalSeconds
	$dtSecAbs = [Math]::Abs( $dtSec )

	If ($dtSecAbs -le $DeltaSecondsTolerance) {
		If ($ShowInfo) { Log 3 'Dateien sind gleich alt' }
		Return 0
	} Else {
		If ($dtSec -lt 0) {
			If ($ShowInfo) { Log 3 "Quelldatei ist $($dtSec)s älter als die Zieldatei" }
			Return $false
		} Else {
			If ($ShowInfo) { Log 3 "Quelldatei ist $($dtSec)s jünger als die Zieldatei" }
			Return $true
		}
	}
}


# Wipe File
# "C:\RemoveFileSecure\test1.txt"  | Remove-FileSecure -DeleteAfterOverwrite #-Confirm:$false #-WhatIf
# Get-ChildItem c:\RemoveFileSecure -Filter *.txt  | Remove-FileSecure -DeleteAfterOverwrite #-Confirm:$false #-WhatIf
# 200805
Function Remove-File-Secure {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact="High")]
    Param(
        [Parameter(Mandatory, ValueFromPipeline)]
        $File,
        [Parameter()]
        [Switch]$DeleteAfterOverwrite = $false
    )

    Begin {
        $Rnd = New-Object System.Security.Cryptography.RNGCryptoServiceProvider
    }

    Process {
        $RetObj = $null

        If ((Test-Path $File -PathType Leaf) -and $PSCmdlet.ShouldProcess($File)) {
            $oFile = $File
            if( !($oFile -is [System.IO.FileInfo]) ) {
                $oFile = new-object System.IO.FileInfo($File)
            }

            $FileLen = $oFile.length
            # write-host $oFile.FullName
            $Stream = $oFile.OpenWrite()
            Try {
                $StopWatch = new-object system.diagnostics.stopwatch
                $StopWatch.Start()

                Write-Progress -Activity $oFile.FullName -Status "Write" -PercentComplete 0 -CurrentOperation ""

                [long]$i = 0
                $Buffer = new-object byte[](1024*1024)
                While( $i -lt $FileLen ) {
                    $Rnd.GetBytes($Buffer)
                    $Rest = $FileLen - $i
                    If( $Rest -gt (1024*1024) ) {
                        $Stream.Write($Buffer, 0, $Buffer.length)
                        $i += $Buffer.LongLength
                    } Else {
                        $Stream.Write($Buffer, 0, $Rest)
                        $i += $Rest
                    }
                    [Double]$p = [double]$i / [double]$FileLen
                    [Long]$remaining = [double]$StopWatch.ElapsedMilliseconds / $p - [double]$StopWatch.ElapsedMilliseconds
                    Write-Progress -Activity $oFile.FullName -Status "Write" -PercentComplete ($p * 100) -CurrentOperation "" -SecondsRemaining ($remaining/1000)
                }
                $StopWatch.Stop()

			} Finally {
                $Stream.Close()
                If( $DeleteAfterOverwrite ) {
                    $j  = Remove-Item $oFile.FullName -Force -Confirm:$false
					Start-Sleep -Milliseconds 250
                    $RetObj = new-object PSObject -Property @{File = $oFile; Wiped=$true; Deleted=(-Not (Test-Path $oFile)) }
                } Else {
                    $RetObj = new-object PSObject -Property @{File = $oFile; Wiped=$true; Deleted=$false}
                }
            }
        } Else {
            $RetObj = new-object PSObject -Property @{File = $File; Wiped=$false; Deleted=$false}
        }
        return $RetObj
    }
}


# Löscht Dateien, die älter als n Tage sind
# 	Unterstützt -WhatIf
# 	$PathFilter akzeptiert Muster
#
# Ex
# Remove-Old-Files c:\Tasks\AD-AAD-Group*.log -OlderThanDays 45 -WhatIf
# Remove-Old-Files c:\Tasks\AD-AAD-Group*.log -OlderThanDays 45
Function Remove-Old-Files() {
	[CmdletBinding(SupportsShouldProcess = $True)]
	Param (
		[Parameter(Position = 0, Mandatory)]
		[String]$PathFilter,

		[Parameter(Position = 1, Mandatory)]
		[Int]$OlderThanDays,
		[Switch]$Recurse
	)
	If ($OlderThanDays -gt 0)  { $OlderThanDays = -1* $OlderThanDays}
	Get-ChildItem -Path $PathFilter -Recurse:$Recurse | ? { ($_.LastWriteTime -lt (Get-Date).AddDays($OlderThanDays)) } | Remove-Item -Force
}



# Sehr schnell, optional mit der expliziten Codierung
# http://www.happysysadm.com/2014/10/reading-large-text-files-with-powershell.html
Function Get-Content-Fast($LiteralPath, [Text.Encoding]$Encoding = $null) {
	If ($Encoding) {
		[System.IO.File]::ReadAllText($LiteralPath, $Encoding)
	} Else {
		[System.IO.File]::ReadAllText($LiteralPath)
	}
}


# Sehr schnell, optional mit der expliziten Codierung
# 191028
Function Write-Content-Fast() {
	Param (
		[Parameter(Position = 0, Mandatory)]
		$LiteralPath,

		[Parameter(Position = 1, Mandatory, ValueFromPipeline)]
		$Content,

		[Parameter(Position = 2)]
		[Text.Encoding]$Encoding,

		[Switch]$Overwrite = $True
	)

	Begin {
		If (Test-Path -LiteralPath $LiteralPath) {
			If ($Overwrite) {
				Remove-Item -Force -LiteralPath $LiteralPath
			} Else {
				Return
			}
		}
	}

	Process {
		Switch ($Content.GetType()) {
			([Object[]]) {
				If ($Encoding) {
					[System.IO.File]::WriteAllLines($LiteralPath, $Content, $Encoding)
				} Else {
					[System.IO.File]::WriteAllLines($LiteralPath, $Content)
				}
			}
			([String]) {
				If ($Encoding) {
					[System.IO.File]::WriteAllText($LiteralPath, $Content, $Encoding)
				} Else {
					[System.IO.File]::WriteAllText($LiteralPath, $Content)
				}
			}
		}
	}

	End {}
}



# 191028
Function Convert-File-Encoding() {
	Param (
		[Parameter(Position = 0, Mandatory)]
		$LiteralPath,

		[Parameter(Position = 1)]
		[System.Text.Encoding]$InEncoding,

		[Parameter(Position = 2)]
		[System.Text.Encoding]$OutEncoding,

		[Switch]$Overwrite = $True
	)

	$Content = Get-Content-Fast -LiteralPath $LiteralPath -Encoding $InEncoding

	$Args = @{
		Overwrite = $Overwrite
	}
	Write-Content-Fast -LiteralPath $LiteralPath -Content $Content -Encoding $OutEncoding @Args
}


# Erzeugt aus
# C:\Test 		und C:\Test\abc.txt			» .\abc.txt
# C:\Test\ 		und C:\Test\abc.txt			» .\abc.txt
# C:\Test\Dir	und C:\Test\Dir\abc.txt		» .\Dir\abc.txt
Function Get-Path-Delta($Base, $Target) {
	# Allenfalls den Pfad-Delimiter zufügen: (Join-Path $Base '').Length
	Return ".\{0}" -f $Target.SubString((Join-Path $Base '').Length )
}


#Endregion Tom-Tools: IO, File-Handling

#Region Tom-Tools: JSON


Function Read-Json() {
	Param(
		[parameter(Position = 0, Mandatory)]
		[String]$JsonFileName,
		[Text.Encoding]$Encoding
	)
	If (Test-Path -LiteralPath $JsonFileName -PathType Leaf) {
		Get-Content-Fast -LiteralPath $JsonFileName -Encoding $Encoding | ConvertFrom-Json
	}
}

Function Write-Json() {
	Param(
		[parameter(Position=0, Mandatory)]
		[String]$JsonFileName,
		[parameter(Position=1, Mandatory)]
		[Object]$JsonData,
		[Text.Encoding]$Encoding
	)
	$JsonData | ConvertTo-Json -Depth 99 | Write-Content-Fast -Overwrite -LiteralPath $JsonFileName -Encoding $Encoding
}


#Endregion Tom-Tools: JSON

#Region Tom-Tools: Cache


# Beispiel
#
# Function Get-YT-Channel-MetaData($Url) {
# 	$CacheVar = 'CacheMetaData'
# 	$ChannelMetaData = Cache-GetVal -CacheName $CacheVar -Key $Url
# 	If ($Null -eq $ChannelMetaData) {
# 		$ChannelMetaData = & $YouTubeRestAPI_ps1 -GetChannelMetaData $Url
# 		Cache-SetVal -CacheName $CacheVar -Key $Url -Value $ChannelMetaData
# 	}
# 	Return $ChannelMetaData
# }



# Liefert den Gecachten Wert oder $null
# Initialisiert allenfalls den Cache
Function Cache-GetVal($CacheName, $Key) {
	$Cache = Get-Variable -Name $CacheName -ValueOnly -Scope Script -ErrorAction SilentlyContinue
	# Allenfalls den Cache initialisieren
	If ($null -eq $Cache) {
		Set-Variable -Name $CacheName -Scope Script -Value @{}
	} Else {
		Return $Cache[$Key]
	}
}

# Setzt einen Wert im Cache
Function Cache-SetVal($CacheName, $Key, $Value) {
	$Cache = Get-Variable -Name $CacheName -ValueOnly -Scope Script -ErrorAction SilentlyContinue
	# Allenfalls den Cache initialisieren
	If ($null -eq $Cache) {
		Set-Variable -Name $CacheName -Scope Script -Value @{}
		$Cache = Get-Variable -Name $CacheName -Scope Script
	}
	Return $Cache.Add($Key, $Value)
}


#Endregion Tom-Tools: Cache

#Region Tom-Tools: Pipeline


# Liefert für die Obj-Liste
# die durch die PropNamen eindeutig identifizierten Objekte zurück
#
# !Ex
# 	Get-UniqueByProp -Data $Res $Properties | ft
# 	$Res | Get-UniqueByProp $Properties | ft
Function Get-UniqueByProp() {
	[CmdletBinding()]
	Param (
		[Parameter(Position = 0, Mandatory)]
		[String[]]$PropNames,
		[Parameter(Position = 1, ValueFromPipeline)]
		[Object[]]$Data
	)

	Begin {
		$AllData = @()
	}

	Process {
		$AllData += $Data
	}

	End {
		$AllData |
			Group-Object $PropNames | `
			% { $_.Group | Select -First 1 } | `
			Sort $PropNames
	}
}

#Endregion Tom-Tools: Pipeline



#Region Tom-Tools: HashTables, Arrays



# Teilt ein Array in chunk of Arrays
# Ex
#	[Int[]]$myArray = 1, 2, 3, 4, 5
#	$Res = Get-Array-Chunks $myArray 2
Function Get-Array-Chunks([Object[]]$SrcArr, [Int]$ChunkSize) {
	# Wenn die SrcArr kleiner als $ChunkSize ist
	If ($SrcArr.Count -le $ChunkSize) { Return $SrcArr }

	Function Get-Arr($Type, $Size) {
		Switch($Type) {
			'String[]' { 	Return [String[]]::New($Size) }
			'Int32[]' { 	Return [Int32[]]::New($Size) }
			'Object[]' {	Return [Object[]]::New($Size) }
			Default { 		Write-Error "Keine Implementation für Typ: $Type" }
		}
	}

	$SrcArrType = $SrcArr.GetType().Name
	$AnzChunks = [Math]::Truncate($SrcArr.Count / $ChunkSize)
	$LeftOver = $SrcArr.Count % $ChunkSize

	[System.Collections.ArrayList]$Chunks = @()
	For ($i = 0; $i -lt $AnzChunks; $i++) {
		$ZielArr = Get-Arr $SrcArrType $ChunkSize
		[Array]::Copy($SrcArr, $i * $ChunkSize, $ZielArr, 0, $ChunkSize)
		$Chunks += ,@($ZielArr)
	}

    If ($LeftOver -gt 0) {
		$ZielArr = @(Get-Arr $SrcArrType $LeftOver)
		[Array]::Copy($SrcArr, ($AnzChunks * $ChunkSize), $ZielArr, 0, $LeftOver)
		$Chunks += ,@($ZielArr)
	}

	$Chunks
}



# Erzeugt aus $Val ein Array
Function Get-Array($Val) {
	If ($Val -isnot [System.Array]) {
		Return, @($Val)
	} Else {
		Return $Val
	}
}


# Konvertiert alle HashTable-Properties eines Objekts
# https://stackoverflow.com/a/55715823/4795779
# 200518 210715
Function Get-Hash-AsObject {
	Param (
		[HashTable]$hash,
		[Switch]$Deep = $true
	)

	$NewHash = @{ }
	ForEach ($k In $hash.Keys) {
		If ($hash[$k] -is [HashTable] -and $Deep) {
			$NewHash.Add($k, (Get-Hash-AsObject -Deep -hash $hash[$k]))
		} ElseIf (($hash[$k] -is [Array])) {
			$Items = @()
			ForEach ($Item In $hash[$k]) {
				$Items += (Get-Hash-AsObject -Deep -hash $Item)
			}
			$NewHash.Add($k, $Items)
		} Else {
			$NewHash.Add($k, $hash[$k])
		}
	}
	Return [PSCustomObject]$NewHash
}


# Wenn $Obj $null ist, wird ein leeres Array zurückgegeben
# Anwendung:
# 		…
# 		Return-DataArr_OrEmptyArr $Obj
# 	}
# 200314 235243
Function Return-DataArr_OrEmptyArr($Obj) {
	# Wenn wir kein Objekt haben, ein leeres Array zurückgeben
	If ($Obj -eq $null) {
		Return, @()
	} Else {
		# haben wir bereits ein Array?
		Switch ($Obj.Gettype().Name) {
			'Object[]' {
				Return $Obj
			}
			default {
				Return, @($Obj)
			}
		}
	}
}

#Endregion Tom-Tools: HashTables, Arrays



#Region Tom-Tools: ScriptBlock in Texten

# Sucht in einem beliebigen Text nach allen ScriptBlocks
# Ex:
# 	$Test = @'
# 		…
# 		{ @{ ShowDoc = $False } }
# 		…
# 		{ @{ Prop = $True } }
# 	'@
Function Get-ScriptBlocks($Text) {
	$RgxScriptBlock = @'
		(?imsnx-)
		(?<OuterScriptBlock>
			\{                   # Match {
			 (?<InnerScriptBlock>
			  [^{}]+             # all chars except {}
			  | (?<Level>\{)     # or if { then Level += 1
			  | (?<-Level>\})    # or if } then Level -= 1
			 )+                  # Repeat (to go from inside to outside)
			(?(Level)(?!))       # zero-width negative lookahead assertion
			\}
		)
'@

	# !9^9 Matches und nicht Match!
	$MyMatches = [RegEx]::Matches($Text, $RgxScriptBlock, @('Compiled', 'CultureInvariant', 'ExplicitCapture', 'IgnoreCase', 'IgnorePatternWhitespace', 'Multiline', 'Singleline'))

	If ($MyMatches.Count -gt 0) {
		ForEach ($Match In $MyMatches) {
			# Den äusseren Scriptblock holen
			$OuterScriptBlock = $Match.Groups['OuterScriptBlock'].Value
			# Den äusseren Scriptblock entfernen und zurückgeben
			$OuterScriptBlock.Trim().Trim('{}').Trim()
		}
	}
}


# Evaluiert den Scriptblock und gibt das Resultat zurück
Function Invoke-ScriptBlock($Text) {
	If ($SB = [Scriptblock]::Create($Text)) {
		Return & $SB
	}
}


# Startet alle ScriptBlocks und prüft, ob ein Proeprty gefunden wurde
#
# Retourniert das ScriptBlock-Resultat (für den Fall, dass weitere Properties von Interesse sind)
# und das gesuchte Property selber
# $ResSB, $ResSBProperty = Get-ScriptBlock-Prop …
Function Get-ScriptBlock-Prop([String[]]$TextScriptBlocks, $PropName) {
	# Alle Text-ScriptBlocks prüfen
	ForEach ($TextSB In $TextScriptBlocks) {
		$ResSB = Start-ScriptBlock $TextSB
		# Baben wir das gesuchte Property gefunden?
		If ($ResSB -and $ResSB."$PropName") {
			Return @($ResSB, $ResSB."$PropName")
		}
	}
}

#Endregion Tom-Tools: ScriptBlock in Texten



#Region Tom-Tools: Filenamen

Function Replace-FileExt($FileName, $NewFileExt) {
	[IO.Path]::Combine( `
		[IO.Path]::GetDirectoryName($FileName), `
		[IO.path]::GetFileNameWithoutExtension($FileName) + $NewFileExt
	)
}



# Ergänzt einen Dateinamen mit einem Pre- und/oder Suffix
# 200514 185133
Function Filename-Add-Prefix-Suffix($FileName, $Prefix, $Suffix) {
	If ([System.String]::IsNullOrEmpty($Prefix)) { $Prefix = '' }
	If ([System.String]::IsNullOrEmpty($Suffix)) { $Suffix = '' }

	[IO.Path]::Combine( `
		[IO.Path]::GetDirectoryName($FileName), `
		$Prefix + [IO.Path]::GetFileNameWithoutExtension($FileName) + $Suffix + [IO.Path]::GetExtension($FileName)
	)
}


# Ergänzt einen Dateinamen mit einem Suffix
Function Filename-Add-Suffix($FileName, $Suffix) {
	[IO.Path]::Combine( `
		[IO.Path]::GetDirectoryName($FileName), `
		[IO.path]::GetFileNameWithoutExtension($FileName) + $Suffix + [IO.path]::GetExtension($FileName)
	)
}

#Endregion Tom-Tools: Filenamen



#Region Tom-Tools: Pfade


# Erzeugt ein Verzeichnis
Function MKDir($Path, [Switch]$Silent = $True) {
	Try {
		If (-not (Test-Path -LiteralPath $Path)) {
			If ($Silent) {
				$null = New-Item -ItemType Directory -Path $Path -Force -ErrorAction SilentlyContinue
			} Else {
				$null = New-Item -ItemType Directory -Path $Path -Force -ErrorAction Stop
			}
		}
	} Catch {
		[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
		$MessageId = ('{0:x}' -f $_.Exception.HResult).Trim([char]0)
		$ErrorMessage = ($_.Exception.Message).Trim([char]0) # Illegal characters in path.
		If ($ErrorMessage -like '*Illegal character*') {
			Log 4 "Die Funktion Clean-FileName-Str() muss um Sonderzeichen erweitert werden für:"
			Log 4 $Path
			Return
		}
	}
}


# Bereinigt FullFileName von ungültigen Zeichen
Function Clean-Path-Chars($FullFileName) {
	If ($FullFileName.StartsWith('\\?\')) {
		$Prefix = $FullFileName.SubString(0, '\\?\'.Length)
		$Pfad = $FullFileName.SubString('\\?\'.Length)
	} ElseIf ($FullFileName.StartsWith('\\')) {
		$Prefix = $FullFileName.SubString(0, '\\'.Length)
		$Pfad = $FullFileName.SubString('\\'.Length)
	} ElseIf ($FullFileName[1] -eq ':' -and $FullFileName[2] -eq '\') {
		$Prefix = $FullFileName.SubString(0, 'x:\'.Length)
		$Pfad = $FullFileName.SubString('x:\'.Length)
	} ElseIf ($FullFileName[1] -eq ':') {
		$Prefix = $FullFileName.SubString(0, 'x:'.Length)
		$Pfad = $FullFileName.SubString('x:'.Length)
	} Else {
		# Ein relativer Pfad
		$Pfad = $FullFileName
	}

	# Die einzelnen Pfad-Elemente bereinigen
	$Res = @()
	$Items = $Pfad.Split('\')
	ForEach ($Item In $Items) {
		# Löscht ungültige Zeichen, mehrfache Leerzeichen und Underlines
		$Res += $Item.Split([IO.Path]::GetInvalidFileNameChars()) -join '_' -replace '\s+', ' ' -replace '_+', ' '
	}
	# Das Resultat wieder zusammenfügen
	$Prefix + ($Res -join '\')
}

# Liefert das Parent-Verzeichnis
Function Get-ParentDir($Dir) {
	# [System.IO.Path]::GetDirectoryName('c:\temp\')	» c:\temp
	# [System.IO.Path]::GetDirectoryName('c:\temp')		» c:\

	# $Dir endet mit / oder \, oder $Dir hat keine Dateierweiterung
	If (($Dir -match '/$|\\$') -or [String]::IsNullOrWhiteSpace([System.IO.Path]::GetExtension($Dir))) {
		# Wahrscheinlich ist Dir ein ein Verzeichnis
		# Dir-Delimiter entfernen
		$Dir = $Dir.TrimEnd('/\')
		# Das ParentDir zurückgeben
		If (Has-Value $Dir) {
			[System.IO.Path]::GetDirectoryName($Dir)
		}
	} Else {
		# Wahrscheinlich ist Dir ein Dateiname
		$Dir = [System.IO.Path]::GetDirectoryName($Dir)
		# Das ParentDir zurückgeben
		If (Has-Value $Dir) {
			[System.IO.Path]::GetDirectoryName($Dir)
		}
	}
}

#Endregion Tom-Tools: Pfade


#Region Tom-Tools: URI


# Verbinded zwei URLs
#
# Wenn $Append = $True, dann wird $Realtive dem ganzen Root-Pfad zugefügt
# Sonst wird Relative nur dem Host zugefügt
Function Join-URL ($Root, $Relative, [Switch]$Append = $True) {
	# Sicherstellen, dass am Ende kein Slash existiert
	$Root = $Root.TrimEnd('/').TrimEnd('\')
	# Wenn $Relative zum ganzen Root-Pfad zugefügt werden muss, benötigt Root ein Slash
	If ($Append) { $Root = $Root + '/' }
	# https://msdn.microsoft.com/en-us/library/system.uri(v=vs.110).aspx
	$RootUri = New-Object System.Uri($Root)
	(New-Object System.Uri($RootUri, $Relative)).AbsoluteUri
}


# Parst $Str in ein [Uri]
# und ersetzt $Uri.Query mit einem Name/Value Array
Function Parse-Uri() {
	Param (
		[parameter(Position = 0, Mandatory)]
		[String]$Str
	)

	# Laden ist schneller als der vorgängige Test
	# ('Web.HttpUtility' -as [Type]) -ne $Null
	Add-Type -AssemblyName System.Web

	$Uri = [System.Uri]$Str

	# $Uri.Query in $Uri.QueryStr ändern
	$Uri | Add-Member -MemberType NoteProperty 'QueryStr' -Value $Uri.Query

	$ParsedQueryString = [Web.HttpUtility]::ParseQueryString($Uri.Query)

	$i = 0
	$QryParams = @()
	ForEach($QueryStringObject in $ParsedQueryString){
		$QryParams += [PSCustomObject][Ordered]@{
			Name = $QueryStringObject
			Value = $ParsedQueryString[$i]
		}
		$i++
	}
	# $Uri.Query patchen / ersetzen
	$Uri | Add-Member -MemberType NoteProperty 'Query' -Value $QryParams -Force
	$Uri
}


#Endregion Tom-Tools: URI




#Region Tom-Tools: Allgemeine Funktionen

# Join-Path für URLs
# Erlaubt den zwingenden abschliessenden Separator, weil manche Webseiten den brauchen
#
# Join-Parts -Parts @($HomeUrl,'login/')
# 	https://www.christ-sucht-christ.de/login/
Function Join-Parts {
    param(
        [String[]]$Parts = $null,
        $Separator = '/'
    )
	# $Nuller löschen
    ($Parts | ? { $_ } | % { ([String]$_).TrimStart($Separator) } | ? { $_ } ) -Join $Separator
}


# ℹ Einzeiler für den Script-Anfang:
# $ScriptDir = [IO.Path]::GetDirectoryName($MyInvocation.MyCommand.Path)

# Liefert das Verzeichnis des ablaufenden Scriptes
Function Get-ScriptDir { "{0}\" -f $($MyInvocation.PSScriptRoot) }

# Macht, was man erwartet
# 220127
Function IsNullOrEmpty([String]$Str) {
	[String]::IsNullOrWhiteSpace($Str)
}

Function Has-Value($Test) {
	-not [String]::IsNullOrWhiteSpace($Test)
}


#Endegion Tom-Tools: Allgemeine Funktionen



#Region Tom-Tools: String-Tools
#220127


# Delayed expansion of variables String
# Alias: Expand-String
Function Invoke-String($str) {
	$escapedString = $str -replace '"', '`"'
	Invoke-Expression "Write-Output `"$escapedString`""
}



# Umschliesst einen String mit einem Character. idR mit "
Function EncloseString($Path, $EnclosingChar = '"') {
	$EnclosingChar + $Path + $EnclosingChar
}


# Forciert, dass $Data die Windows-CRLF hat
Function Enforce-Win-CRLF($Data) {
	$Data -replace "`r(?!`n)|`n(?!`r)", "`r`n"
}


# Forciert, dass $Data die Linux-LF hat
# Ex
# $f1 = 'c:\Certificate.crt'
# $F1Cnt = [IO.File]::ReadAllText($f1) | % { Enforce-Linux-LF $_ } | % { Enforce-LastLine-End $_ -Linux }
Function Enforce-Linux-LF($Data) {
	$Data -replace "`r`n|`n`r", "`n"
}


# Stellt sicher, dass die letzte Zeile in $Data mit dem gewünschten NewLine endet
Function Enforce-LastLine-End() {
	Param (
		[Parameter(Position = 0, Mandatory)]
		[String]$Data,
		[Switch]$Windows,
		[Switch]$Linux,
		[Switch]$MacOS
	)

	If ($Data -eq $false -and $Windows -eq $false -and $Linux -eq $false -and $MacOS -eq $false) {
		Return $Data
	}

	If ($Windows) {
		If ($Data.EndsWith("`r`n")) {
			Return $Data
		}
		Return $Data + "`r`n"
	}
	If ($Linux) {
		If ($Data.EndsWith("`n")) {
			Return $Data
		}
		Return $Data + "`n"
	}
	If ($MacOS) {
		If ($Data.EndsWith("`r")) {
			Return $Data
		}
		Return $Data + "`r"
	}
}


# Data kann ein String oder ein Array von Strings sein
# Die Daten werden auf CRLF konvertiert
Function Trim-Lines() {
	Param (
		[Parameter(Position = 0, Mandatory)]
		[String]$Data,
		[Switch]$Trim,
		[Switch]$TrimStart,
		[Switch]$TrimEnd
	)

	If ($Trim -eq $false -and $TrimStart -eq $false -and $TrimEnd -eq $false) {
		Return $Data
	}

	# Den Parameter verarbeiten
	If ($Trim) { $Splat = @{ Trim = $true } }
	If ($TrimStart) { $Splat = @{ TrimStar = $true } }
	If ($TrimEnd) { $Splat = @{ TrimEnd = $true } }


	Switch ($Data.GetType().Name) {
		'String' {
			Trim-Lines_ -String $Data @Splat
		}
		'Object[]' {
			$Res = @()
			ForEach ($Item In $Data) {
				$Res += Trim-Lines_ -String $Item @Splat
			}
			$Res
		}
		default {
			Write-Host "(076ef222): Unbekannter Typ: $($Data.GetType().Name)"
		}
	}

}


Function Trim-Lines_() {
	Param (
		[Parameter(Position = 0, Mandatory)]
		[String]$String,
		[Switch]$Trim,
		[Switch]$TrimStart,
		[Switch]$TrimEnd
	)

	If ($Trim -eq $false -and $TrimStart -eq $false -and $TrimEnd -eq $false) {
		Return $String
	}

	$String = Enforce-Win-CRLF $String
	$Lines = $String -split "`r`n"
	$Res = $Lines | % {
		If ($Trim) {
			$_.Trim()
		}
		ElseIf ($TrimStart) {
			$_.TrimStart()
		}
		ElseIf ($TrimEnd) {
			$_.TrimEnd()
		}
	}
	$Res -join "`r`n"
}

#Endregion Tom-Tools: String-Tools



#Region Tom-Tools: Programmlogik

# Beispiele:
# IIf ( --$Week % $nthWeek -eq 0 ) $true	$false
# $a = IIf $Object {$_.Method()}
Function IIf($If, $IfTrue, $IfFalse) {
	If ($If -IsNot "Boolean") {
		$_ = $If
	}
	If ($If) {
		If ($IfTrue -is "ScriptBlock") {
			&$IfTrue
		} Else {
			$IfTrue
		}
	} Else {
		If ($IfFalse -is "ScriptBlock") {
			&$IfFalse
		} Else {
			$IfFalse
		}
	}
}

#Endregion Tom-Tools: Programmlogik



#Region Tom-Tools: PSCustomObject, PSObject

# Prüft, ob ein Objekt ein Property besitzt
# VORSICHT!, ist nicht ganz zuverlässig!, M$-Eigene Properties liefern manchmal falsche Ergebnisse
Function HasProperty ([object]$TestObject, [string]$propertyName) {
	If (Get-Member -Force -InputObject $TestObject -Name $propertyName -MemberType Properties) {
		$true
	} Else { $false }
}


# Define the default DisplaySet
# Set-PSCustomObject_DisplaySet $result ('Server', 'BackupTime', 'Hostname')
Function Set-PSCustomObject_DisplaySet($Obj, $DisplaySet) {
	If (-not ($Obj | Get-Member -Name 'PSStandardMembers' -Force)) {
		$defaultDisplayPropertySet = New-Object System.Management.Automation.PSPropertySet('DefaultDisplayPropertySet', [string[]]$DisplaySet)
		$PSStandardMembers = [System.Management.Automation.PSMemberInfo[]]@($defaultDisplayPropertySet)
		$Obj.PSObject.TypeNames.Insert(0, 'User.Information')
		$Obj | Add-Member MemberSet PSStandardMembers $PSStandardMembers
		$Obj
	}
}

#Endregion Tom-Tools: PSCustomObject



#Region Tom-Tools: Suchen und Einbinden von Scripts

### ℹ Anwendung

# $ScriptFileName = [IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Source)

# ## Config
# $BackupVeeam_ps1 = 'Backup-Veeam.ps1'
# $ConfigFile = "{0}-Config.ps1"

# ## Main
# $ScriptDir = Get-ScriptDir
# $ScriptName = Get-ScriptNameWithoutExtension
# $ConfigFile = $ConfigFile -f "$ScriptName"

# # 	$Res = [PSCustomObject][ordered]@{
# # 		ScriptFile = Das gefundene ScriptFile
# # 		HasErr	  = True: Das aufrufen des Scripts erzeugte einen Fehler
# # 		ScriptRes  = Das Resultat des aufgerufenen Scripts
# $BackupVeeam_ps1 = . Get-Script $ScriptDir $BackupVeeam_ps1 -ShowError:$true -LocalCachePrefix LocalCachePrefix
# $ConfigFile_ps1 = . Get-Script $ScriptDir $ConfigFile -ShowError:$true -dotSourceScript -LocalCachePrefix LocalCachePrefix



# 200127: Get-Script(): Switch Parameter besser geprüft
# 200515: Get-Script(): Findet ein lokaler Cache
# 200519: Get-Script(): Neu: $ScriptParameters
# 220127: Info ScriptDir Einzeiler


# Sucht das PowerShell Verzeichnis
Function Get-ScriptPowerShellDir($SubDir) {
	$Suche = '\powershell\'
	$DirPos = $SubDir.IndexOf($Suche, [System.StringComparison]::CurrentCultureIgnoreCase)
	If ($DirPos -gt 0) {
		$SubDir.SubString(0, $DirPos + $Suche.Length)
	}
}


# Sucht die Datei $aScriptName in:
# 1. In aScriptDir
# 2. In aScriptDir\* Rekursiv
# 3. In aScriptDir\powershell\* Rekursiv
# 4. Aufwärts in aScriptDir
#
# Res
# 	$FoundScript, $Res = Get-Script (Get-ScriptDir) $Get_O365_Config_ps1 -dotSourceScript
#                $Res = $null, wenn das Script nicht geladen wird
#
# 200420 Switch Parameter besser geprüft
# 200519 Neu: $ScriptParameters
# 				Parameter, die dem aufgerufenen Script übergeben werden können
# 				Ex
# 					If ($Silent) { $ScriptArgs = @{ Silent = $true } }
# 					$FoundScript, $Res = . Get-Script (Get-ScriptDir) $Get_O365_Config_ps1 -dotSourceScript -ScriptParameters $ScriptArgs
Function Get-Script() {
	[CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Low')]
	Param (
		[Parameter(Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'NoSwitches')]
		[Parameter(Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'CallScript')]
		[Parameter(Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'dotSourceScript')]
		[String]$aScriptDir,

		[Parameter(Position = 1, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'NoSwitches')]
		[Parameter(Position = 1, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'CallScript')]
		[Parameter(Position = 1, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'dotSourceScript')]
		[String]$aScriptName,

		# Aufruf mit &: Das Script aufrufen und nur das Resultat nützen
		# https://ss64.com/ps/call.html
		[Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'CallScript')]
		[Switch]$CallScript,

		# Aufruf mit .: Das Script einbetten, d.h. das Script im aktiven Scope aufrufen
		# https://ss64.com/ps/source.html
		[Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'dotSourceScript')]
		[Switch]$dotSourceScript,

		[Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'NoSwitches')]
		[Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'CallScript')]
		[Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'dotSourceScript')]
		[Switch]$ShowError = $true,

		[HashTable]$ScriptParameters = $null

	)

	# Verbose deaktivieren und später wieder herstellen
	$VerbosePreferenceBak = $VerbosePreference
	$VerbosePreference = 'SilentlyContinue'
	Try {
		# Erkennen, ob die Funktion DotSourced aufgerufen wurde
		Enum eCalledBy { Null; DotSource; CallOperator; Path; FunctionName }
		[eCalledBy]$CalledBy = [eCalledBy]::Null
		If ($MyInvocation.InvocationName -eq '&') {
			$CalledBy = [eCalledBy]::CallOperator
		} ElseIf ($MyInvocation.InvocationName -eq '.') {
			$CalledBy = [eCalledBy]::DotSource
		} Else {
			$CalledBy = [eCalledBy]::FunctionName
		}

		If ($CalledBy -ne ([eCalledBy]::DotSource)) {
			Write-Host 'Die Funktion(!) sollte DotSourced aufgerufen werden!: Get-Script()' -ForegroundColor Red
		}


		# 1. Sucht im ScriptDir selber
		If ($FoundScript = (Get-ChildItem -LiteralPath $aScriptDir -Filter $aScriptName | Select-Object -First 1).FullName) {
			Write-Verbose "Nütze Script: $FoundScript"
			If ($ScriptParameters -ne $null) {
				If ($CallScript) { Return @($FoundScript, (& $FoundScript @ScriptParameters)) }
				If ($dotSourceScript) { Return @($FoundScript, (. $FoundScript @ScriptParameters)) }
			} Else {
				If ($CallScript) { Return @($FoundScript, (& $FoundScript)) }
				If ($dotSourceScript) { Return @($FoundScript, (. $FoundScript)) }
			}
			Return $FoundScript
		}

		# 2. Sucht rekursiv im ScriptDir
		If ($FoundScript = (Get-ChildItem -LiteralPath $aScriptDir -Recurse -Filter $aScriptName | Select-Object -First 1).FullName) {
			Write-Verbose "Nütze Script: $FoundScript"
			If ($ScriptParameters -ne $null) {
				If ($CallScript) { Return @($FoundScript, (& $FoundScript @ScriptParameters)) }
				If ($dotSourceScript) { Return @($FoundScript, (. $FoundScript @ScriptParameters)) }
			} Else {
				If ($CallScript) { Return @($FoundScript, (& $FoundScript)) }
				If ($dotSourceScript) { Return @($FoundScript, (. $FoundScript)) }
			}
			Return $FoundScript
		}

		# 3. Sucht das Scripts\PowerShell Verzeichnis
		# und dann in allen Unterverzeichnissen
		If ($ScriptPowerShellDir = Get-ScriptPowerShellDir $aScriptDir) {
			If ($FoundScript = (Get-ChildItem -LiteralPath $ScriptPowerShellDir -Recurse -Filter $aScriptName | Select-Object -First 1).FullName) {
				Write-Verbose "Nütze Script: $FoundScript"
				If ($ScriptParameters -ne $null) {
					If ($CallScript) { Return @($FoundScript, (& $FoundScript @ScriptParameters)) }
					If ($dotSourceScript) { Return @($FoundScript, (. $FoundScript @ScriptParameters)) }
				} Else {
					If ($CallScript) { Return @($FoundScript, (& $FoundScript)) }
					If ($dotSourceScript) { Return @($FoundScript, (. $FoundScript)) }
				}
				Return $FoundScript
			}
		}

		# 4. Aufwärts in aScriptDir
		$ParentDir = Get-ParentDir $aScriptDir
		While ($ParentDir) {
			If ($FoundScript = (Get-ChildItem -LiteralPath $ParentDir -Filter $aScriptName | Select-Object -First 1).FullName) {
				Write-Verbose "Nütze Script: $FoundScript"
				If ($ScriptParameters -ne $null) {
					If ($CallScript) { Return @($FoundScript, (& $FoundScript @ScriptParameters)) }
					If ($dotSourceScript) { Return @($FoundScript, (. $FoundScript @ScriptParameters)) }
				} Else {
					If ($CallScript) { Return @($FoundScript, (& $FoundScript)) }
					If ($dotSourceScript) { Return @($FoundScript, (. $FoundScript)) }
				}
				Return $FoundScript
			}
			$ParentDir = Get-ParentDir $ParentDir
		}

		If ($ShowError) {
			Write-Host "Script fehlt  : $aScriptName"
			Write-Host "In Verzeichnis: $aScriptDir"
		}
	} Finally {
		$VerbosePreference = $VerbosePreferenceBak
	}
}


# Liefert $True,
# wenn ein Script von einem anderen Script
# und nicht von der Shell aus gestartet wurde
Function Is-CalledFromScript($ThisScriptName) {
	$CallStack = Get-PSCallStack | select -ExpandProperty Command
	$CallingScriptName = $CallStack[($CallStack.count - 2)]
	$CallingScriptName -ne $ThisScriptName
}

#Endregion Tom-Tools: Suchen und Einbinden von Scripts


#Region Tom-Tools: Network

# Ein schnelles Ping
# 220127
Function Test-Connection-Fast {
	<#
	.DESCRIPTION
		Test-ComputerConnection sends a ping to the specified computer or IP Address specified in the ComputerName parameter. Leverages the System.Net object for ping
		and measures out multiple seconds faster than Test-Connection -Count 1 -Quiet.
	.PARAMETER ComputerName
		The name or IP Address of the computer to ping.
	.EXAMPLE
		Test-ComputerConnection -ComputerName "THATPC"
		Tests if THATPC is online and returns a custom object to the pipeline.
	.EXAMPLE
		$MachineState = Import-CSV .\computers.csv | Test-ComputerConnection -Verbose

		Test each computer listed under a header of ComputerName, MachineName, CN, or Device Name in computers.csv and
		and stores the results in the $MachineState variable.
	.NOTES
		001, 220127
	#>
	[CmdletBinding()]
	Param (
		[Parameter(Mandatory, ValueFromPipeline, ValueFromPipelinebyPropertyName)]
		[Alias('CN', 'MachineName', 'Device Name')]
		[String]$ComputerName,
		[Int]$TimeoutMs = 500,
		[Int]$NoOfPings = 5,
		# Versucht stilldie Pings und bricht bei Erfolg ab
		[Switch]$TestForSuccess,
		# Maximum number of times the ICMP echo message can be forwarded before reaching its destination.
		# Results in: TtlExpired
		# Range is 1-255. Default is 64
		[Int]$TTL = 64,
		# Buffer used with this command. Default 32
		[Int]$Buffersize = 32,
		# Wenn true und das Paket ist für einen Router oder gateway zum Host
		# grösser als die MTU: Status: PacketTooBig
		[Switch]$DontFragment = $false,
		[Switch]$PassThru
	)

	Begin {
		$options = New-Object System.Net.Networkinformation.PingOptions
		$options.TTL = $TTL
		$options.DontFragment = $DontFragment
		$buffer=([System.Text.Encoding]::ASCII).getbytes('a' * $Buffersize)
		$ping = New-Object System.Net.NetworkInformation.Ping

		# mind. 1 Ping
		$NoOfPings = [Math]::Max($NoOfPings, 1)
		$DestinationReachedOnce = $False
		$ResPing = @()
	}

	Process {
		For ($Cnt = 0; $Cnt -lt $NoOfPings; $Cnt++) {
			Try {
				$reply = $ping.Send($ComputerName, $TimeoutMs, $buffer, $options)
			} Catch {
				$ErrorMessage = $_.Exception.Message
				Write-Host ($_ | Out-String)
				$Res = [PSCustomObject][Ordered]@{
					Message = ($_.ToString())
					ComputerName = $ComputerName
					Success = $False
					Timeout = $True
					Status = $ErrorMessage
				}
			}
			If ($reply.status -eq 'Success') {
				$Res = @{
					ComputerName = $ComputerName
					Success = $True
					Timeout = $False
					Status = $reply.status
				}
			} Else {
				$Res = [PSCustomObject][Ordered]@{
					ComputerName = $ComputerName
					Success = $False
					Timeout = $True
					Status = $reply.status
				}
			}
			If ($Res.Success) { $DestinationReachedOnce = $True }

			If ($TestForSuccess) {
				# Die Resultate sammeln
				$ResPing +=$Res
				# Bei Erfolg stoppen
				If ($DestinationReachedOnce) {
					If ($PassThru) {
						Return $ResPing
					} Else {
						Return $True
					}
				}
			} Else {
				If ($PassThru) {
					$Res
				} Else {
					$Res.Success
				}
			}
		}
		If ($TestForSuccess) {
			If ($PassThru) {
				Return $ResPing
			} Else {
				Return $DestinationReachedOnce
			}
		}
	}
	End{}
}

#EndRegion Tom-Tools: Network


#Region Tom-Tools: Enums


# !Ex Enum mit System.Flags und All / None Valie
#
# # Flag prüfen:
# ([eMediaType]::Video).HasFlag( [eMediaType]::Video )

# Add-Type -TypeDefinition @"
# [System.Flags]
# public enum eMediaType {
#   None = 0,
#   Audio = 1,
#   Video = 2,
#   All = (Audio | Video)
# }
# "@

# Setzt ein Flag und stellt sicher, dass $Flag zu $Enum passt
Function Set-Enum-Flag() {
	[CmdletBinding()]
	Param(
		[Enum]$Enum,
		[Enum]$Flag
	)

	If ($Enum.GetType().Name -ne $Flag.GetType().Name) {
		Write-Error "Inkompatible Enums: $($Enum.GetType().Name) und $($Flag.GetType().Name)"
	} Else {
		Return $Enum -bor $Flag
	}
	Return $Enum
}


# Löscht ein Flag und stellt sicher, dass $Flag zu $Enum passt
Function Clear-Enum-Flag() {
	[CmdletBinding()]
	Param(
		[Enum]$Enum,
		[Enum]$Flag
	)

	If ($Enum.GetType().Name -ne $Flag.GetType().Name) {
		Write-Error "Inkompatible Enums: $($Enum.GetType().Name) und $($Flag.GetType().Name)"
	} Else {
		If ($Enum.HasFlag($Flag)) {
			Return ($Enum -band (-bnot [Int]$Flag))
		}
	}
	Return $Enum
}


#EndRegion Tom-Tools: Enums


#Region Tom-Tools: Debugger

# Liefert true, wenn die Console von VSCode odere Sapien ist
Function Is-DebuggerVsCodeOrSapien() {
	switch ($Host.Name) {
		'Visual Studio Code Host' {
			Return $True
		}
		'PrimalScriptHostImplementation' {
			Return $True
		}
		Default {
			Return $False
		}
	}
}

#EndRegion Tom-Tools: Debugger


#Endregion Tom-Tools
