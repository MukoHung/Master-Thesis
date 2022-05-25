if ($PSVersionTable.PSVersion.Major -lt 5) {
    Write-Error "Powershell version 5 or later is required."
    exit 1
}
function Compare-With-Current-Dxlib-Version ($dxlib_txt, $dxlib_expect_version) {
    return (Test-Path $dxlib_txt) -And ($dxlib_expect_version -eq ([regex]"Ver ([0-9]+\.[0-9a-z]+)").Matches((Get-Content $dxlib_txt))[0].Groups[1].value.Replace(".", "_"));
}
[System.Console]::Write("fetch DxLib...")
$ProgressPreference = 'SilentlyContinue'
$dlhtml = Invoke-WebRequest -Uri "http://dxlib.o.oo7.jp/dxdload.html"
try {
    $null = $dlhtml -match '<A HREF="(http[s]*:\/\/[^/]+\/DxLib\/DxLib_VC[\d\w_/.:]+\.(exe|zip))">'
} catch {
    exit 1
}
$dllink = $matches[1];
$dlext = $matches[2];
$null = $dllink -match "DxLib_VC([\d\w_/.:]+)\.$dlext"
$dxlib_version = $matches[1];
Write-Output "done."
$dxlib_txt = "DxLib_VC\DxLib.txt"
if ((Test-Path "DxLib_VC") -And (Compare-With-Current-Dxlib-Version $dxlib_txt $dxlib_version)){
    Write-Output "DxLib version $dxlib_version detect. skip install."
} else {
    if (!(Test-Path "DxLib_VC$dxlib_version.$dlext")) {
        # ensure current directory when executed from powershell
        [System.IO.Directory]::SetCurrentDirectory((Get-Location -PSProvider FileSystem).Path)
        Write-Output "Downloading DxLib($dxlib_version) from: $dllink"
        $cli = New-Object System.Net.WebClient
        try {
            $uri = New-Object Uri($dllink)
            $cli.DownloadFile($uri, "DxLib_VC$dxlib_version.$dlext")
        } finally {
            $cli.Dispose()
        }
        # Invoke-WebRequest -Uri $dllink -OutFile "DxLib_VC$dxlib_version.$dlext"
        Write-Output "done."
    } else {
        Write-Output "DxLib_VC$dxlib_version.$dlext found. Download skip."
    }
    [System.Console]::Write("Extracting...")
    if ((Test-Path "DxLib_VC")) {
        Rename-Item -path "DxLib_VC" -newName "DxLib_VC_old"
    }
    if ($dlext -eq "zip") {
        $zip_path = "DxLib_VC$dxlib_version.zip";
        $zip = Get-Item $zip_path
        $dirname = $zip.Basename
        New-Item -Force -ItemType directory -Path $dirname
        $global:ProgressPreference = 'SilentlyContinue'
        if (0 -eq $PSVersionTable.PSVersion.Minor) {
            Expand-Archive $zip_path -OutputPath $dirname
        } else {
            Expand-Archive -Path $zip_path -DestinationPath $dirname
        }
        Move-Item -Path "$dirname/DxLib_VC" -Destination "DxLib_VC"
        Remove-Item -path $dirname -recurse -force
    } else {
        Start-Process -FilePath "DxLib_VC$dxlib_version.exe" -Wait
    }
    if ((Test-Path "DxLib_VC") -And (Compare-With-Current-Dxlib-Version $dxlib_txt $dxlib_version)) {
        Write-Output "done."
        [System.Console]::Write("Delete old DxLib_VC and temporary file...")
        if ((Test-Path "DxLib_VC_old")) {
            Remove-Item -path "DxLib_VC_old" -recurse -force
        }
        Remove-Item -path "DxLib_VC$dxlib_version.$dlext" -ErrorAction Ignore
        Write-Output "done."
    } else {
        Rename-Item -path "DxLib_VC_old" -newName "DxLib_VC"
        Write-Output "failed."
        exit 1
    }
}

$root_path = Get-ChildItem -Path .\DxLib_VC\ -Recurse -File -Include "DxLib.h"
if ($root_path.Length -ne 0) {
    [System.Console]::Write("setting to environment variable...")
    $env:DXLIB_ROOT=$root_path.DirectoryName
    Write-Output "done."
} else {
    Write-Output "failed."
    exit 1
}
