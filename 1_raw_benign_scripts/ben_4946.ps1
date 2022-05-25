# Some scripts and commands were extracted from the following links:
# - https://dev.to/smashse/wsl-chocolatey-powershell-winget-1d6p
# - https://stackoverflow.com/questions/4753051/how-do-i-check-if-a-particular-msi-is-installed

# Check to see if we are currently running "as Administrator"
if (!(Verify-Elevated)) {
    $newProcess = new-object System.Diagnostics.ProcessStartInfo "PowerShell";
    $newProcess.Arguments = $myInvocation.MyCommand.Definition;
    $newProcess.Verb = "runas";
    [System.Diagnostics.Process]::Start($newProcess);

    exit
}

# Create temp directory for downloaded stuff
$tempdir = ".\temp"
## Remove-Item -LiteralPath $tempdir -Recurse -Force
Get-ChildItem -Path $tempdir -Recurse | Remove-Item -Recurse -Force
If(!(test-path $tempdir))
{
    New-Item -ItemType Directory -Path $tempdir -Force | Out-Null
}

Write-Host "# core tools" -ForegroundColor "Yellow"

# PowerShell Core (https://github.com/PowerShell/PowerShell)
if(-not (Get-Uninstalls | Where-Object { $_.PSChildName -eq "{11E117C7-01D0-4C4E-9096-2E90843A173E}" })) {
    Write-Host "Installing `"Powershell Core`"..." -ForegroundColor "Yellow"
    Exit
    &Invoke-WebRequest `
        -Uri "https://github.com/PowerShell/PowerShell/releases/download/v7.2.1/PowerShell-7.2.1-win-x64.msi" `
        -OutFile "$tempdir\PowerShellCore.msi" `
        -UseBasicParsing
    # Run `msiexec /?` to see options that msiexec accepts.
    # Run `msiexec /log logfile.txt /package PowerShellCore.msi` and see logfile.txt for configurable "property" values in this msi package.
    &msiexec `
        /package "$tempdir\PowerShellCore.msi" `
        /quiet `
        ADD_PATH=1 `
        REGISTER_MANIFEST=1 `
        ADD_EXPLORER_CONTEXT_MENU_OPENPOWERSHELL=1 `
        ADD_FILE_CONTEXT_MENU_RUNPOWERSHELL=1
}
else {
    Write-Host "`"Powershell Core`" found." -ForegroundColor "Yellow"
}

# Chocolatey (https://chocolatey.org/)
choco -v | Out-Null
if(-not $?) {
    Write-Host "Installing `"Chocolatey`"..." -ForegroundColor "Yellow"
    Write-Host ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
    &Set-ExecutionPolicy Bypass -Scope Process -Force; `
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; `
        iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
    Write-Host "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
    Refresh-Environment
}
else {
    Write-Host "`"Chocolatey`" found." -ForegroundColor "Yellow"
}

# Windows Package Manager Client (aka winget.exe) (https://github.com/microsoft/winget-cli)
if(-not (Get-AppxPackage -Name "Microsoft.DesktopAppInstaller")) {
    Write-Host "Installing `"winget`"..." -ForegroundColor "Yellow"
    ## * To install the latest stable release,
    ## go to https://github.com/microsoft/winget-cli/releases
    ## and search for the relase with the "Latest"
    ## * The -UseBasicParsing parameter is included for backwards compatibility only
    ## and any use of it has no effect on the operation of the cmdlet
    &Invoke-WebRequest `
        -Uri "https://github.com/microsoft/winget-cli/releases/download/v1.1.12653/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle" `
        -OutFile "$tempdir\winget-cli.msixbundle" `
        -UseBasicParsing
    Add-AppxPackage -Path "$tempdir\winget-cli.msixbundle"
}
else {
    Write-Host "`"winget`" found." -ForegroundColor "Yellow"
}

