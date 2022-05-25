<#	
	.NOTES
	===========================================================================
	 Created on:   	2021-11-23 9:36 AM
	 Created by:   	Marc Collins
	 Email:         Marc.Collins@qlik.com
	 Organization: 	Qlik
	 Filename:     	Export_QV_LoadScript.ps1
	===========================================================================
#>

#Start QlikView Desktop
$QV = New-Object -ComObject QlikTech.Qlikview

#Wait for QlikView Desktop to fully launch
$QV.WaitForIdle() | Out-Null
$Global:QVVersion = $QV.QvVersion()
$QVPID = $QV.GetProcessId()
$QV.DisableDialogs($true)

#Specify the Folder to scan for QV Documents
$ScanFolder = "C:\ProgramData\QlikTech\SourceDocuments"

#Get all of the QV documents in folder
$QVWFiles = Get-ChildItem -Recurse -Path $ScanFolder -Filter "*.qvw"
foreach ($QVWFile in $QVWFiles)
{
	#Open the Document without Data
	$QVDoc = $QV.OpenDocEx($QVWFile.FullName, 0, $false, $null, $null, $null, $true, $true)
	
	#Get the properties so we can access the script
	$QVDocProperties = $QVDoc.GetProperties()
		
	###### DO Something with this.......
	$ScriptFile = "$([System.IO.Path]::GetTempPath())$($QVWFile.Name).txt"
	$QVDocProperties.Script | Out-file -FilePath $ScriptFile -Encoding utf8
	notepad.exe $ScriptFile
	
	#Close the Document
	$QVDoc.CloseDoc()
}

#Quit QlikView Desktop
$QV.Quit()