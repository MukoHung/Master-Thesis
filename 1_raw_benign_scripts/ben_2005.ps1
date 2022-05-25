Set-StrictMode -Version latest
$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

# default installation directory
$dmd_install = "C:\D"

echo "Fetching latest DMD version..."
$dmd_version = [System.Text.Encoding]::ASCII.GetString((Invoke-WebRequest -URI "http://downloads.dlang.org/releases/LATEST").content)
$dmd_url = "http://downloads.dlang.org/releases/2.x/$dmd_version/dmd.$dmd_version.windows.zip"
$dmd_filename = [System.IO.Path]::GetFileName($dmd_url)
$dmd_archive = Join-Path (pwd).path $dmd_filename

echo "Downloading $dmd_filename..."
$client = new-object System.Net.WebClient
$client.DownloadFile($dmd_url, $dmd_archive)

echo "Extracting $dmd_filename..."
Expand-Archive $dmd_archive -Force -DestinationPath $dmd_install

# add to environment path
echo "Installing DMD..."
$dmd_bin = Join-Path $dmd_install "dmd2\windows\bin"
$Env:Path = $Env:Path + ";" + $dmd_bin

echo "Testing DMD..."
& dmd.exe --version 2>&1>$null