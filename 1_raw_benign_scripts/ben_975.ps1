param([Parameter(Mandatory = $True)]$ProjectName)
mkdir $ProjectName
Set-Location .\$ProjectName
mkdir Srcs
mkdir Srcs\sim
mkdir Srcs\source
mkdir Srcs\constraint
mkdir IP
mkdir output
mkdir BlockDesign

vivado.bat -mode batch -source ..\CreateNewProject.tcl
Remove-Item *.jou
Remove-Item *.log
Remove-Item .Xil/

Copy-Item ..\CreateNewProject.tcl .\build_project.tcl

New-Item "build_project.ps1"
Write-Output "vivado -mode batch -source .\build_project.tcl" >> "build_project.ps1"
Write-Output "Remove-Item *.jou" >> "build_project.ps1"
Write-Output "Remove-Item *.log" >> "build_project.ps1"
Write-Output "Remove-Item .Xil/" >> "build_project.ps1"

New-Item "update_project.ps1"
Write-Output "vivado -mode batch -source .\update_project.tcl" >> "update_project.ps1"
Write-Output "Remove-Item *.jou" >> "update_project.ps1"
Write-Output "Remove-Item *.log" >> "update_project.ps1"
Write-Output "Remove-Item .Xil/" >> "update_project.ps1"

Copy-Item ..\update_project.tcl .\update_project.tcl
