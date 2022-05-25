# Generate a random Alphanumeric string

Function Get-RandomAlphanumericString {
	
	[CmdletBinding()]
	Param (
        [int] $length = 8
	)

	Begin{
	}

	Process{
        Write-Output ( -join ((0x30..0x39) + ( 0x41..0x5A) + ( 0x61..0x7A) | Get-Random -Count $length  | % {[char]$_}) )
	}	
}


# Write-Host ("Alfa Beta " | Tee-Object -Variable txt) ($txt.length)

Write-Host "A: "(Get-RandomAlphanumericString | Tee-Object -variable teeTime ) ("len=$($teeTime.length)")
Write-Host "B: "(Get-RandomAlphanumericString -length 22 | Tee-Object -variable teeTime ) ("len=$($teeTime.length)")

