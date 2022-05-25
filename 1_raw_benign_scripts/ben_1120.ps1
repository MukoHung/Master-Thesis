Update-ExecutionPolicy -Policy Unrestricted

Get-AppxPackage -Name Microsoft.ZuneVideo | Remove-AppxPackage
Get-AppxPackage -Name Microsoft.ZuneMusic | Remove-AppxPackage
Get-AppxPackage -Name Microsoft.BingFinance | Remove-AppxPackage
Get-AppxPackage -Name Microsoft.BingWeather | Remove-AppxPackage
Get-AppxPackage -Name Microsoft.BingNews | Remove-AppxPackage
Get-AppxPackage -Name Microsoft.Getstarted | Remove-AppxPackage
Get-AppxPackage -Name Microsoft.Windows.Photos | Remove-AppxPackage
Get-AppxPackage -Name Microsoft.XboxApp | Remove-AppxPackage
Get-AppxPackage -Name Microsoft.windowscommunicationsapps | Remove-AppxPackage
Get-AppxPackage -Name Microsoft.windowscamera | Remove-AppxPackage
Get-AppxPackage -Name Microsoft.people | Remove-AppxPackage
Get-AppxPackage -Name Microsoft.office.onenote | Remove-AppxPackage

Set-StartScreenOptions -EnableListDesktopAppsFirst
Set-CornerNavigationOptions -EnableUsePowerShellOnWinX
Set-WindowsExplorerOptions -EnableShowHiddenFilesFoldersDrives -EnableShowFileExtensions -EnableShowFullPathInTitleBar

cinst -y git -params '"/GitOnlyOnPath"'
cinst -y poshgit
cinst -y googlechrome
cinst -y notepad2-mod
cinst -y fiddler4
cinst -y procexp
cinst -y conemu