function ConvertFrom-UserParameter {
<#
.SYNOPSIS

Converts a userparameters encoded blob into an ordered dictionary of decoded values.

Author: Will Schroeder (@harmj0y)
License: BSD 3-Clause
Required Dependencies: None

.DESCRIPTION

This function will take a userparameters blob from an active directory user
and decodes the arbitrary format into human readable values.
Heavily based on Cybericom's PoC code at https://social.technet.microsoft.com/Forums/scriptcenter/en-US/953cd9b5-8d6f-4823-be6b-ebc009cc1ed9/powershell-script-to-modify-the-activedirectory-userparameters-attribute-to-set-terminal-services?forum=ITCG

.PARAMETER Value

Specifies the string blob to decode.

.PARAMETER ShowAll

Switch. Signals ConvertFrom-UserParameter to display all values, including null/blank values.

.EXAMPLE

Get-NetUser testuser | ConvertFrom-UserParameter

Name                           Value
----                           -----
CtxCfgPresent                  1428032432
CtxMinEncryptionLevel          1
CtxWFProfilePath               \\primary\blah.profile
CtxWFProfilePathW              \\primary\blah.profile
CtxShadow                      EnableInputNoNotify
CtxMaxDisconnectionTime        0
CtxMaxConnectionTime           0
CtxMaxIdleTime                 0
CtxCfgFlags1                   {INHERITMAXDISCONNECTIONTIME, DISABLECCM, INH...
CtxInitialProgram              \\server\evil.exe
CtxInitialProgramW             \\server\evil.exe

.EXAMPLE

Get-NetUser testuser | ConvertFrom-UserParameter -ShowAll

Name                           Value
----                           -----
CtxCfgPresent                  1428032432
CtxMinEncryptionLevel          1
CtxWFProfilePath               \\primary\blah.profile
CtxWFProfilePathW              \\primary\blah.profile
CtxWFHomeDir
CtxWFHomeDirW
CtxWFHomeDirDrive
CtxWFHomeDirDriveW
CtxShadow                      EnableInputNoNotify
CtxMaxDisconnectionTime        0
CtxMaxConnectionTime           0
CtxMaxIdleTime                 0
CtxWorkDirectory
CtxWorkDirectoryW
CtxCfgFlags1                   {INHERITMAXDISCONNECTIONTIME, DISABLECCM, INH...
CtxInitialProgram              \\server\evil.exe
CtxInitialProgramW             \\server\evil.exe

.INPUTS

String

Accepts an string representing a user userparameters binary blob.

.OUTPUTS

System.Collections.Specialized.OrderedDictionary

An ordered dictionary with the converted user userparameter fields.

.LINK

https://social.technet.microsoft.com/Forums/scriptcenter/en-US/953cd9b5-8d6f-4823-be6b-ebc009cc1ed9/powershell-script-to-modify-the-activedirectory-userparameters-attribute-to-set-terminal-services?forum=ITCG

https://msdn.microsoft.com/en-us/library/ff635169.aspx
#>

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $True, ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)]
        [Alias('userparameters')]
        [String]
        $Value,

        [Switch]
        $ShowAll
    )

    BEGIN {
        # values from https://msdn.microsoft.com/en-us/library/ff635169.aspx
        $CtxCfgFlagsBitValues = @{
                        'INHERITCALLBACK' = 0x08000000
                        'INHERITCALLBACKNUMBER' = 0x04000000
                        'INHERITSHADOW' = 0x02000000
                        'INHERITMAXSESSIONTIME' = 0x01000000
                        'INHERITMAXDISCONNECTIONTIME' = 0x00800000
                        'INHERITMAXIDLETIME' = 0x00400000
                        'INHERITAUTOCLIENT' = 0x00200000
                        'INHERITSECURITY' = 0x00100000
                        'PROMPTFORPASSWORD' = 0x00080000
                        'RESETBROKEN' = 0x00040000
                        'RECONNECTSAME' = 0x00020000
                        'LOGONDISABLED' = 0x00010000
                        'AUTOCLIENTDRIVES' = 0x00008000
                        'AUTOCLIENTLPTS' = 0x00004000
                        'FORCECLIENTLPTDEF' = 0x00002000
                        'DISABLEENCRYPTION' = 0x00001000
                        'HOMEDIRECTORYMAPROOT' = 0x00000800
                        'USEDEFAULTGINA' = 0x00000400
                        'DISABLECPM' = 0x00000200
                        'DISABLECDM' = 0x00000100
                        'DISABLECCM' = 0x00000080
                        'DISABLELPT' = 0x00000040
                        'DISABLECLIP' = 0x00000020
                        'DISABLEEXE' = 0x00000010
                        'WALLPAPERDISABLED' = 0x00000008
                        'DISABLECAM' = 0x00000004
        }
    }
    PROCESS {

        $UserParameterBytes = [System.Text.Encoding]::UNICODE.GetBytes($Value)
        $MemoryStream = New-Object -TypeName System.IO.MemoryStream -ArgumentList @(,$UserParameterBytes)
        $BinaryReader = New-Object -TypeName System.IO.BinaryReader -ArgumentList $MemoryStream, ([Text.Encoding]::Unicode)
        $ResultValues = New-Object System.Collections.Specialized.OrderedDictionary

        # [0-95] -> reserved
        $Null = $BinaryReader.ReadBytes(96)

        # [96-97] -> signature: @(80,0) (UNICODE 'P')
        $Signature = $BinaryReader.ReadUInt16()

        if ($Signature -eq 80) {
            Write-Verbose 'Signature match'

            # [97-98] -> number of attributes in blob
            $NumAttributes = $BinaryReader.ReadUInt16()
            Write-Verbose "Number of attributes found in blob: $NumAttributes"

            1..$NumAttributes | % {
                # 2 bytes for the name length 
                $NameLength = $BinaryReader.ReadUInt16()
                Write-Verbose "NameLength: $NameLength"

                # 2 bytes for the value length
                $ValueLength = $BinaryReader.ReadUInt16()
                Write-Verbose "ValueLength: $ValueLength"

                # 2 bytes for the type
                $Type = $BinaryReader.ReadUInt16()

                $AttributeName = [System.Text.Encoding]::UNICODE.GetString($BinaryReader.ReadBytes($NameLength))
                $AttributeData = $BinaryReader.ReadBytes($ValueLength)
                Write-Verbose "AttributeName: $AttributeName"

                if ($AttributeName -match 'CtxCfgPresent|CtxCfgFlags1|CtxCallBack|CtxKeyboardLayout|CtxMinEncryptionLevel|CtxNWLogonServer|CtxMaxConnectionTime|CtxMaxDisconnectionTime|CtxMaxIdleTime|CtxShadow|CtxMinEncryptionLevel') {
                    $AttributeData = -join($AttributeData | ForEach-Object {[Char][Byte]$_})
                    $AttributeValue = [Convert]::ToInt32($AttributeData, 16)
                    
                    if ($AttributeName -match 'CtxShadow') {
                        $AttributeValue = Switch ($AttributeValue) {
                            0x0         { 'Disable' }
                            0x1000000   { 'EnableInputNotify' }
                            0x2000000   { 'EnableInputNoNotify' }
                            0x3000000   { 'EnableNoInputNotify' }
                            0x4000000   { 'EnableNoInputNoNotify' }
                            default     { $AttributeValue }
                        }
                    }
                    elseif ($AttributeName -match 'CtxCfgFlags1') {
                        # this field is represented as a bitmask
                        $CtxCfgFlags1 = New-Object System.Collections.ArrayList
                        $CtxCfgFlagsBitValues.GetEnumerator() | ForEach-Object {
                            if (($AttributeValue -band $_.Value) -eq $_.Value) {
                                $Null = $CtxCfgFlags1.Add($_.Name)
                            }
                        }
                        $AttributeValue = $CtxCfgFlags1.ToArray()
                    }
                    $ResultValues.Add($AttributeName, $AttributeValue)
                }
                elseif ($AttributeName -match 'CtxWFHomeDirDrive|CtxWFHomeDir|CtxWFHomeDrive|CtxInitialProgram|CtxWFProfilePath|CtxWorkDirectory|CtxCallbackNumber') {
                    $AttributeValue = ''
                    For ($i = 0; $i -lt $ValueLength; $i += 2) {
                        $ValueChar = [Char][Byte]([Convert]::ToInt16([Char][byte]$AttributeData[$i] + [char][byte]$AttributeData[$i+1], 16))
                        $AttributeValue += $ValueChar
                    }
                    if ($AttributeName -match ',*w$') {
                        # handle wide strings
                        $AttributeValue = [System.Text.Encoding]::UNICODE.GetString([System.Text.Encoding]::ASCII.GetBytes($AttributeValue))
                    }
                    if($ShowAll -or ($AttributeValue.Length -ne 1)) {
                        $ResultValues.Add($AttributeName, $AttributeValue)
                    }
                }
                else {
                    Write-Verbose "Unrecognized AttributeName: $AttributeName"
                }
            }
        }
        $BinaryReader.Close()
        $MemoryStream.Close()

        $ResultValues
    }
}
