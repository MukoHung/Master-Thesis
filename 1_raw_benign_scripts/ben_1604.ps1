Function Get-CRC16 {
[CmdletBinding()]
Param (
[Parameter(Mandatory=$true, ValueFromPipeline=$true)]
[string]$String,
[Parameter(Mandatory=$false, ValueFromPipeline=$true)]
$CRCValue   # For future verification
)

$CRC      = 0xFFFF  # Set to 0x0000 for CRC-16/XMODEM, ACORN, LTE output
$Poly     = 0x1021
$ReflectD = $False  # Not used but for reference
$ReflCRCO = $False  # Not used but for reference
$XOR      = 0x0000  # Not used but for reference
$Check    = 0x29B1  # Not used but for reference

For ($i=0;$i -lt $String.Length;$i++) {

$CH = '0x' + "{0:x}" -f [int][char]$String[$i] -shl 8

For ($j=0;$j -lt 8;$j++) {

If (($CRC -bxor $CH) -band 0x8000) { $xor_flag = $True } Else { $xor_flag = $False }

$CRC = $CRC -shl 1

If ($xor_flag -eq $True) { $CRC = $CRC -bxor $Poly }

$CH = $CH -shl 1

}
}
  return '0x' + '{0:X2}' -f ($CRC -band 0xFFFF)
}