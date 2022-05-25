#############################################################
# AppUpdate-Start.ps1                                #
# Programmers: Greg Carriger                                #
# Date: November 2020                                       #
#############################################################

# Load variables
$PSScriptRoot
invoke-expression -Command $PSScriptRoot\AppUpdate-Config.ps1

do
 {
    Show-CodeMoveMenu
    $selection = Read-Host "Please make a selection"
    switch ($selection)
    {
    '1' {
	$global:01Status = "Started"
    invoke-expression -Command $PSScriptRoot\AppUpdateFiles\AppUpdate-01.ps1
    } '2' {
    $global:02Status = "Started"
	invoke-expression -Command $PSScriptRoot\AppUpdateFiles\AppUpdate-02.ps1
    } '3' {
	$global:03Status = "Started"
    invoke-expression -Command $PSScriptRoot\AppUpdateFiles\AppUpdate-03.ps1
    } '4' {
    $global:04Status = "Started"
	invoke-expression -Command $PSScriptRoot\AppUpdateFiles\AppUpdate-04.ps1
    } '5' {
    $global:05Status = "Started"
	invoke-expression -Command $PSScriptRoot\AppUpdateFiles\AppUpdate-05.ps1
    } '6' {
    $global:06Status = "Started"
	invoke-expression -Command $PSScriptRoot\AppUpdateFiles\AppUpdate-06.ps1
    } '7' {
    $global:07Status = "Started"
	invoke-expression -Command $PSScriptRoot\AppUpdateFiles\AppUpdate-07.ps1
    } '8' {
    $global:08Status = "Started"
	invoke-expression -Command $PSScriptRoot\AppUpdateFiles\AppUpdate-08.ps1
    } '9' {
    $global:09Status = "Started"
	invoke-expression -Command $PSScriptRoot\AppUpdateFiles\AppUpdate-09.ps1
    } '10' {
    $global:10Status = "Started"
	invoke-expression -Command $PSScriptRoot\AppUpdateFiles\AppUpdate-10.ps1
	} '11' {
    $global:11Status = "Started"
	invoke-expression -Command $PSScriptRoot\AppUpdateFiles\AppUpdate-11.ps1
	} '12' {
    $global:12Status = "Started"
	invoke-expression -Command $PSScriptRoot\AppUpdateFiles\AppUpdate-12.ps1
	} '13' {
    $global:13Status = "Started"
	invoke-expression -Command $PSScriptRoot\AppUpdateFiles\AppUpdate-13.ps1
	} '14' {
    $global:14Status = "Started"
	invoke-expression -Command $PSScriptRoot\AppUpdateFiles\AppUpdate-14.ps1
	} '15' {
    $global:15Status = "Started"
	invoke-expression -Command $PSScriptRoot\AppUpdateFiles\AppUpdate-15.ps1
	} '16' {
    $global:16Status = "Started"
	invoke-expression -Command $PSScriptRoot\AppUpdateFiles\AppUpdate-16.ps1
    	} '17' {
    $global:17Status = "Started"
	invoke-expression -Command $PSScriptRoot\AppUpdateFiles\AppUpdate-17.ps1
    	} '18' {
    $global:18Status = "Started"
	invoke-expression -Command $PSScriptRoot\AppUpdateFiles\AppUpdate-18.ps1
    	} '19' {
    $global:19Status = "Started"
	invoke-expression -Command $PSScriptRoot\AppUpdateFiles\AppUpdate-19.ps1
    	} '20' {
    $global:20Status = "Started"
	invoke-expression -Command $PSScriptRoot\AppUpdateFiles\AppUpdate-20.ps1
    	} '21' {
    $global:21Status = "Started"
	invoke-expression -Command $PSScriptRoot\AppUpdateFiles\AppUpdate-21.ps1
    	} '22' {
    $global:22Status = "Started"
	invoke-expression -Command $PSScriptRoot\AppUpdateFiles\AppUpdate-22.ps1
    	}

     }
pause
 }
 until ($selection -eq 'q')