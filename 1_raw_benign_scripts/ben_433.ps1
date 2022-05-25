Clear-Host
#--------------------------------------------------------------
# Create Image base image is nanoserver
#--------------------------------------------------------------
#& .\BCOMScripting\BCDevImage\BCOm_SetGlobalVar.ps1
#. .\BCOMScripting\BCDevImage\BCOm_SetGlobalVar.ps1
. .\BCOm_SetGlobalVar.ps1
$hostname = "ImageServer"
$devimage ='BCDevImage'
$PathScripting = Join-Path 'C:\GIT\PowerShellScripts\BCOMScripting' $devimage
$PathDestination = Join-Path $DockerVol $devimage 
$PathShare = $DockerVol +":" + $HostVol

$PathImage = Join-Path $HostVol "BCDevImage"
#$PathShare
#New-Item -Path $PathDestination -ItemType Directory -Force

<#
Copy-Item -Path (Join-Path $PathScripting "BCOMStart.ps1") -Destination $PathDestination -force
Copy-Item -Path (Join-Path $PathScripting "BCOM_ImportModules.ps1") -Destination $PathDestination -force
Copy-Item -Path (Join-Path $PathScripting "BCOM_InstallBCOnPremFromDVD.ps1") -Destination $PathDestination -force
#>
Copy-Item -Path $PathScripting  -Destination $PathDestination -force


<#
vorhandenen hostz anhalten und entfernen,soll immer neu erzeugt werden
#>

docker stop $hostname
docker rm $hostname

<#
host in der powershell starten
#>
docker run --name $hostname  -it -w ($PathImage) -v ($PathShare)  mcr.microsoft.com/windows/servercore "powershell" 
#manuell??
#docker exec -it $hostname "powershell" 

#----------------------------------------------------
<#>
docker stop $hostname
docker rm $hostname
docker run --name $hostname  -it -w ($PathImage) -v ($PathShare)  mcr.microsoft.com/windows/nanoserver
docker run --name $hostname  -it -w ($PathImage) -v ($PathShare)  mcr.microsoft.com/windows/servercore
docker start $hostname
docker exec -it $hostname cmd [Environment]::SetEnvironmentVariable("HTTP_PROXY", "http://proxy.bechtle.de:80", [EnvironmentVariableTarget]::Machine)
docker exec -it $hostname "powershell" 
#>

<#>
docker start $hostname
docker exec -it $hostname "powershell c:\HostFiles\BCDevImage\BCOMStart.ps1"
docker exec -it $hostname "powershell 'c:\HostFiles\BCDevImage\BCOM ImportModules.ps1'"
docker exec -it $hostname "powershell 'c:\HostFiles\BCDevImage\InstallBCOnPremImageFromDVD.ps1'"
powershell version
in  
$hostname = 'psnanoserver'
docker stop $hostname
docker rm $hostname
docker ps -a

get-command -Module Containers
#>



<#>
#docker run --name  myserver -it -v "C:\DockerFiles:c:\HostFiles"  mcr.microsoft.com/windows/servercore powershell
Clear-Host

docker run --name  myserver -it -v "C:\DockerFiles:c:\HostFiles"  mcr.microsoft.com/windows/servercore
docker run --name  myserver -it -v "C:\DockerFiles:c:\HostFiles"  mcr.microsoft.com/windows/nanoserver
docker start myserver
Copy-Item -Path C:\GIT\PowerShellScripts\BCOMScripting\BCDevImage\"BCOM ImportModules.ps1" -Destination C:\DockerFiles\bcdevimage -force
Copy-Item -Path C:\GIT\PowerShellScripts\BCOMScripting\BCDevImage\"InstallBCOnPremImageFromDVD.ps1" -Destination C:\DockerFiles\bcdevimage -force
Copy-Item -Path C:\GIT\PowerShellScripts\BCOMScripting\BCDevImage\"BCOMStart.ps1" -Destination C:\DockerFiles\bcdevimage -force

#docker exec -it -w "c:\hostfiles"myserver cmd  

docker exec -it  -w "c:\hostfiles\BCDevImage" myserver powershell 
#docker exec -it  -w "c:\hostfiles" myserver powershell; BCOMStart.ps1
docker exec -it  -w "c:\hostfiles\BCDevImage" myserver powershell BCOMStart.ps1
#docker exec myserver cmd exit
#docker exec -it myserver powershell  .\InstallBCOnPremImageFromDVD.ps1
#dir c:\dockerfiles
#dir c:\hostfiles
exit

docker stop  myserver 
docker rm myserver
dir
#>