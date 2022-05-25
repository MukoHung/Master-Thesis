<#
    .SYNOPSIS
        Remove Visio 2010 AppV Package
    .DESCRIPTION
        Controller script to invoke 'Remove-Package' cmdlet
    .EXAMPLE
        . .\$PSScriptRoot\Remove-AppvPackage.ps1
    .LINK
        Links to further documentation
    .NOTES
        Version : 1.0
        Date Created : 28/04/2016
        Created by : Graham Beer
#> 

#Dot source the script
. $PSScriptRoot\Remove-AppvPackage.ps1

#splat the arguements to pass to 'Remove-AppvPackage' cmdlet
$RemoveVisio = @{
    
    AppVPackage = 'Microsoft_Visio_Standard_2010SP1'
    Shortcut = 'Microsoft Visio 2010.lnk'
    FlagFileName = 'Visio_2010_Removal' # .flg extension created by 'Remove-AppvPackage.ps1' script.
    
    }
#Run the code to remove Visio 2010
Remove-AppvPackage @RemoveVisio