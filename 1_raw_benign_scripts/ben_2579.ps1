function New-SYSVOLZip {
<#
.SYNOPSIS

Compresses all folders/files in SYSVOL to a .zip file.

Author: Will Schroeder (@harmj0y)  
License: BSD 3-Clause  
Required Dependencies: None

.PARAMETER Domain

The domain to clone GPOs from. Defaults to $ENV:USERDNSDOMAIN.

.PARAMETER Path

The output file for the zip archive, defaults to "$Domain.sysvol.zip".
#>

    [CmdletBinding()]
    Param(
        [Parameter(Position = 0)]
        [ValidateNotNullOrEmpty()]
        [String]
        $Domain = $ENV:USERDNSDOMAIN,

        [Parameter(Position = 1)]
        [Alias('Out', 'OutFile')]
        [ValidateNotNullOrEmpty()]
        [String]
        $Path
    )

    if ($PSBoundParameters['Path']) {
        $ZipPath = $PSBoundParameters['Path']
    }
    else {
        $ZipPath = "$($Domain).sysvol.zip"
    }

    if (-not (Test-Path -Path $ZipPath)) {
        Set-Content -Path $ZipPath -Value ("PK" + [char]5 + [char]6 + ("$([char]0)" * 18))
    }
    else {
        throw "Output zip path '$ZipPath' already exists"
    }

    $ZipFileName = (Resolve-Path -Path $ZipPath).Path
    Write-Verbose "Outputting to .zip file: $ZipFileName"

    $SysVolPath = "\\$($ENV:USERDNSDOMAIN)\SYSVOL\"
    Write-Verbose "Using SysVolPath: $SysVolPath"
    $SysVolFolder = Get-Item "\\$($ENV:USERDNSDOMAIN)\SYSVOL\"

    # create the zip file
    $ZipFile = (New-Object -Com Shell.Application).NameSpace($ZipFileName)

    # 1024 -> do not display errors
    $ZipFile.CopyHere($SysVolFolder.FullName, 1024)
    "$SysVolPath zipped to $ZipFileName"
}
