#Uninstall 3D Builder
Get-AppxPackage *3dbuilder* | Remove-AppxPackage

#Uninstall Alarms and Clock
Get-AppxPackage *windowsalarms* | Remove-AppxPackage

#Uninstall Calculator
Get-AppxPackage *windowscalculator* | Remove-AppxPackage

#Uninstall Calendar and Mail:
Get-AppxPackage *windowscommunicationsapps* | Remove-AppxPackage

#Uninstall Camera:
Get-AppxPackage *windowscamera* | Remove-AppxPackage

#Uninstall Contact Support:
#This app can’t be removed.

#Uninstall Cortana:
#This app can’t be removed.

#Uninstall Get Office:
Get-AppxPackage *officehub* | Remove-AppxPackage

#Uninstall Get Skype:
Get-AppxPackage *skypeapp* | Remove-AppxPackage

#Uninstall Get Started:
Get-AppxPackage *getstarted* | Remove-AppxPackage

#Uninstall Groove Music:
Get-AppxPackage *zunemusic* | Remove-AppxPackage

#Uninstall Maps:
Get-AppxPackage *windowsmaps* | Remove-AppxPackage

#Uninstall Microsoft Edge:
#This app can’t be removed.

#Uninstall Microsoft Solitaire Collection:
Get-AppxPackage *solitairecollection* | Remove-AppxPackage

#Uninstall Money:
Get-AppxPackage *bingfinance* | Remove-AppxPackage

#Uninstall Movies & TV:
Get-AppxPackage *zunevideo* | Remove-AppxPackage

#Uninstall News:
Get-AppxPackage *bingnews* | Remove-AppxPackage

#Uninstall OneNote:
Get-AppxPackage *onenote* | Remove-AppxPackage

#Uninstall People:
Get-AppxPackage *people* | Remove-AppxPackage

#Uninstall Phone Companion:
Get-AppxPackage *windowsphone* | Remove-AppxPackage

#Uninstall Photos:
Get-AppxPackage *photos* | Remove-AppxPackage

#Uninstall Store:
Get-AppxPackage *windowsstore* | Remove-AppxPackage

#Uninstall Sports:
Get-AppxPackage *bingsports* | Remove-AppxPackage

#Uninstall Voice Recorder:
Get-AppxPackage *soundrecorder* | Remove-AppxPackage

#Uninstall Weather:
Get-AppxPackage *bingweather* | Remove-AppxPackage

#Uninstall Windows Feedback:
#This app can’t be removed.

#Uninstall Xbox:
Get-AppxPackage *xboxapp* | Remove-AppxPackage

#UPDATE 1 - New Apps
#Uninstall Reader:
Get-AppxPackage *Reader* | Remove-AppxPackage

#Uninstall Messaging:
Get-AppxPackage *Messaging* | Remove-AppxPackage

#Uninstall CommsPhone:
Get-AppxPackage *CommsPhone* | Remove-AppxPackage

#Uninstall ConnectivityStore:
Get-AppxPackage *ConnectivityStore* | Remove-AppxPackage

#Uninstall Sway (Office):
Get-AppxPackage *Office.Sway* | Remove-AppxPackage

#UPDATE 2 - New Apps
#Uninstall Twitter:
Get-AppxPackage *Twitter* | Remove-AppxPackage

#Uninstall TuneInRadio
Get-AppxPackage *TuneInRadio* | Remove-AppxPackage

#Uninstall Netflix
Get-AppxPackage *Netflix* | Remove-AppxPackage

#Uninstall Feedback Hub
Get-AppxPackage *WindowsFeedbackHub* | Remove-AppxPackage

#Uninstall OneConnect
Get-AppxPackage *OneConnect* | Remove-AppxPackage

#Extras
#Uninstall Sticky Notes
#Get-AppxPackage *MicrosoftStickyNotes* | Remove-AppxPackage

#Remove installed Games (no install auto, only first click shortcut)
#Uninstall Asphalt 8 Airborne
#Get-AppxPackage *GAMELOFTSA.Asphalt8Airborne* | Remove-AppxPackage

#Uninstall Candy Crush Saga
#Get-AppxPackage *king.com.CandyCrushSodaSaga* | Remove-AppxPackage

#Remove Windows Features
#Uninstall Internet Explorer (IE) 11
Disable-WindowsOptionalFeature -Online -FeatureName Internet-Explorer-Optional-amd64

#UPDATE 3 - Anniversary Update
#Uninstall Appconnector
Get-AppxPackage *Appconnector* | Remove-AppxPackage

#Uninstall StorePurchaseApp
Get-AppxPackage *StorePurchaseApp* | Remove-AppxPackage

#Remove 3D objects in profile folder
Remove-Item $env:USERPROFILE"\3D Objects"
