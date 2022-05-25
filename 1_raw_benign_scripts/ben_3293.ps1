############################################################
# Powershell script to remove shit features bundled in Windows 10
# Removes junk bundled with Windows 10
# App list: https://www.howtogeek.com/224798/how-to-uninstall-windows-10s-built-in-apps-and-how-to-reinstall-them/
# King shit: https://care.king.com/en/candy-crush-soda-saga/how-to-remove-candy-crush-soda-saga-from-windows-10-with-a-powershell-command
# Author: Joshua Haupt josh@hauptj.com Date: 19.12.2017
############################################################


##### Remove Awesome Features #####

# Remove Windows Store
Write-Host "Removing Windows Store"
Get-AppxPackage *windowsstore* | Remove-AppxPackage

# Remove Get Started
Write-Host "Removing Get Started"
Get-AppxPackage *getstarted* | Remove-AppxPackage

# Remove Windows Phone Companion
Write-Host "Removing Windows Phone Companion"
Get-AppxPackage *windowsphone* | Remove-AppxPackage

# Remove Xbox
Write-Host "Removing Xbox App"
Get-AppxPackage *xboxapp* | Remove-AppxPackage

# Remove People App
Write-Host "Removing People"
Get-AppxPackage *people* | Remove-AppxPackage

# Remove 3D Builder
Write-Host "Removing 3D Builder"
Get-AppxPackage *3dbuilder* | Remove-AppxPackage

# Remove Photos
Write-Host "Removing Photos"
Get-AppxPackage *photos* | Remove-AppxPackage

# Remove Camera
Write-Host "Removing Camera"
Get-AppxPackage *windowscamera* | Remove-AppxPackage

# Remove Voice Recorder
Write-Host "Removing Voice Recorder"
Get-AppxPackage *soundrecorder* | Remove-AppxPackage

# Remove Calendar and Mail
Write-Host "Removing Calendar and Mail"
Get-AppxPackage *windowscommunicationsapps* | Remove-AppxPackage

# Remove Alarms and Clock
Write-Host "Removing Alarms and Clock"
Get-AppxPackage *windowsalarms* | Remove-AppxPackage

# Remove Calculator
Write-Host "Removing Calculator"
Get-AppxPackage *windowscalculator* | Remove-AppxPackage

# Remove Get Office
Write-Host "Get Office"
Get-AppxPackage *officehub* | Remove-AppxPackage

# Remove OneNote
Write-Host "Removing OneNote"
Get-AppxPackage *onenote* | Remove-AppxPackage

# Remove Bing Maps
Write-Host "Removing Bing Maps"
Get-AppxPackage *windowsmaps* | Remove-AppxPackage

# Remove Bing Finance / Money
Write-Host "Removing Bing Finance / Money"
Get-AppxPackage *bingfinance* | Remove-AppxPackage

# Remove Zune / Windows Video
Write-Host "Removing Zune / Windows Video"
Get-AppxPackage *zunevideo* | Remove-AppxPackage

# Remove Zune / Windows Video
Write-Host "Removing Zune / Groove Music"
Get-AppxPackage *zunemusic* | Remove-AppxPackage

# Remove Solitaire
Write-Host "Removing Solitaire"
Get-AppxPackage *solitairecollection* | Remove-AppxPackage

# Remove Bing Sports
Write-Host "Removing Bing Sports"
Get-AppxPackage *bingsports* | Remove-AppxPackage

# Remove Bing News
Write-Host "Removing Bing News"
Get-AppxPackage *bingnews* | Remove-AppxPackage

# Remove Bing Weather
Write-Host "Removing Bing Weather"
Get-AppxPackage *bingweather* | Remove-AppxPackage

# Remove Skype App
Write-Host "Removing Skype App"
Get-AppxPackage *skypeapp* | Remove-AppxPackage

# Remove King shit
Write-Host "Removing King Shit"
Get-AppxPackage *king.com* | Remove-AppxPackage
# Just to be sure ...
Get-AppxPackage -Name 'king.com.CandyCrushSodaSaga' | Remove-AppxPackage