Write-Host "# winget packages" -ForegroundColor "Yellow"
$wingetPackages = @(
    ## Miscellaneous tools
    ## -----------------------
    # Greenshot (https://getgreenshot.org/)
    [pscustomobject]@{ Name="Greenshot"; Id="Greenshot.Greenshot" }
    # 7-Zip (https://www.7-zip.org/)
    [pscustomobject]@{ Name="7zip"; Id="7zip.7zip" }
    # GIMP (https://www.gimp.org/)
    [pscustomobject]@{ Name="GIMP"; Id="GIMP.GIMP" }
    # Google Chrome (https://www.google.com/chrome/)
    [pscustomobject]@{ Name="Chrome"; Id="Google.Chrome" }
    # VLC Media Player (https://www.videolan.org/)
    [pscustomobject]@{ Name="VLC"; Id="VideoLAN.VLC" }
    # Mixxx (https://www.mixxx.org/)
    # [pscustomobject]@{ Name="MiXXX"; Id="MiXXX.MiXXX" }
    # qBittorrent (https://www.qbittorrent.org/)
    [pscustomobject]@{ Name="qBittorrent"; Id="qBittorrent.qBittorrent" }

    ## CLI tools
    ## -----------------------
    # Windows Terminal (https://github.com/Microsoft/Terminal)
    [pscustomobject]@{ Name="Windows Terminal"; Id="Microsoft.WindowsTerminal" }

    ## Dev tools
    ## -----------------------
    # WinMerge (https://winmerge.org/)
    [pscustomobject]@{ Name="WinMerge (an Open Source differencing and merging tool for Windows)"; Id="WinMerge.WinMerge" }
    # Microsoft Visual Studio Code (https://code.visualstudio.com/)
    [pscustomobject]@{ Name="vscode"; Id="Microsoft.VisualStudioCode" }
    # Git (https://gitforwindows.org/)
    [pscustomobject]@{ Name="Git"; Id="Git.Git" }
    # Postman (https://www.postman.com/)
    [pscustomobject]@{ Name="Postman"; Id="Postman.Postman" }
    # Python (https://www.python.org/)
    [pscustomobject]@{ Name="Python 3"; Id="Python.Python.3" }
    # .NET SDK (https://dot.net/, https://docs.microsoft.com/en-us/dotnet/, https://docs.microsoft.com/en-us/dotnet/core/sdk, https://docs.microsoft.com/en-us/dotnet/core/tools/dotnet-install-script)
    [pscustomobject]@{ Name=".NET SDK"; Id="Microsoft.dotnet" }
)
if (which winget) {
    Foreach ($p in $wingetPackages)
    {
        winget list --exact --id $p.Id | Out-Null
        if(-not $?) {
            Write-Host "Installing `"$($p.Name)`"..." -ForegroundColor "Yellow"
            winget install --exact --id $p.Id
        }
        else {
            Write-Host "`"$($p.Name)`" found." -ForegroundColor "Yellow"
        }
    }
}
Remove-Variable wingetPackages

Write-Host "# chocolatey packages" -ForegroundColor "Yellow"
$chocoPackages = @(
    ## System tools
    ## -----------------------
    # sysinternals (https://technet.microsoft.com/en-us/sysinternals/bb842062)
    [pscustomobject]@{ Name="sysinternals"; Id="sysinternals" }
    # ffmpeg (https://www.ffmpeg.org/)
    [pscustomobject]@{ Name="ffmpeg"; Id="ffmpeg" }
    # winfetch (https://github.com/kiedtl/winfetch)
    [pscustomobject]@{ Name="winfetch"; Id="winfetch" }

    ## CLI tools
    ## -----------------------
    # vim (https://www.vim.org/)
    [pscustomobject]@{ Name="vim"; Id="vim" }
    # ripgrep (https://github.com/BurntSushi/ripgrep)
    [pscustomobject]@{ Name="ripgrep (rg, A search tool that combines the usability of ag with the raw speed of grep)"; Id="ripgrep" }
    # curl (https://curl.se/)
    [pscustomobject]@{ Name="curl"; Id="curl" }
    # less (http://www.greenwoodsoftware.com/less/)
    [pscustomobject]@{ Name="less"; Id="less" }
    # jq (https://stedolan.github.io/jq/)
    [pscustomobject]@{ Name="jq (Command-line JSON processor)"; Id="jq" }
    # yq (https://mikefarah.gitbook.io/yq/)
    [pscustomobject]@{ Name="yq (Command-line YAML processor)"; Id="yq" }
    # bat (https://github.com/sharkdp/bat)
    [pscustomobject]@{ Name="bat (A cat clone)"; Id="bat" }
    # nvm (https://github.com/coreybutler/nvm-windows)
    [pscustomobject]@{ Name="NVM for Windows"; Id="nvm" }
    # delta (https://github.com/dandavison/delta)
    [pscustomobject]@{ Name="delta (A syntax-highlighter for git and diff output)"; Id="delta" }
    # glow (https://github.com/charmbracelet/glow)
    [pscustomobject]@{ Name="glow (a terminal based markdown reader)"; Id="glow" }
    # fzf (https://github.com/junegunn/fzf)
    [pscustomobject]@{ Name="fzf (a fuzzy finder)"; Id="fzf" }

    ## Nerd Fonts
    ## -----------------------
    ## More fonts with glyphs: https://github.com/ryanoasis/nerd-fonts#patched-fonts
    # Caskaydia Cove Nerd Font (aka. CascadiaCode Nerd Font) (https://github.com/ryanoasis/nerd-fonts/tree/master/patched-fonts/CascadiaCode)
    # Installation: https://github.com/ryanoasis/nerd-fonts#option-1-download-and-install-manually
    [pscustomobject]@{ Name="Caskaydia Cove Nerd Font"; Id="cascadia-code-nerd-font" }

    ## Other Fonts
    ## -----------------------
    # Fira Code (https://github.com/tonsky/FiraCode)
    # Unfortunately there is not a package with the patched version from Nerd Fonts: https://github.com/ryanoasis/nerd-fonts/tree/master/patched-fonts/FiraCode
    # Installation for vscode: https://github.com/tonsky/FiraCode/wiki/VS-Code-Instructions
    [pscustomobject]@{ Name="Fira Code (a monospaced font with programming ligatures)"; Id="firacode" }
    # Source Code Pro (https://github.com/adobe-fonts/source-code-pro)
    [pscustomobject]@{ Name="Source Code Pro (a set of OpenType fonts designed for better reading in GUIs)"; Id="sourcecodepro" }

    ## Misc
    ## -----------------------
    # Telegram (https://desktop.telegram.org/)
    # Cloud-based synchronized messaging app with a focus on speed and security
    [pscustomobject]@{ Name="Telegram"; Id="telegram" }
    # HxD (https://mh-nexus.de/en/hxd/)
    # A hex editor
    [pscustomobject]@{ Name="HxD"; Id="hxd" }
)
if (which choco) {
    Foreach ($p in $chocoPackages)
    {
        $result = choco list --limit-output --local-only --exact --by-id-only $p.Id | Where-object { $_.ToLower().StartsWith($p.Id.ToLower()) }
        if($result -eq $null) {
            Write-Host "Installing `"$($p.Name)`"..." -ForegroundColor "Yellow"
            choco install -y --limit-output $p.Id
        }
        else {
            Write-Host "`"$($p.Name)`" found." -ForegroundColor "Yellow"
        }
    }
}
Remove-Variable chocoPackages

