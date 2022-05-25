###############################################################################
# Functions
###############################################################################
function Write-BoxstarterMessage
{
    param
    (
        [parameter(mandatory=$true)]
        [string]
        $Message
    )
    Write-Output ""
    Write-Output ""
    Write-Output "###############################################################################"
    #Write-Output $Message -ForeGroundColor Yellow
    Write-Output $Message
    Write-Output "###############################################################################"
}

###############################################################################
# Begin
###############################################################################
Write-BoxstarterMessage "Install NuGet"
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
Write-BoxstarterMessage "Trust PSGallery"
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
Write-BoxstarterMessage "Install AzureRM module"
Install-Module AzureRM -AllowClobber

Write-BoxstarterMessage "Boxstarter WinConfig Features"
Disable-BingSearch
Disable-GameBarTips
Disable-UAC
Set-TaskbarOptions -AlwaysShowIconsOff -Size Small -Dock Bottom -Combine Never
Set-TaskbarOptions -Lock 
Set-WindowsExplorerOptions -EnableShowFileExtensions -EnableShowFullPathInTitleBar

Write-BoxstarterMessage "choco - Install packages"
cinst -y docker
Write-BoxstarterMessage "Exit"
exit 0
#Write-BoxstarterMessage "Reboot"
#Invoke-Reboot
