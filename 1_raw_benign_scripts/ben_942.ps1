# script to create data.json
# THIS IS TEMPORARY, UI NEEDS TO BE MADE THAT GENERATES DATA!

#region CLASSES

class File {
    [string]$Type
    [string]$InstallationCategory = "basic"
    
    File() {
        $this.Type = $this        
    }
}

class WebFile : File {
    [string]$Url
    [string]$OutFile
        
    [void] GetFile() {
        Invoke-WebRequest -UserAgent "Wget" -Uri $this.Url -OutFile $this.OutFile
    }

    static [string] GetUrlForGithubAsset($repository, $assetNamePattern) {
        $releasesUri = "https://api.github.com/repos/$repository/releases/latest"
        $asset = (Invoke-WebRequest $releasesUri | ConvertFrom-Json).assets | Where-Object name -like $assetNamePattern
        return $asset.browser_download_url
    }
}
          
class WingetFile : File {
    [string]$Id
    [bool]$InteractiveMode = $false
                 
    [void] Install() {
        if ($this.InteractiveMode -eq $true) {
            winget install -e --id $this.Id -i
        }
        else {
            winget install -e --id $this.Id            
        }
    }
}

#endregion CLASSES

# create array
$files = [System.Collections.ArrayList]@()

#region APPS

# Powershell
$powershell = [WingetFile]::new()
$powershell.Id = "Microsoft.PowerShell"
[void]$files.Add($powershell)

# Windows Terminal
$terminal = [WingetFile]::new()
$terminal.Id = "Microsoft.WindowsTerminal"
[void]$files.Add($terminal)

#region MAIN APPS

# Google Chrome
$chrome = [WingetFile]::new()
$chrome.Id = "Google.Chrome"
[void]$files.Add($chrome)

# Spotify
$spotify = [WingetFile]::new()
$spotify.Id = "Spotify.Spotify"
[void]$files.Add($spotify)
    
# Discord
$discord = [WingetFile]::new()
$discord.InstallationCategory = "full"
$discord.Id = "Discord.Discord"
[void]$files.Add($discord)
    
# Drive File Stream
$drive = [WingetFile]::new()
$drive.InstallationCategory = "full"
$drive.Id = "Google.Drive"
[void]$files.Add($drive)
    
# Rambox
$rambox = [WebFile]::new()
$rambox.InstallationCategory = "full"
$rambox.Url = "https://rambox.app/api/download?os=windows"
$rambox.OutFile = "Install-Rambox.exe"
[void]$files.Add($rambox)
    
#endregion MAIN APPS

#region UTILITIES

# Java
$java = [WingetFile]::new()
$java.Id = "Microsoft.OpenJDK.17"
[void]$files.Add($java)

# 7Zip
$7zip = [WingetFile]::new()
$7zip.Id = "7zip.7zip"
[void]$files.Add($7zip)

# VLC Media Player
$vlc = [WingetFile]::new()
$vlc.InstallationCategory = "full"
$vlc.Id = "VideoLAN.VLC"
[void]$files.Add($vlc)

# Adobe Acrobat Reader DC
$pdfReader = [WingetFile]::new()
$pdfReader.InstallationCategory = "full"
$pdfReader.Id = "Adobe.AdobeAcrobatReaderDC"
[void]$files.Add($pdfReader)

# powertoys
$powertoys = [WingetFile]::new()
$powertoys.InstallationCategory = "full"
$powertoys.Id = "Microsoft.PowerToys"
[void]$files.Add($powertoys)

#Geek Uninstaller
$geek = [WebFile]::new()
$geek.InstallationCategory = "full"
$geek.Url = "https://geekuninstaller.com/geek.zip"
$geek.OutFile = "geekUnistaller.zip"
[void]$files.Add($geek)

#endregion UTILITIES
    
#region EDITING
    
# paint.net
$paintnet = [WebFile]::new()
$paintnet.Url = "https://www.dotpdn.com/files/paint.net.4.3.7.install.anycpu.web.zip"
$paintnet.OutFile = "paintNET.zip"
[void]$files.Add($paintnet)

# inkscape
$inkscape = [WingetFile]::new()
$inkscape.InstallationCategory = "full"
$inkscape.Id = "Inkscape.Inkscape"
[void]$files.Add($inkscape)        
    
# gimp
$gimp = [WingetFile]::new()
$gimp.InstallationCategory = "full" 
$gimp.Id = "GIMP.GIMP" 
[void]$files.Add($gimp)
        
# audacity
$audacity = [WingetFile]::new()
$audacity.InstallationCategory = "full"
$audacity.Id = "Audacity.Audacity"
[void]$files.Add($audacity)
        
#endregion EDITING

#region CUSTOMIZATION

# Logitech G Hub
$lghub = [WebFile]::new()
$lghub.InstallationCategory = "full"
$lghub.Url = "https://download01.logi.com/web/ftp/pub/techsupport/gaming/lghub_installer.exe"
$lghub.OutFile = "Install-LogitechGhub.exe"
[void]$files.Add($lghub)
    
