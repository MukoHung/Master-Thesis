param(
    [string][Parameter(Mandatory=$true)]$InputFile,
    [string][Parameter(Mandatory=$true)]$OutputFile,
    [int]$SampleRate = 44100,
    [string]$BitRate = "160k"
)

$ErrorActionPreference = "Stop"

$InputFile = [System.IO.Path]::Combine((Get-Location), $InputFile)
$OutputFile = [System.IO.Path]::Combine((Get-Location), $OutputFile)
$OutputFilePath = [System.IO.Path]::GetDirectoryName($OutputFile)
if ((Test-Path -LiteralPath $OutputFilePath) -eq $false) {
    New-Item -type directory -path $OutputFilePath | out-null
}

$TempFile = [System.IO.Path]::GetTempFileName()

$ErrorActionPreference = "Continue"

try {
    ffmpeg -i "$InputFile" -y -ar $SampleRate -ac 2 -b:a $BitRate -map_metadata 0 -id3v2_version 3 "$OutputFile" 2>&1 >$TempFile
    if ($global:LASTEXITCODE -ne 0) {
        Get-Content $TempFile
        Write-Error "ffmpeg failure"
        exit -1
    }
}
finally {
    Remove-Item -LiteralPath $TempFile -ErrorAction Ignore
}

$Error.Clear()
