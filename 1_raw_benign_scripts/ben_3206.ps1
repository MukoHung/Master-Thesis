param (
	[String]$File
)

function Func_Demo([String]$s) {
	Write-Output $s
}

if ([String]::IsNullOrWhiteSpace($File) -or (($File -eq "--help") -or ($File -eq "-h") -or ($File -eq "-?"))) {
	Write-Output "[pwsh] Usage: pwsh <FILE> OR .\pwsh.ps1 <FILE>"
} elseif (-not (Test-Path $File)) {
	Write-Output "[pwsh] Error: File '$File' not found!"
} else {
	foreach($Line in [System.IO.File]::ReadLines(((Get-Item $File).FullName))) {
		if (-not ([String]::IsNullOrWhiteSpace($Line))) {
			Func_Demo($Line)
		}
	}
}