Refresh-Environment

# Invoke-Expression -Command ""

# vscode setup
if (which code) {
    Write-Host "# vscode extensions" -ForegroundColor "Yellow"
    $vscodePackages = @(
        ## Miscellaneous
        ## -----------------------
        # Trailing Spaces (https://github.com/shardulm94/vscode-trailingspaces)
        [pscustomobject]@{ Name="sysinternals"; Id="shardulm94.trailing-spaces" }
        # Diff Tool (https://github.com/jinsihou19/vscode-diff-tool)
        [pscustomobject]@{ Name="Diff Tool"; Id="jinsihou.diff-tool" }
    )
    Foreach ($p in $vscodePackages)
    {
        Write-Host "Installing `"$($p.Name)`"..." -ForegroundColor "Yellow"
        code --install-extension $p.Id
    }
    Remove-Variable vscodePackages
}


# NodeJS setup
if ((which nvm) -and (which choco)) {
    Write-Host "# nvm components" -ForegroundColor "Yellow"
    ## Install latest nodeJS version
    nvm on
    $nodeLtsVersion = choco search nodejs-lts --limit-output | ConvertFrom-String -TemplateContent "{Name:package-name}\|{Version:1.11.1}" | Select -ExpandProperty "Version"
    nvm install $nodeLtsVersion
    nvm use $nodeLtsVersion
    Remove-Variable nodeLtsVersion
    Write-Host "Installing Node Packages..." -ForegroundColor "Yellow"
    if (which npm) {
        npm update npm
        npm install -g yarn
        # npm install -g gulp
        # npm install -g mocha
        # npm install -g node-inspector
        # npm install -g yo
    }
}

# Ruby Setup
# if (which gem) {
#     gem pristine --all --env-shebang
# }

# VIM setup
if (which vim) {
    Write-Host "# Vim components" -ForegroundColor "Yellow"
    &Invoke-WebRequest `
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim `
        -UseBasicParsing |`
        New-Item $home/vimfiles/autoload/plug.vim -Force
    Write-Host "Installing Vim plugins..." -ForegroundColor "Yellow"
    vim -c 'PlugInstall --sync' -c 'qa'
    # Janus for vim
    # Write-Host "Installing Janus..." -ForegroundColor "Yellow"
    # if ((which curl) -and (which vim) -and (which rake) -and (which bash)) {
    #     curl.exe -L https://bit.ly/janus-bootstrap | bash
    # }
}

Remove-Variable tempdir
