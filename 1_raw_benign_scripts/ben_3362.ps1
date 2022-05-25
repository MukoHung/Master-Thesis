<#
    Windows 8 RETRO Script

    Removes as much METRO as possible. Stay RETRO my friend.

    Policies:
    1.- Disable the hot corners
    2.- Disable forced reboots for Windows Updates
    3.- Disable Microsoft Account Linking
    4.- Disable Lock Screen
    5.- Disable Metro Tutorial
    6.- Disable Windows Store
    7.- Disable SkyDrive
    8.- Disable booting directly into metro (boots into Windows 8.1 Desktop)
    9.- Disable Charms bar
    10.- Set All Apps page as default in Start Metro Screen


    Actions:
    1.- Install Clasic Shell
    2.- Remove All Metro Apps

#>

function Set-RegKey
{
    Param( $regkey )

    if(!(Test-Path -LiteralPath $regkey.Path))
    {
        Write-Debug "Doesn't exits: $($regkey.Path)"
        New-Item -Path $regkey.Path -Force > $null
    }

    New-ItemProperty -Path $regkey.Path -Name $regkey.Key -Value $regkey.Value -PropertyType $regkey.Type -Force > $null

}


function New-Policy
{
    Param(
        [Parameter(Mandatory=$True)] [ValidateNotNull()] [string]$keypath,
        [Parameter(Mandatory=$True)] [ValidateNotNull()] [string]$keyname,
        [Parameter(Mandatory=$True)] [ValidateNotNull()] $keyvalue,
        [string]$keytype = "DWORD"
        )

    New-Object psobject -property @{
        Path = $keypath
        Key = $keyname
        Value = $keyvalue
        Type = $keytype
    }

}


function Install-StartMenu
{
    Start-BitsTransfer -Source "http://downloads.sourceforge.net/project/classicshell/Version%203.6.6%20general%20release/ClassicShellSetup_3_6_6.exe" -Destination "$env:SystemDrive\Users\$env:USERNAME\Downloads\install.exe"
    Start-Process -FilePath "$env:SystemDrive\Users\$env:USERNAME\Downloads\install.exe" "/qn"
}

function Remove-Metro-Apps
{
    $AppsList = "Microsoft.BingFinance", "Microsoft.BingFoodAndDrink", "Microsoft.BingHealthAndFitness", `
                "Microsoft.BingMaps", "Microsoft.BingNews", "Microsoft.BingSports", "Microsoft.BingTravel", `
                "Microsoft.HelpAndTips", "Microsoft.WindowsAlarms","Microsoft.Reader",`
                "Microsoft.WindowsScan","Microsoft.WindowsSoundRecorder","Microsoft.SkypeApp"

    ForEach ($App in $AppsList)
    {
        $Packages = Get-AppxPackage | Where-Object {$_.Name -eq $App}
        if ($Packages -ne $null)
        {
          foreach ($Package in $Packages)
          {
             Remove-AppxPackage -package $Package.PackageFullName
          }
        }

       $ProvisionedPackage = Get-AppxProvisionedPackage -online | Where-Object {$_.displayName -eq $App}
        if ($ProvisionedPackage -ne $null)
        {
            Remove-AppxProvisionedPackage -online -packagename $ProvisionedPackage.PackageName
        }
    }
}


#1.- Disable the hot corners
$disable_corners    = New-Policy "HKCU:\Software\Microsoft\Windows\CurrentVersion\ImmersiveShell\EdgeUI" `
                                 "DisableCharmsHint" `
                                 1

#2.- Disable forced reboots for Windows Updates
$disable_reboots    = New-Policy "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" `
                                 "NoAutoRebootWithLoggedOnUsers" `
                                 1

#3.- Disable Microsoft Account Linking
$disable_linking    = New-Policy "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" `
                                 "NoConnectedUser" `
                                 3

#4.- Disable LockScreen
$disable_lockscreen = New-Policy "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization" `
                                 "NoLockScreen" `
                                 1

#5.- Disable Metro tutorial
$disable_tutorial   = New-Policy "HKCU:\Software\Policies\Microsoft\Windows\EdgeUI" `
                                 "DisableHelpSticker" `
                                 1

#6.- Disable Windows Store
$disable_wstore     = New-Policy "HKLM:\Software\Policies\Microsoft\WindowsStore" `
                                 "RemoveWindowsStore" `
                                 1
#7.- Disable SkyDrive
$disable_skydrive   = New-Policy "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Skydrive" `
                                 "DisableFileSync" `
                                  1

#8.-  Disable booting directly into metro (boots into Windows 8.1 Desktop)
$disable_metro_boot = New-Policy "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\StartPage" `
                                 "OpenAtLogon" `
                                 0

#9.- Disable Charms bar
$disable_charmsbar1 = New-Policy "HKCU:\Software\Microsoft\Windows\CurrentVersion\ImmersiveShell\EdgeUI" "DisableCharmsHint" 1
$disable_charmsbar2 = New-Policy "HKCU:\Software\Microsoft\Windows\CurrentVersion\ImmersiveShell\EdgeUI" "DisableTRcorner"   1
$disable_charmsbar3 = New-Policy "HKCU:\Software\Microsoft\Windows\CurrentVersion\ImmersiveShell\EdgeUI" "DisableTLcorner"   1


#10.- Set "All-Apps" as default view for the start metro screen
$set_allapps_metro  = New-Policy "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\StartPage" `
                                 "MakeAllAppsDefault" `
                                 1

Write-Host "[+] Making some registry changes"

#Here you can add/remove policies. This is the list that will be installed
$policies = $disable_corners, $disable_reboots, $disable_linking, $disable_lockscreen, $disable_tutorial, $disable_wstore, $disable_skydrive, `
            $disable_metro_boot, $disable_charmsbar1, $disable_charmsbar2, $disable_charmsbar3, $set_allapps_metro

foreach($policy in $policies)
{
    Set-RegKey $policy
}

Write-Host "[+] Removing Metro Apps"
Remove-Metro-Apps

Write-Host "[+] Installing Classic Shell"
Install-StartMenu