# Corsair iCUE
$icue = [WingetFile]::new()
$icue.InstallationCategory = "full"
$icue.Id = "Corsair.iCUE.4"
[void]$files.Add($icue)

# Rainmeter
$rainmeter = [WingetFile]::new()
$rainmeter.InstallationCategory = "full"
$rainmeter.Id = "Rainmeter.Rainmeter"
[void]$files.Add($rainmeter)

# Spicetify
# Invoke-WebRequest "https://raw.githubusercontent.com/khanhas/spicetify-cli/master/install.ps1" | Invoke-Expression

#endregion CUSTOMIZATION

#region AUDIO

# EarTrumpet
$eartrumpet = [WingetFile]::new()
$eartrumpet.InstallationCategory = "full"
$eartrumpet.Id = "File-New-Project.EarTrumpet"
[void]$files.Add($eartrumpet)

# BEACN App (Only usable with BEACN Products)
$beacnapp = [WebFile]::new()
$beacnapp.InstallationCategory = "full"
$beacnapp.Url = "https://beacn-app-public-download.s3.us-west-1.amazonaws.com/BEACN+Setup+V1.0.134.0.exe"
$beacnapp.OutFile = "Install-BeacnApp.exe"
[void]$files.Add($beacnapp)

# Equalizer APO
$eqApo = [WebFile]::new()
$eqApo.InstallationCategory = "full"
$eqApo.Url = "https://sourceforge.net/projects/equalizerapo/files/latest/Download"
$eqApo.OutFile = "Install-EqualizerAPO.exe"
[void]$files.Add($eqApo)

#region VST Plugins

# Noise Suppresion VST
$rnnoise = [WebFile]::new()
$rnnoise.InstallationCategory = "full"
$rnnoise.Url = [WebFile]::GetUrlForGithubAsset("werman/noise-suppression-for-voice", "windows_rnnoise_bin_x64*.zip")
$rnnoise.OutFile = "rnnoise-latest.zip"
[void]$files.Add($rnnoise)

#endregion VST Plugins

#endregion AUDIO

#region DEVELOPMENT

# Git
$git = [WingetFile]::new()
$git.Id = "Git.Git"
$git.InteractiveMode = $true
[void]$files.Add($git)

# Github CLI
$gh = [WingetFile]::new()
$gh.Id = "GitHub.cli"
[void]$files.Add($gh)

# Visual Studio Code
$vscode = [WingetFile]::new()
$vscode.Id = "Microsoft.VisualStudioCode"
$vscode.InteractiveMode = $true
[void]$files.Add($vscode)

# KeepassXC
$keepass = [WingetFile]::new()
$keepass.Id = "KeePassXCTeam.KeePassXC"
[void]$files.Add($keepass)

# DevToys
$devtoys = [WingetFile]::new()
$devtoys.InstallationCategory = "full"
$devtoys.Id = "9PGCV4V3BK4W"
[void]$files.Add($devtoys)

#endregion DEVELOPMENT

#region FONTS
 
# FiraCode Nerd Font (font for editors)
$firacode = [WebFile]::new()
$firacode.Url = [WebFile]::GetUrlForGithubAsset("ryanoasis/nerd-fonts", "FiraCode.zip")
$firacode.OutFile = "FiraCodeNerd-latest.zip"
[void]$files.Add($firacode)

# CodeNewRoman Nerd Font (for terminals)
$codeNR = [WebFile]::new()
$codeNR.Url = [WebFile]::GetUrlForGithubAsset("ryanoasis/nerd-fonts", "CodeNewRoman.zip")
$codeNR.OutFile = "CodeNewRomanNerd-latest.zip"
[void]$files.Add($codeNR)

#endregion FONTS

#region GAMING

# Steam
$steam = [WingetFile]::new()
$steam.InstallationCategory = "full"
$steam.Id = "Valve.Steam"
[void]$files.Add($steam)

# MultiMC (Minecraft Instance Manager)
$multimc = [WebFile]::new()
$multimc.InstallationCategory = "full"
$multimc.Url = "https://files.multimc.org/downloads/mmc-stable-win32.zip"
$multimc.OutFile = "multiMC-latest-stable.zip"
[void]$files.Add($multimc)

#endregion GAMING

#region STREAMING

# OBS Studio
$obs = [WingetFile]::new()
$obs.InstallationCategory = "full"
$obs.Id = "OBSProject.OBSStudio"
[void]$files.Add($obs)

# Stream Deck
$streamdeck = [WingetFile]::new()
$streamdeck.InstallationCategory = "full"
$streamdeck.Id = "Elgato.StreamDeck"
[void]$files.Add($streamdeck)

#endregion STREAMING

#endregion APPS

# output array as json file
$files | ConvertTo-Json 