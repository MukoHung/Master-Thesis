Get-Command *user* -Module msonline

Get-Help Get-msoluser

#Hledani modulu v PowerShell galerii
Find-Module -Name *teams*

# Informace o napojene repository a pripadny prehled vsech instalovanych modulu
Get-PSRepository
Get-InstalledModule

# Jako prvni je potreba nainstalovat vsechny potrebne moduly
# -Scope CurrentUser nam umoznuje instalovat v kontextu aktualniho uzivatele. Samotne moduly jsou pak dostupne $home\Documents\WindowsPowerShell\Modules
# https://docs.microsoft.com/en-us/powershell/module/powershellget/install-module?view=powershell-5.1
Install-Module MSOnline -Scope CurrentUser # Microsoft365
Install-Module AzureADPreview -Scope CurrentUser # AzureAD
Install-Module Microsoft.Online.SharePoint.PowerShell -Scope CurrentUser # SharePoint
Install-Module ExchangeOnlineManagement -Scope CurrentUser -Force # Exchange Online
Install-Module MicrosoftTeams -Scope CurrentUser # Microsoft Teams
Install-Module Microsoft.PowerApps.Administration.PowerShell -Scope CurrentUser # Microsoft Power Apps a Power Automate (Flow) cmdlety
Install-Module Microsoft.PowerApps.PowerShell -Scope CurrentUser -AllowClobber
#Skype Online je pouze ke stazeni, je potreba ke sprave politik pro MS Teams

# Pripadne se da na zacatek skriptu pridat tato cast, abychom zajistili ze bude k dispozici dany modul s cmdlety
try {
    Import-Module MicrosoftTeams -ErrorAction Stop
} catch {
    Install-Package MicrosoftTeams -Scope CurrentUser
    Import-Module MicrosoftTeams
}

#Pro MS Teams existuje pre-release verze modulu a ta je k dispozici v PowerShell Test Gallery
#Doporucuje se napred odinstalovat aktualni verzi modulu MS Teams a teprve pote instalovat tu z test galerie
#https://www.poshtestgallery.com/packages/MicrosoftTeams/1.0.24
Uninstall-Module -Name MicrosoftTeams
Register-PSRepository -Name PSGalleryInt -SourceLocation https://www.poshtestgallery.com/ -InstallationPolicy Trusted
#Unregister-PSRepository -Name PSGalleryInt #Odregistrace PSGalerie
Install-Module -Name MicrosoftTeams -Repository PSGalleryInt -Force
Get-Module MicrosoftTeams

#Update verze modulu
Install-Module MicrosoftTeams -Scope CurrentUser -Force

# Import-Module MSOnline a ostatni moduly
Import-Module MicrosoftTeams
Import-Module ExchangeOnlineManagement
Import-Module MSOnline
Import-Module AzureADPreview
Import-Module Microsoft.Online.SharePoint.PowerShell

# Ziskani pristupovych udaju
$credential = Get-Credential -UserName "admin@KrtekCompany.onmicrosoft.com" -Message "Login"

# Dnes si budu hrat s timto uctem
$userPN = "AllanD@KrtekCompany.OnMicrosoft.com"



