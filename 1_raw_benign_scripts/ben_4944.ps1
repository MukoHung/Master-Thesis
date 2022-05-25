# IGNORE THIS ERROR! IGNORE THIS ERROR! JUST A POWERSHELL THING THAT HAPPENS ON THE FIRST LINE OF A POWERSHELL SCRIPT 

# Cimitra Cimitra Windows Printer Control Install Script
# Author: Tay Kratzer tay@cimitra.com
# 9/8/2021

Write-Output "IGNORE THIS ERROR! IGNORE THIS ERROR! JUST A POWERSHELL THING THAT HAPPENS ON THE FIRST LINE OF A POWERSHELL SCRIPT"

function CHECK_ADMIN_LEVEL{

if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
[Security.Principal.WindowsBuiltInRole] "Administrator")) {
Write-Output ""
Write-Warning "Insufficient permissions to run this script. Open the PowerShell console as an administrator and run this script again."
Write-Output ""
exit 1
}

}
CHECK_ADMIN_LEVEL


$global:INSTALLATION_DIRECTORY = "C:\cimitra\scripts\printer"
 
write-output ""
write-output "START: INSTALLING - Cimitra Windows Printer Control Practice"
write-output "------------------------------------------------------------"


if ($args[0]) { 
    $global:INSTALLATION_DIRECTORY = $args[0]
}

try{
    New-Item -ItemType Directory -Force -Path $INSTALLATION_DIRECTORY 2>&1 | out-null
}catch{}

$theResult = $?

if (!($theResult)){
    Write-Output "Error: Could Not Create Installation Directory: $INSTALLATION_DIRECTORY"
    exit 1
}

try{
Set-Location -Path $INSTALLATION_DIRECTORY
}catch{
Write-Output ""
Write-Output "Error: Cannot access directory: $INSTALLATION_DIRECTORY"
Write-Output ""
exit 1
}


$CurrentPath = Get-Location
$CurrentPath= $CurrentPath.Path

$CIMITRA_SCRIPT_DOWNLOAD = "https://raw.githubusercontent.com/cimitrasoftware/windows_printer/main/PrinterControl.ps1"
$CIMITRA_JSON_DOWNLOAD = "https://raw.githubusercontent.com/cimitrasoftware/windows_printer/main/ControlPrinter.json"
$CIMITRA_IMPORT_READ_ZIP = "https://github.com/cimitrasoftware/windows_printer/raw/main/read_first.zip"

$CIMITRA_SCRIPT_DOWNLOAD_OUT_FILE = "$INSTALLATION_DIRECTORY\PrinterControl.ps1"
$CIMITRA_JSON_DOWNLOAD_OUT_FILE = "$INSTALLATION_DIRECTORY\ControlPrinter.json"
$CIMITRA_IMPORT_READ_ZIP_OUT_FILE = "$INSTALLATION_DIRECTORY\read_first.zip"


$ThisScript = $MyInvocation.MyCommand.Name



$global:runSetup = $true


$EXTRACTED_DIRECTORY = "$INSTALLATION_DIRECTORY\printer-main"



if($Verbose){
    Write-Output ""
    Write-Output "Downloading File: $CIMITRA_SCRIPT_DOWNLOAD"
}else{
    Write-Output ""
    Write-Output "Downloading Script File From GitHub"
}

try{
    $RESULTS = Invoke-WebRequest $CIMITRA_SCRIPT_DOWNLOAD -OutFile $CIMITRA_SCRIPT_DOWNLOAD_OUT_FILE -UseBasicParsing 2>&1 | out-null
}catch{}

$theResult = $?

if (!$theResult){
    Write-Output "Error: Could Not Download The File: $CIMITRA_SCRIPT_DOWNLOAD"
    exit 1
}

if($Verbose){
    Write-Output ""
    Write-Output "Downloading File: $CIMITRA_JSON_DOWNLOAD"
}else{
    Write-Output ""
    Write-Output "Downloading JSON File From GitHub"
}

