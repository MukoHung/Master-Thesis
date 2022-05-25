cls
#First Thing First: Lets come to Script Directory

Function Get-ScriptDirectory
{
  $Invocation = (Get-Variable MyInvocation -Scope 1).Value
  Split-Path $Invocation.MyCommand.Path
}

cd (Get-ScriptDirectory)

#========================================================

# Delete any existing Txt Or CSV file

$BGInfoOutput = "$env:Temp\Bginfo.txt"
$BGInfoOutputCSV = "$env:Temp\Bginfo.CSV"

if((Test-Path $BGInfoOutput) -or (Test-Path $BGInfoOutputCSV))
{
  Remove-Item $BGInfoOutput -ErrorAction SilentlyContinue 
  Remove-Item $BGInfoOutputCSV -ErrorAction SilentlyContinue
}

#=== OutPut BGInfo to %Temp%\Bginfo.txt
# BGinfo.exe is kept @ .\BGInfo\Bginfo.exe

Start-Process -FilePath .\BGInfo\Bginfo.exe -ArgumentList '.\BGInfo\LFS.BGI  /TIMER:00 /SILENT /NOLICPROMPT' -Wait -NoNewWindow

#=== Create a Copy of TXT to CSV for PS manupulation

Copy-Item -Path $BGInfoOutput -Destination $BGInfoOutputCSV

#=== Read values from CSV

$colCSV = Import-Csv -Path $BGInfoOutputCSV

$colCSV



