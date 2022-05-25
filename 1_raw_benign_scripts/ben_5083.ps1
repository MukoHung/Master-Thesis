<#
#usage

#script_bentley_apps_install
#Downloads and installs bentley apps - For now, only the connection client
remove-item $env:TEMP\script_bentley_apps_install.ps1 -erroraction silentlycontinue
powershell -exec bypass -c "Invoke-WebRequest https://raw.githubusercontent.com/cgpdavid/public_files/main/script_bentley_apps_install.ps1 -OutFile $env:TEMP\script_bentley_apps_install.ps1"
powershell -exec bypass -c ". $env:TEMP\script_bentley_apps_install.ps1;"

#>

function CheckIfRunningAsAdmin {
If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")) {
    write-host "MUST BE RUN AS ADMIN - Exiting in 10 seconds!" -ForegroundColor RED
	sleep 10
    Exit
}elseif (([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")) {
	write-host "This script is running as administrator!" -ForegroundColor GREEN
}
}
CheckIfRunningAsAdmin
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -force

#Create ITs folders
remove-item $env:TEMP\func_CheckAndCreateITSFolders.ps1 -erroraction silentlycontinue
powershell -exec bypass -c "Invoke-WebRequest https://raw.githubusercontent.com/cgpdavid/public_files/main/func_CheckAndCreateITSFolders.ps1 -OutFile $env:TEMP\func_CheckAndCreateITSFolders.ps1"
powershell -exec bypass -c ". $env:TEMP\func_CheckAndCreateITSFolders.ps1; CheckAndCreateITSFolders"


write-host "--- ENTER Y for YES on any of the below prompts ---"
$askBentleyConnect = Read-Host "Install Bentley connect?"
$askBentleyStormCAD = Read-Host "Install Bentley StormCAD?"
$askBentleyimodel = Read-Host "Install Bentley i-model Publishing Engine"
$askBentleyCulvertMaster = Read-Host "Install Bentley CulvertMaster"
$askBentleyFlowMaster = Read-Host "Install Bentley FlowMaster?"
#$askBentley = Read-Host "Install Bentley"
#$askBentley = Read-Host "Install Bentley"



New-Item -Path "C:\itsupport\Installers\" -Name "Bentley" -ItemType "directory"
write-host "Downloading Bentley Prerequisites Installer"
write-host "This might take awhile - The installer is xxxxxxx"
Invoke-WebRequest "https://cdnllnw.bentley.com/s/bentley/productregistry/dist2/intel/v0811/desktopprerequisites/b8cef45f58f3408cbadd9518ba87ebc9/pbda08110706en.exe?e=1635463901.839352&h=e17dac0e0341f3d014a1bc2302158b38&x=pbda08110706en.exe" -OutFile C:\itsupport\Installers\Bentley\BentleyPrerequisites.exe

#Prerequisites for Bentley Desktop Applications (English)
#https://softwaredownloads.bentley.com/en/ProductDetails/1246
#https://cdnllnw.bentley.com/s/bentley/productregistry/dist2/intel/v0811/desktopprerequisites/b8cef45f58f3408cbadd9518ba87ebc9/pbda08110706en.exe?e=1635463901.839352&h=e17dac0e0341f3d014a1bc2302158b38&x=pbda08110706en.exe


if ($askBentleyConnect -eq 'y') {
	write-host "Downloading Bentley connect"
	write-host "This might take awhile - The installer is 230mb+"
	Invoke-WebRequest "https://www.bentley.com/en/Resources/Software/CONNECTION-Client-x64" -OutFile C:\itsupport\Installers\Bentley\BentleyConnectLatest.exe
	Start-Process C:\itsupport\Installers\Bentley\BentleyConnectLatest.exe  -ArgumentList "/s NoStartPostInstall=1"

}

if ($askBentleyStormCAD -eq 'y') {
	write-host "Not implimented yet! Sorry."
	write-host "Downloading Bentley StormCAD"
	#Invoke-WebRequest "https://www.bentley.com/en/Resources/Software/CONNECTION-Client" -OutFile C:\itsupport\Installers\Bentley\BentleyConnectLatest.zip
	
	#StormCAD CONNECT Edition x64 (SES) (English) 
	#https://softwaredownloads.bentley.com/en/ProductDetails/1246
	#https://cdnllnw.bentley.com/s/p/rl/dist2/intel/v1003/stormcadx64/f928f47aba434849b50fa0a800fe2349/stmc10030453en.exe?e=1635467498.5288565&h=35bef13a4d47e43099adc409faf69f28&x=stmc10030453en.exe

	
}

if ($askBentleyimodel -eq 'y') {
	write-host "Not implimented yet! Sorry."
	write-host "Downloading Bentley i-model"
	#Invoke-WebRequest "https://www.bentley.com/en/Resources/Software/CONNECTION-Client" -OutFile C:\itsupport\Installers\Bentley\BentleyConnectLatest.zip
	
	#i-model Publishing Engine for Hydraulics and Hydrology Beta 1 (English)
	#https://softwaredownloads.bentley.com/en/ProductDetails/1246
	#https://cdnllnw.bentley.com/s/bentley/productregistry/dist2/beta/intel/v0811/imodelenginehaestad/0f6270134058452baee323821a9ebefd/imeh08110704en.exe?e=1635463904.8354845&h=91c248f822cc9651d2811f93ea4192e3&x=imeh08110704en.exe

}

if ($askBentleyCulvertMaster -eq 'y') {
	write-host "Not implimented yet! Sorry."
	write-host "Downloading Bentley CulvertMaster"
	#Invoke-WebRequest "https://www.bentley.com/en/Resources/Software/CONNECTION-Client" -OutFile C:\itsupport\Installers\Bentley\BentleyConnectLatest.zip
	
	#Bentley CulvertMaster CONNECT Edition (SES) (English)
	#https://softwaredownloads.bentley.com/en/ProductDetails/1210
	#https://cdnllnw.bentley.com/s/p/rl/dist2/intel/v1003/culvertmaster/2222f2ad86324ab58466a8452a856d15/cvm10030003en.exe?e=1635464052.4784746&h=70c9eda3cf062a6bad2faa854232b6bc&x=cvm10030003en.exe

}

if ($askBentleyFlowMaster -eq 'y') {
	write-host "Not implimented yet! Sorry."
	write-host "Downloading Bentley FlowMaster"
	#Invoke-WebRequest "https://www.bentley.com/en/Resources/Software/CONNECTION-Client" -OutFile C:\itsupport\Installers\Bentley\BentleyConnectLatest.zip
	
	#Bentley FlowMaster CONNECT Edition (SES) (English) 
	#https://cdnllnw.bentley.com/s/p/rl/dist2/intel/v1003/flowmaster/75f02858d191437684dd9de5b5d9fa0e/fmw10030003en.exe?e=1635464107.1541858&h=b98734747945da5e33efdbfe5f59cfd8&x=fmw10030003en.exe

}



