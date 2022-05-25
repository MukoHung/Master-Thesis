#Name: PS-ResetWUMU.ps1
#Author: github.com/livkx
#Decription: Reset WUMU config, cache, certs. Then, run a scan and try check in with WSUS.
#Version: 1.0

#Declare the functions we're going to use in the main function.
Function ServiceControlAndWait{ #Function stops the Windows Update related services.
	param([Parameter(Position = 0)] [String[]] $Services, [String] $MaxWait, [String] $Action)

	ForEach($Service in $Services){
		$ServiceObject = Get-Service $Service
		Switch($Action){
			"Stop" {
				Stop-Service $ServiceObject
				$ServiceObject.WaitForStatus("Stopped","00:00:$MaxWait") #Waits for svc to be stopped or hit maxwait seconds before continuing to next service in array.
			}
			"Start" {
				Start-Service $ServiceObject
				$ServiceObject.WaitForStatus("Running","00:00:$MaxWait") #Waits for svc to be stopped or hit maxwait seconds before continuing to next service in array.
			}
		}
	}
}

Function DeleteRegKeys{
	$Keypath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\"
	$ValueArray = @("SusClientId","SusClientIDValidation")

	ForEach($RegValue in $ValueArray){
		Remove-ItemProperty -path $KeyPath -name $RegValue
	}
}

Function RemoveDirectories{
	$SoftwareDistribution = "$env:windir\SoftwareDistribution\"
	$Catroot2 = "$env:windir\System32\catroot2\"
	
	Get-ChildItem -path $SoftwareDistribution -Recurse | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
	Remove-Item $SoftwareDistribution -Force -ErrorAction SilentlyContinue
	Get-ChildItem -path $Catroot2 -Recurse | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
	Remove-Item $Catroot2 -Force -ErrorAction SilentlyContinue #This could sometimes fail because I've seen CryptSvc get restarted automatically before this operation is called.
}

Function ScanAndReportWSUS{
	param([Bool[]] $AttemptLegacy)

	Start-Process -FilePath "UsoClient.exe" -ArgumentList "RefreshSettings" #Refresh the Windows Update settings before scanning.
	Start-Process -FilePath "UsoClient.exe" -ArgumentList "StartScan" #This *should* report into WSUS if it detects anything.
	if($AttemptLegacy -eq $true){
		Start-Sleep -Seconds 60 #This is just in case the command below is functional on the target OS build. It's inconsistent.
		Start-Process -FilePath "wuauclt.exe" -ArgumentList "/reportnow" #Attempt legacy wuauclt reportnow command.
	}
}

Function Start-Script{
	ServiceControlAndWait -Services wuauserv,bits,cryptsvc,msiserver -MaxWait 20 -Action stop #Specify services, the maximum wait time for each service to stop before continuing, stop or start.
	DeleteRegKeys
	RemoveDirectories
	ServiceControlAndWait -Services wuauserv,bits,cryptsvc,msiserver -MaxWait 15 -Action start
	ScanAndReportWSUS -AttemptLegacy $true #Set to true or false based on if to try a legacy report.
	exit #End the session.
}

# Start point
Start-Script