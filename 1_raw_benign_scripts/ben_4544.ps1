$ErrorActionPreference = 'Stop'

Set-WindowsExplorerOptions -EnableShowHiddenFilesFoldersDrives -EnableShowProtectedOSFiles -EnableShowFileExtensions
Set-TaskbarOptions -Size Large -Combine Full -UnLock
Disable-GameBarTips
Disable-BingSearch
Disable-InternetExplorerESC
Set-CornerNavigationOptions -EnableUsePowerShellOnWinX