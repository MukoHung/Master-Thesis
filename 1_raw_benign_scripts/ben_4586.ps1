#
# Run this script as administrator!

# How to setup Windows DevEnvironment:
# 1.  install MSYS2:     https://www.msys2.org/
#     add `<path-to-msys64>\mingw64\bin` and ` <msys64>\usr\bin` to environment path
# 2.  install Windows-Terminal
# 3.  run this script as Admin
# 4.  set FZF_DEFAULT_COMMAND and FZF_DEFAULT_OPTS
#

Write-Output "Running init..."

# function to check if a tool is already installed
Function IsInstalled([string] $appname) {
    Get-Command $appname -ErrorAction SilentlyContinue | Select-Object Definition
    $?
}

Function MakeSymbolicLink([string] $target, [string] $source) {
    Remove-Item -Recurse "$target" -ErrorAction SilentlyContinue
    if (Test-Path -Path $source -PathType Container) {
        Write-Output "make junction $target to $source"
        # iex "cmd /c mklink /J $target $source"
        New-Item -Path "$target" -ItemType Junction -Value "$source"
    } else {
        Write-Output "linking file $target to $source"
        New-Item -Path "$target" -ItemType SymbolicLink -Value "$source"
    }
}

Function ConfigPowershell {
    Write-Output "******** ConfigPowershell ********"
    $profileDir = Split-Path -parent $profile
    New-Item $profileDir -ItemType Directory -Force -ErrorAction SilentlyContinue # create $profileDir folder

    # link all .ps1 files
    Get-ChildItem powershell *.ps1 | foreach-object { MakeSymbolicLink "$profileDir\$($_.Name)" $_.fullname }

    # install powershell modules
    if (-not (Get-Module -Name "Terminal-Icons")) {
        Install-Module -Name Terminal-Icons -Repository PSGallery
    }
    
    # starship
	$location = get-location
    $currentDir = $location.Path
	scoop install starship
    MakeSymbolicLink "$HOME\.config\starship.toml" "$currentDir/../shared/.config/starship.toml"

    scoop install zoxide
}

Function InstallPackageManager {
    Write-Output "******** InstallPackageManager ********"
    # install chocolatey
    if (-not (IsInstalled choco))
    {
        Invoke-WebRequest -useb https://chocolatey.org/install.ps1 | Invoke-Expression
    }

    # install scoop and its extra buckets
    if (-not (IsInstalled scoop))
    {
        Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
        Invoke-WebRequest -useb get.scoop.sh | Invoke-Expression

        # add additional buckets
        scoop bucket add extras
        scoop bucket add versions
        scoop bucket add nerd-fonts
    }

    # install required tools
    scoop install git aria2 fd fzf python ripgrep
}

Function ConfigMiscTools {
    Write-Output "******** ConfigMiscTools ********"
    $location = get-location
    $currentDir = $location.Path
    $dotfilesDir = Split-Path -parent $currentDir

    # apps nvim needs
    scoop install neovim
    MakeSymbolicLink "$env:LOCALAPPDATA\nvim" "$dotfilesDir\shared\nvim"  # vim configuration
    python -m pip install --user --upgrade pynvim  # let python be aware of pynvim module

    # subl
    if (IsInstalled subl) {
        # sublime-text configuration
        $st_packages = "$env:userprofile\scoop\persist\sublime-text\Data\Packages"
        Remove-Item -recurse "$st_packages\User"
        # iex "cmd /c mklink /D $st_packages\User $currentDir\Sublime\User"
        MakeSymbolicLink "$st_packages\User" "$currentDir\Sublime\User"
        MakeSymbolicLink "$st_packages\myplugin" "$currentDir\Sublime\myplugin"
    }

    # code
    if (IsInstalled code) {
        ### vscode configuration
        MakeSymbolicLink "$env:appdata\Code\User\settings.json" "$currentDir\vscode\settings.json"
    }

    # wt
    if (IsInstalled wt) {
        $WTSettings_target = "$HOME\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState"
        MakeSymbolicLink "$WTSettings_target" "$currentDir\WindowsTerminalSettings"
    }
}

Function InstallOptionalTools {
    # install core scoop apps
    $apps = Get-Content scoop-key-apps.txt
    scoop install @apps
    # install tree-sitter
    cargo install tree-sitter-cli
    pip3 install tree_sitter
    # install exa
    cargo install --git https://github.com/zkat/exa

}

################################################################################
# install

Push-Location
    InstallPackageManager
    ConfigPowershell
    ConfigMiscTools
    InstallOptionalTools

    Write-Output "******** upgrade pip ********"
    # upgrade pip
    python -m pip install --upgrade pip
Pop-Location


Write-Output "done!"
