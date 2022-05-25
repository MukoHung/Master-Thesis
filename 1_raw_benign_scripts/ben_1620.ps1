Function Get-DirHash {
    [Cmdletbinding()]
    Param(
        [Parameter(Mandatory=$true)]
        [ValidateScript({
            if(Test-Path -Path $_ -ErrorAction SilentlyContinue)
            {
                return $true
            }
            else
            {
                throw "$($_) is not a valid path."
            }
        })]
        [string]$Path
    )
    $temp=[System.IO.Path]::GetTempFileName()
    gci -File -Recurse $Path | Get-FileHash | select -ExpandProperty Hash | Out-File $temp -NoNewline
    $hash=Get-FileHash $temp
    Remove-Item $temp
    $hash.Path=$Path
    return $hash
}