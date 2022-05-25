$currentdirectory = split-path -parent $MyInvocation.MyCommand.Definition
Set-Location $currentdirectory
#(Get-Location).Path
#######################################################################################################################

# Descargar desde Github 
$token = "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"
$headers = @{Authorization = "token $($token)"}
Invoke-WebRequest -Headers $headers -Uri "https://raw.githubusercontent.com/despegar/Scripts-Win10/main/Install-Avaya/ProcessUpdateLatest.ps1" -UseBasicParsing -OutFile "$currentdirectory\ProcessUpdateLatest.ps1"

#& .\ProcessUpdate.ps1

#Start-Process -Wait PowerShell.exe -ArgumentList "& .\ProcessUpdatelatestV2.ps1"

Start-Process -Wait PowerShell.exe -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File "ProcessUpdateLatest.ps1"'

Remove-Item ProcessUpdateLatest.ps1

#Pause


<#
# Destruction Block
mkdir $env:TEMP\paraborrar\ -Force
Write-Output $currentdirectory > $env:TEMP\paraborrar\pathfiles.txt

Write-Output {
    
    $pathfiles = Get-Content $env:TEMP\paraborrar\pathfiles.txt
    Remove-Item $pathfiles\ProcessUpdateLatest.ps1 -Force

} > $env:TEMP\paraborrar\borrado.ps1

 

& $env:TEMP\paraborrar\borrado.ps1


#>