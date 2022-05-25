#Powershell will query the LN config and gather a list of folder locations (for file input, file output, grab and log if not default). These will then be created (should be easy)
#v1.021 new test

#Guids for each type of input
$guidFIn = 'e0f9db87-6d64-4341-964e-b5eff040bead'
$guidFOut =  '706b41a0-995b-4d0f-ac93-3d89da0ff0e9'
$guidPrIn =  'e1f5c233-a8f4-4122-a621-a21160f5fbbe'
$guidPrOut = '73074eb-5976-4c92-ac82-db2f4adcf13c'
$printerInputArray = @()
$printerOutputArray = @()

$buildRootDir = 'ModelBank'
$buildPath = gci -Path ".\${buildRootDir}\*.lnconfig"
$dir = $buildPath.directoryname
$modulesDir = "$buildRootDir\Modules\*.settings"
$instanceDir = "$buildRootDir\Computers"
$configFile = 'config.xml'
$computerName = $env:computername
$programData = 'C:\ProgramData\EFS Technology\Lasernet 7'
$lnReg = "HKLM:\SOFTWARE\Wow6432Node\EFS Technology\AUTOFORM LaserNet 7"
$lnVer = "HKLM:\SOFTWARE\Wow6432Node\EFS Technology\AUTOFORM LaserNet 7\Version"

if (Test-Path $lnReg)
{
	Write-Host "LaserNet already installed, please remove before continuing"
	$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
	exit
}

#Checks if demo licence is supplied
if (Test-Path *.license)
{
	$demoLic = gci -Path *.license
	Write-Debug "Demo licence found"
}
else
{
	$demoLic = ""
	Write-Debug "No Demo licence found"
}

if(( Get-ChildItem $instanceDir | Measure-Object ).Count -gt 2)
{
	Write-Host "Too many instances in build. Remove one and restart script."
	$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
	exit
}

#Gather settings from config file
[xml]$configXML = Get-Content $configFile
$svcLic = $configXML.lasernetconfig.svcLicence
$devLic = $configXML.lasernetconfig.devLicence
$instancename = $configXML.lasernetconfig.instance
$port = $configXML.lasernetconfig.port
$lasernetInstaller = gci -Path *.msi
$lnInstallDir = $configXML.lasernetconfig.install

#Check if instance name or port already exists
$svc = Get-Service -DisplayName "LaserNet 7 (${instancename}:*"
if ($svc.Length -gt 0)
{
	Write-Host "Instance name $instancename already exists"
	$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
	exit
}
$svc = Get-Service -DisplayName "LaserNet 7 (*:${port})"
if ($svc.Length -gt 0)
{
	Write-Host "Port of $port already exists"
	$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
	exit
}

#Check if demo licence or normal licence exists for Developer and Service
if ($svcLic -eq '' -AND $demoLic -eq "")
{
	Write-Host "No Licence Found for Service"
	$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
	exit
}
if ($devLic -eq '' -AND $demoLic -eq "")
{
	Write-Host "No Licence Found for Developer"
	$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
	exit
}

#If install folder is blank use default, if not use install folder in config file
if ($lnInstallDir -eq "")
{
	$lnArguements = "/i `"" + $lasernetInstaller.FullName + "`" /passive DEMO=1"
}
else
{
	$lnArguements = "/i `"" + $lasernetInstaller.FullName + "`" /passive DEMO=1 APPDIR=`"" + $lnInstallDir + "`""
}

Write-Debug "Start"


#Run through all modules in build
ForEach ($file in Get-ChildItem -Path $modulesDir)
{
	[xml]$moduleXML = Get-Content -Path $file
	$guid = ($moduleXML.settings.General.Type.getvalue(1)).innertext
	#If module is file input or output, check folder exists and if not create it
	Write-Debug "guid is $guid"
	if ($guid -eq $guidFIn)
	{
		$fileInput = $moduleXML.settings.path.innertext
		if (!(Test-Path $fileInput))
		{
			Write-Debug "Folder created $fileInput"
			New-Item $fileInput -type directory
		}
	}
	elseif ($guid -eq $guidFOut)
	{
		$fileOutput = $moduleXML.settings.Directory.innertext
		if (!(Test-Path $fileOutput))
		{
			Write-Debug "Folder created $fileOutput"
			New-Item $fileOutput -type directory
		}
	}
	elseif ($guid -eq $guidPrIn)
	{
		$printerInputArray += $moduleXML.settings.PrinterName.innertext
	}
	elseif ($guid -eq $guidPrOut)
	{
		$printerOutputArray += $moduleXML.settings.PrinterName.innertext
	}
}



