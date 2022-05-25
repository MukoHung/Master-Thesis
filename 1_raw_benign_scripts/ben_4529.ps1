# caveat emptor, this worked for me, be careful, your milage may vary

# to remove “consumer” Windows Store apps like Weather, Finance, News from Windows 8:
# http://blogs.technet.com/b/deploymentguys/archive/2012/10/26/removing-built-in-applications-from-windows-8.aspx

# remove the apps from the current user account. it will clean up your start screen, basically.
# you will likely see errors when this runs, but it’s still effective
Get-AppXPackage | Remove-AppxPackage

# this removes the apps from the machine entirely
Get-AppXProvisionedPackage -online | Remove-AppxProvisionedPackage –online

# to remove visual studio advertising sdk
# http://stackoverflow.com/questions/24134693/how-to-uninstall-the-microsoft-advertising-sdk-visual-studio-extension/24449757#24449757
gwmi Win32_Product -Filter "Name LIKE 'Microsoft Advertising%'" | foreach { $_.Uninstall() }

# to remove visual studio windows phone tools
gwmi Win32_Product -Filter "Name LIKE 'Windows Phone%'" | foreach { $_.Uninstall() }
