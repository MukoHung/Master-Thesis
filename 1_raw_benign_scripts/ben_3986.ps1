# Powershell Script Sync iPhone v0.0.2
#
# Copy Files (Images/Videos) to PC
# Copy Files Created After `date`
# Rename Files to "yyyyMMdd_HHmmss.ext" (android style)
#
# Usage:
# .\sync-iphone.ps1
# .\sync-iphone.ps1 -After 2021-07-01
# .\sync-iphone.ps1 -After last
#
# IMPORTANT!
# iPhone Settings -> Photos -> Keep Originals
#
# secator.com, 2021
#

param([string]$After = "")

$Destination = $((Get-Location).Path + "\")
$Filter = ".jpg", ".png", ".mov"

$Shell = New-Object -ComObject Shell.Application

function GetFiles($Path) {

    $Objects = $Shell.NameSpace($Path).self.GetFolder()

    foreach($Object in $Objects.Items()) {

        if ($Object.IsFolder) {
            GetFiles($Object)
        } else {
                    
            if ($Object.Name -match "^img_" -and $Filter -match $Object.ExtendedProperty("System.FileExtension") -and $Object.ExtendedProperty("System.DateCreated").ToString("yyyy-MM-dd") -ge $After) {

                $Group = $Object.ExtendedProperty("System.DateCreated").ToString("yyyyMM")
                $Group = $($Destination + "\" + $Group + "\")

                if (-Not (Test-Path -Path $Group)) {
                    New-Item -ItemType "directory" -Path $Group
                }

                $NewName = $Object.ExtendedProperty("System.DateCreated").ToString("yyyyMMdd_HHmmss") + $Object.ExtendedProperty("System.FileExtension")

                if (Test-Path -Path $($Group + $NewName)) {
                    if ($Object.ExtendedProperty("System.Size") -eq (Get-Item $($Group + $NewName)).Length) {
                        continue
                    }

                    $NewName = $Object.ExtendedProperty("System.DateCreated").ToString("yyyyMMdd_HHmmss") + "-" + $Object.ExtendedProperty("System.Size") + $Object.ExtendedProperty("System.FileExtension")
                    if (Test-Path -Path $($Group + $NewName)) {
                        continue
                    }
                }
                
                Write-Output $($Object.ExtendedProperty("System.FileName") + " (" + $Object.ExtendedProperty("System.Size") + ") -> " + $NewName)

                $Shell.NameSpace($Group).self.GetFolder.CopyHere($Object)

                if (Test-Path $($Group + $Object.ExtendedProperty("System.FileName"))) {
                    Rename-Item -Path $($Group + $Object.ExtendedProperty("System.FileName")) -NewName $NewName
                } else {
                    Write-Output $("Error copy: " + $($Group + $Object.ExtendedProperty("System.FileName")))
                }
            }
        }
    }
}

$Phones = $shell.NameSpace(0x11).self.GetFolder.items() | where { $_.Type -match "^portable" -and $_.Name -match "iphone" }

if (-Not $Phones) {
    Write-Output "No Iphone"
    exit
}

foreach ($Phone in $Phones) {

    $Destination += $Phone.Name

    if (-Not (Test-Path -Path $Destination)) {
        New-Item -ItemType "directory" -Path $Destination
    } elseif ($After -eq "") {

    } elseif (-Not ($After -match "^\d{4}-\d{2}-\d{2}$")) {
        $After = (Get-Item $Destination).LastWriteTime.ToString("yyyy-MM-dd")
    }

    (Get-Item $Destination).LastWriteTime = Get-Date
    GetFiles($Phone.Path)
}