try{
    $RESULTS = Invoke-WebRequest $CIMITRA_JSON_DOWNLOAD -OutFile $CIMITRA_JSON_DOWNLOAD_OUT_FILE -UseBasicParsing 2>&1 | out-null
}catch{}

$theResult = $?

if (!$theResult){
    Write-Output "Error: Could Not Download The File: $CIMITRA_JSON_DOWNLOAD"
    exit 1
}


if($Verbose){
    Write-Output ""
    Write-Output "Downloading Readme/Import Instruction Files: $CIMITRA_IMPORT_READ_ZIP"
}else{
    Write-Output "Downloading Readme/Import Instruction Files"
}

try{
    $RESULTS = Invoke-WebRequest $CIMITRA_IMPORT_READ_ZIP -OutFile $CIMITRA_IMPORT_READ_ZIP_OUT_FILE -UseBasicParsing 2>&1 | out-null
}catch{}

$theResult = $?

if (!$theResult){
    Write-Output "Error: Could Not Download The File: $CIMITRA_IMPORT_READ_ZIP"
}

if($Verbose){
    Write-Output ""
    Write-Output "Extracting File: $CIMITRA_IMPORT_READ_ZIP_OUT_FILE"
    Write-Output ""
}
 

Expand-Archive $CIMITRA_IMPORT_READ_ZIP_OUT_FILE -Destination $INSTALLATION_DIRECTORY -Force

$theResult = $?

if (!$theResult){
Write-Output "Error: Could Not Extract File: $CIMITRA_DOWNLOAD_IMPORT_READ_OUT_FILE"
exit 1
}

try{
    $SUCCESS = Remove-Item -Path $CIMITRA_DOWNLOAD_IMPORT_READ_OUT_FILE -Force -Recurse -ErrorAction SilentlyContinue 2>&1 | out-null
}catch{}

Write-Output ""
Write-Host "Configuring Windows to Allow PowerShell Scripts to Run" -ForegroundColor blue -BackgroundColor white
Write-Output ""
Write-Output ""
Write-Host "If Prompted: Use 'A' For 'Yes to All'" -ForegroundColor blue -BackgroundColor white
Write-Output ""
Unblock-File * 

try{
    powershell.exe -NonInteractive -Command Set-ExecutionPolicy Unrestricted -ErrorAction SilentlyContinue 2>&1 | out-null
}catch{
    Set-ExecutionPolicy Unrestricted -ErrorAction SilentlyContinue 2>&1 | out-null
}

try{
    powershell.exe -NonInteractive -Command Set-ExecutionPolicy Bypass -ErrorAction SilentlyContinue 2>&1 | out-null
}catch{
    Set-ExecutionPolicy Bypass -ErrorAction SilentlyContinue 2>&1 | out-null 2> $null 1> $null
}

try{
    powershell.exe -NonInteractive -Command Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope Process -ErrorAction SilentlyContinue 2>&1 | out-null
}catch{

    try{
        Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope Process -ErrorAction SilentlyContinue *> $null | out-null
    }catch{}
}

try{
    powershell.exe -NonInteractive -Command Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope CurrentUser -ErrorAction SilentlyContinue 2>&1 | out-null
}catch{
    Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope CurrentUser -ErrorAction SilentlyContinue 2>&1 | out-null
    }

try{
    powershell.exe -NonInteractive -Command Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope LocalMachine -ErrorAction SilentlyContinue 2>&1 | out-null
}catch{
    Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope LocalMachine -ErrorAction SilentlyContinue 2>&1 | out-null
}


$RTFFileExists = Test-Path -Path C:\cimitra\scripts\printer\read_first.rtf -PathType Leaf

if($RTFFileExists){

& "C:\Program Files\Windows NT\Accessories\wordpad.exe" "C:\cimitra\scripts\printer\read_first.rtf"
}