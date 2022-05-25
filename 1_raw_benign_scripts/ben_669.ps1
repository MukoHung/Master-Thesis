#----------------------------
# Filename: chkltyUpdater.ps1
# Author:   Josh Teeter
# Date:     2014-01-27
# Version:  1.0.0.0
# Purpose:  takes a list of chocolatey apps and updates them. :)
#----------------------------
#
# Get the current execution path
#
$fullPathIncFileName = $MyInvocation.MyCommand.Definition
$currentScriptName = $MyInvocation.MyCommand.Name
$currentExecutingPath = $fullPathIncFileName.Replace($currentScriptName, "")

#
# Read the list of apps to remove from the file
#
$filePath = $currentExecutingPath.ToString() + "update.list"
$strAppsToUpdate = Get-Content $filePath.ToString()


	foreach ($i in $strAppsToUpdate){
	    try{
			echo $i
			cup $i
	    }catch{
	    }#endTry
	}#endForEach

#shutdown.exe -s /t 0