#Loop through servers in the build that are not "Master.settings"
ForEach ($file in Get-ChildItem -path $instanceDir | ? { $_.Name -match '(?<!Master).settings$' })
{
	[xml]$instanceXML = Get-Content -Path $file.FullName
	#Create grab and log folders
	try
	{
		$logDir = $instanceXML.settings.Log.LogDirectory.innertext #put with other stuff
	}
	catch
	{
		Write-Debug "Log directory not set, using default"
		$logDir = ""
	}
	$grabDir = $instanceXML.settings.Grab.GrabDirectory.innertext
	
	#if instance names and port is set in config update the build, if not read default from build
	if ($port -eq "")
	{
		$port = ($instanceXML.settings.General.Port.getvalue(1)).innertext
	}
	else
	{
		$instanceXML.settings.General.Port.InnerText = $port
	}
	Write-Debug "port is $port"
	if ($instancename -eq "")
	{
		$instancename = ($instanceXML.settings.General.ObjectName.getvalue(1)).innertext
	}
	else
	{
		$instanceXML.settings.General.ObjectName.InnerText = $instancename ### needs checking
	}
	Write-Debug "Instance name is $instancename"
	$instanceXML.settings.General.Server.InnerText = $computerName
	$fullName = $file.FullName
	#Output changes into instance in build folder
	$instanceXML.Save($fullName)
	Write-Debug "Log directory is $logDir"
	#Create paths for log and grab folders
	if ($logDir -eq $null)
	{
		Write-Debug "Default log location used - No folder created"
	}
	elseif (!(Test-Path $logDir))
	{
		Write-Debug "Creating folder $logDir"
		New-Item $logDir -type directory
	}
	Write-Debug "Grab directory is $grabDir"
	if (!(Test-Path $grabDir))
	{
		Write-Debug "Creating folder $grabDir"
		New-Item $grabDir -type directory
	}
}

Start-Sleep -Seconds 1
#Install LaserNet
Write-Debug "LaserNet installing" 
try 
{
	Start-Process -FilePath msiexec.exe -ArgumentList $lnArguements -Verb runAs -Wait
}
catch
{
	Write-Host "LaserNet not installed due to $_"
	$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
	exit
}
Write-Debug "LaserNet Installed" 

#Licence after lasernet is installed
$registryVal = Get-ItemProperty $lnReg
$LNPath = $registryVal.path
Write-Debug "Install path is $LNPath"
$serPath = $LNPath + "LnService.exe"
$devPath = $LNPath + "LnDeveloper.exe"
$lndeploy = $LNPath + "lndeploy.exe"
$LMPath = $LNPath + "LnLicenseManager.exe" #licence mananger path
$demoLMPath = $LNPath +"LnDemoLicenceManager.exe"


	#Install Service
	#Create arguments list for licencing
	$licArguements = "install -n " + $instancename + " -p " + $port
 	Write-Debug "Arguements for licence $licArguements"
	#Create instance, pauses until process is finished
	Write-Debug "Creating Instance ${instancename}:${port}"
	Start-Process -FilePath $LMPath -ArgumentList $licArguements -wait
 	Write-Debug "Instance created"
	
	#Checking instance was created
	$serviceName = "Lasernet 7 (${instancename}:${port})"
	Write-Debug "Service Name is $serviceName"
	$service = Get-Service  $serviceName
	if ($service -eq $null)
	{
		Write-Host "Instance not installed"
		$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
		exit
	}
 
	write-debug "The installation of the LaserNet instance $instancename has finished"
	Stop-Process -ProcessName lnlic*
	
	#Uses demo licence manager to licence LN
	Write-Debug "Install Demo licence for SVC"
	#If demo licence, creates instance folder in programdata and copies in demo licence
	if(!(Test-Path "$programData\$instancename"))
	{
		New-Item -ItemType directory -Path "$programData\$instancename"
	}
	if(!(Test-Path "$programData\*-*-*-*-*"))
	{
		Write-Debug "Developer started"
		Start-Process $devPath
		start-sleep -s 5
		Stop-Process -ProcessName lndeveloper
 		Write-Debug "Developer stopped"
	}
	#New licence manager stuff here
	$demoLicArgs = $demoLic.FullName
	Write-Debug "Demo Lic Args are $demoLicArgs"
	Write-Debug "Demo LM File Path are $demoLMPath"
	Start-Process -FilePath $demoLMPath -ArgumentList "`"$demoLicArgs`"" | Out-Null

#LaserNet Service will be started must be run as admin
Write-Debug "Starting Service"
Start-Service "LaserNet 7 (${instancename}:${port})"
start-sleep -s 5
#Deploy build
Write-Debug "Uploading Build"
$arguements = "-c  $dir -d ${computerName}:${port}"
Write-Debug "Arguements for build is $arguements"
Write-Debug "Deploy is  $lndeploy"
Start-Process -FilePath $lndeploy -ArgumentList $arguements