param([parameter(mandatory=$false)] [string]$install_root = $null)

$setups = @(
    ### Basics ###
    @{name = "Install-Scoop"; requires = @(); bundles = @("All", "Basics"); command = "scoop"},
    @{name = "Install-Chocolatey"; requires = @(); bundles = @("Basics", "All"); command = "choco"}

    ### Buckets ###
    @{name = "Install-Bucket-Versions"; requires = @("Install-Scoop", "Install-Git"); bundles = @("Buckets", "All")},
    @{name = "Install-Bucket-Extras"; requires = @("Install-Scoop", "Install-Git"); bundles = @("Buckets", "All")},
    @{name = "Install-Bucket-Nerd_Fonts"; requires = @("Install-Scoop", "Install-Git"); bundles = @("Buckets", "All")},

    ### Programming ###
    @{name = "Install-Git"; requires = @("Install-Scoop"); bundles = @("Programming", "All"); command = "git"},
    @{name = "Install-Python-Latest"; requires = @("Install-Scoop"); bundles = @("Basics","Programming", "All"); command = "python"},
    @{name = "Install-Python-37"; requires = @("Install-Scoop", "Install-Bucket-Versions"); bundles = @("Programming", "All"); command = "python37"},
    @{name = "Install-Python-27"; requires = @("Install-Scoop", "Install-Bucket-Versions"); bundles = @("Programming", "All"); command = "python27"},
    @{name = "Install-Nodejs"; requires = @("Install-Scoop"); bundles = @("Programming", "All"); command = "node"},
    @{name = "Install-Go"; requires = @("Install-Scoop"); bundles = @("Programming", "All"); command = "go"},
    @{name = "Install-Rez"; requires = @("Install-Python-Latest"); bundles = @("Programming", "All"); command = "rez"},
    @{name = "Install-Cmake"; requires = @("Install-Scoop"); bundles = @("Programming", "All"); command = "cmake"},
    @{name = "Install-Ninja"; requires = @("Install-Scoop"); bundles = @("Programming", "All"); command = "ninja"},
    @{name = "Install-Emscripten"; requires = @("Install-Scoop"); bundles = @("Programming", "All"); command = "emcc"},
    @{name = "Install-Oh_My_Posh"; requires = @("Install-Scoop"); bundles = @("Programming", "All"); command = "set-poshprompt"},
    @{name = "Install-Vim"; requires = @("Install-Scoop"); bundles = @("Programming", "All"); command = "vim"},
    @{name = "Install-Vim-Config"; requires = @("Install-Vim", "Install-FZF", "Install-Python", "Install-Ripgrep", "Install-Git", "Install-Nodejs"); bundles = @("Programming", "All")},

    ### Utility ###
    @{name = "Install-FZF"; requires = @("Install-Scoop"); bundles = @("Utility", "All"); command = "fzf"},
    @{name = "Install-Ripgrep"; requires = @("Install-Scoop"); bundles = @("Utility", "All"); command = "rg"},
    @{name = "Install-Touch"; requires = @("Install-Scoop"); bundles = @("Utility", "All"); command = "touch"},
    @{name = "Install-Bat"; requires = @("Install-Scoop"); bundles = @("Utility", "All"); command = "bat"},
    @{name = "Install-FFMPEG"; requires = @("Install-Scoop"); bundles = @("Utility", "All"); command = "ffmpeg"},
    @{name = "Install-Powertoys"; requires = @("Install-Scoop", "Install-Bucket-Extras", "All"); bundles = @("Utility")},
    @{name = "Install-7zip"; requires = @("Install-Scoop"); bundles = @("Utility", "All"); command = "7z"},

    ### Web / Database ###
    @{name = "Install-Postgresql"; requires = @("Install-Scoop"); bundles = @("Web/Database", "All"); command = "psql"},
    @{name = "Install-MongoDB"; requires = @("Install-Scoop"); bundles = @("Web/Database", "All"); command = "mongo"},
    @{name = "Install-Postman"; requires = @("Install-Chocolatey"); bundles = @("Web/Database", "All")},
    @{name = "Install-Docker"; requires = @("Install-Chocolatey"); bundles = @("Web/Database", "All"); command = "docker"},

    ### Productivity ###
    @{name = "Install-LibreOffice"; requires = @("Install-Chocolatey"); bundles = @("Productivity", "All")},
    @{name = "Install-Brave"; requires = @("Install-Chocolatey"); bundles = @("Productivity", "All")},
    @{name = "Install-Chrome"; requires = @("Install-Chocolatey"); bundles = @("Productivity", "All")},
    @{name = "Install-Firefox"; requires = @("Install-Chocolatey"); bundles = @("Productivity", "All")},
    @{name = "Install-Windows-Terminal"; requires = @("Install-Chocolatey"); bundles = @("Utility", "All")},

    ### Media ###
    @{name = "Install-VLC"; requires = @("Install-Chocolatey"); bundles = @("Media", "All")},
    @{name = "Install-OBS"; requires = @("Install-Chocolatey"); bundles = @("Media", "All")},
    @{name = "Install-DJView"; requires = @("Install-Chocolatey"); bundles = @("Media", "All")},
    
    ### DCC ###
    @{name = "Install-Blender"; requires = @("Install-Chocolatey"); bundles = @("DCC", "All")},
    @{name = "Install-Unity"; requires = @("Install-Chocolatey"); bundles = @("DCC", "All")},
    
    ### Games ###
    @{name = "Install-Steam"; requires = @("Install-Chocolatey"); bundles = @("Games", "All")},
    @{name = "Install-Epic"; requires = @("Install-Chocolatey"); bundles = @("Games", "All")},

    ### Social ###
    @{name = "Install-Discord"; requires = @("Install-Chocolatey"); bundles = @("Social", "All")},
    @{name = "Install-Ferdi"; requires = @("Install-Chocolatey"); bundles = @("Social", "All")},
    @{name = "Install-Rampbox"; requires = @("Install-Chocolatey"); bundles = @("Social", "All")},

    ### PIP ###
    @{name = "Install-Pipenv"; requires = @("Install-Python"); bundles = @("PIP", "All"); command = "pipenv"},
    @{name = "Install-Jedi"; requires = @("Install-Python"); bundles = @("PIP", "All")},
    @{name = "Install-Pylint"; requires = @("Install-Python"); bundles = @("PIP", "All"); command = "pylint"},
    @{name = "Install-Black"; requires = @("Install-Python"); bundles = @("PIP", "All"); command = "black"},
    @{name = "Install-Yapf"; requires = @("Install-Python"); bundles = @("PIP", "All"); command = "yapf"},
    @{name = "Install-Autopep8"; requires = @("Install-Python"); bundles = @("PIP", "All"); command = "autopep8"},

    ### NPM ###
    @{name = "Install-Vue"; requires = @("Install-Nodejs"); bundles = @("NPM", "All")},
    @{name = "Install-React"; requires = @("Install-Nodejs"); bundles = @("NPM", "All")},
    @{name = "Install-Surge"; requires = @("Install-Nodejs"); bundles = @("NPM", "All")},

    ### Debloat ###
    @{name = "Disable-Cortana"; requires = @(); bundles = @("Debloat", "All")},
    @{name = "Disable-ErrorReporting"; requires = @(); bundles = @("Debloat", "All")},
    @{name = "Disable-WebSearch"; requires = @(); bundles = @("Debloat", "All")},

    ### Functionalities ###
    @{name = "Install-WSL2"; requires = @("Install-Chocolatey"); bundles = @("Functionalities", "All"); command = "wsl"}
)


########## Utility ##########

function Execute-Setup {
    param(
        [parameter(mandatory=$true)] [hashtable]$setup,
        [parameter(mandatory=$true)] [hashtable[]]$options
    )

    # If the setup has no requirement just execute it
    if (-not $setup.containskey("requires")) {
        Invoke-Expression "$($setup[`"name`"])"
        return
    }
    # Execute all its requirements
    foreach($requirement in $setup["requires"]) {
        # Get the requirement info
        foreach($required_setup in $options | ? {$_["name"] -eq $requirement}) {
            if (-not $required_setup["completed"]) {
                Write-Output "Executing requirement $($required_setup["name"]) for $($setup["name"])"
                Execute-Setup -setup $required_setup -options $options
            }
        }
    }
    Invoke-Expression "$($setup[`"name`"])"
    # Set the config to done
    foreach($option in $options | ? {$_["name"] -eq $setup["name"]}) {
        $option["completed"] = $true
    }
}

function Download-GithubRelease {
    param(
        [parameter(mandatory=$true)] [string]$repo,
        [parameter(mandatory=$false)] [string]$file = ""
    )

    $releases = "https://api.github.com/repos/$repo/releases"
    # Determining the latest release
    $tag = (Invoke-WebRequest $releases -UseBasicParsing | ConvertFrom-Json)[0].tag_name

    if ($file -eq "") {
        $file = "$tag.zip"
        $download = "https://github.com/$repo/archive/refs/tags/$file"
        $name = "$($repo.split("/")[1])-$tag"
    }
    else {
        $download = "https://github.com/$repo/releases/download/$tag/$file"
        $name = $file.split(".")[0]
    }

    if ($file.split(".")[-1] -ne "zip") {
        Invoke-WebRequest $download -out $file -usebasicparsing
        return $file
    }

    $zip = "$name-$tag.zip"
    $dir = "$name-$tag"

    Invoke-WebRequest $download -out $zip -usebasicparsing
    Expand-Archive $zip -force

    # Moving from temp dir to target dir
    Move-Item $dir\$name -destination $name -force

    # Removing temp files
    Remove-Item $zip -force
    Remove-Item $dir -recurse -force

    return $name
}

function Download-GithubGist {
    param(
        [parameter(mandatory=$true)] [string]$username,
        [parameter(mandatory=$true)] [string]$filename,
        [parameter(mandatory=$true)] [string]$output_path
    )

    # Gett all the gists of the user
    $gists = Invoke-RestMethod "https://api.github.com/users/$username/gists"
    foreach ($gist in $gists) {
        if ($gist.files.psobject.properties.name.contains($filename)) {
            $file_url = $gist.files."$filename".raw_url
            $file_content = Invoke-RestMethod $file_url
            Out-File -filepath "$output_path\$filename" -inputobject $file_content -encoding "ascii"
            return "$output_path\$filename"
        }
    }

    Write-Warning "Rez config gist not found, the default config will be used"
    return ""
}


########## SETUPS ##########

function Install-Scoop {
    param([parameter(mandatory=$false)] [string]$scoop_dir = "")

    Write-Output "Installing Scoop..."
    # Get install dir if not provided
    if ($scoop_dir -eq "" -and $install_root -ne $null) {
        $scoop_dir = "$install_root/scoop"
    }
    # Prompt for install dir if not provided
    elseif ($scoop_dir -eq "") {
        $scoop_dir = read-host "Scoop install root directory : "
    }
    $env:SCOOP=$scoop_dir
    [environment]::setenvironmentvariable('SCOOP', $env:SCOOP, 'user')
    Invoke-Expression (New-Object System.Net.WebClient).DownloadString('https://get.scoop.sh')
}

function Install-Chocolatey {
    Write-Output "Installing Chocolatey..."
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
}

function Install-Bucket-Versions {
    Write-Output "Installing Scoop versions bucket..."
    scoop bucket add versions
}

function Install-Bucket-Extras {
    Write-Output "Installing Scoop extras bucket..."
    scoop bucket add extras
}

function Install-Bucket-Nerd_Fonts {
    Write-Output "Installing Scoop nerd-fonts bucket..."
    scoop bucket add nerd-fonts
}

function Install-Git {
    Write-Output "Installing Git..."
    scoop install git
}

function Install-Python-Latest {
    Write-Output "Installing Python..."
    scoop install python
}

function Install-Python-37 {
    Write-Output "Installing Python37..."
    scoop install python37
}

function Install-Python-27 {
    Write-Output "Installing Python27..."
    scoop install python27
}

function Install-Nodejs {
    Write-Output "Installing Nodejs..."
    scoop install nodejs
}

function Install-Go {
    Write-Output "Installing Go..."
    scoop install go
}

function Install-Rez {
    param([parameter(mandatory=$false)] [string]$rez_dir = "")

    Write-Output "Installing Rez..."
    # Get install dir if not provided
    if ($rez_dir -eq "" -and $install_root -ne $null) {
        $rez_dir = "$install_root/rez"
    }
    # Prompt for install dir if not provided
    elseif ($rez_dir -eq "") {
        $rez_dir = Read-Host "rez install root directory : "
    }
    $rez_source = Download-GithubRelease -repo "nerdvegas/rez"
    # Install rez
    Invoke-Expression "python $(Resolve-Path $rez_source)\install.py $rez_dir"
    $env:PATH=$env:PATH + ";$rez_dir\scripts\rez"
    [environment]::SetEnvironmentVariable('path', $env:PATH, 'user')
    Remove-Item $rez_source -recurse -force
    $env:REZ=$rez_dir
    [environment]::SetEnvironmentVariable('REZ', $env:REZ, 'user')
    $env:PYTHONPATH=$env:PYTHONPATH + ";$rez_dir\lib\site-packages"
    [environment]::SetEnvironmentVariable('PYTHONPATH', $env:PYTHONPATH, 'user')
    # Install config
    $rez_config = download-githubgist -username "acedyn" -filename "rezconfig.py" -output_path $rez_dir
    $env:REZ_CONFIG_FILE=$rez_config
    [environment]::SetEnvironmentVariable('REZ_CONFIG_FILE', $env:REZ_CONFIG_FILE, 'user')
    # Create some default packages
    rez-bind --quickstart
}

function Install-Cmake {
    Write-Output "Installing Cmake..."
    scoop install cmake
}

function Install-Ninja {
    Write-Output "Installing Ninja..."
    scoop install ninja
}

function Install-Vim {
    Write-Output "Installing Vim..."
    scoop install vim
}

function Install-Vim-Config {
    Write-Output "Installing Vim-Config..."
    # Get vim plug and install it
    $plugin_config = Download-GithubGist -username "acedyn" -filename ".vimplug" -output_path $HOME
    Invoke-WebRequest -useb "https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim" |`
    New-Item $HOME/vimfiles/autoload/plug.vim -Force
    # Call for the install of the plugins
    vim -c "silent! source ~/.vimplug" + "PlugInstall --sync" + "qa"
    Remove-Item $plugin_config
    # Get the vim config files from github
    Download-GithubGist -username "acedyn" -filename ".vimrc" -output_path $HOME
    Download-GithubGist -username "acedyn" -filename ".gvimrc" -output_path $HOME
}

function Install-Oh_My_Posh {
    Write-Output "Installing Oh_My_Posh..."
    Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
    Set-PSRepository 'PSGallery'
    Install-Module oh-my-posh -Scope CurrentUser
    Import-Module oh-my-posh
    Set-PoshPrompt -Theme iterm2

    if (-not (Test-Path $Home\Documents\WindowsPowerShell\Profile.ps1)) {
    	New-Item $Home\Documents\WindowsPowerShell\Profile.ps1
    }

    Add-Content $Home\Documents\WindowsPowerShell\Profile.ps1 "`nImport-Module oh-my-posh`nSet-PoshPrompt -Theme iterm2"
}

function Install-FZF {
    Write-Output "Installing FZF..."
    scoop install fzf
}

function Install-Ripgrep {
    Write-Output "Installing Ripgrep..."
    scoop install ripgrep
}

function Install-Touch {
    Write-Output "Installing touch..."
    scoop install touch
}

function Install-Bat {
    Write-Output "Installing bat..."
    scoop install bat
}

function Install-FFMPEG {
    Write-Output "Installing ffmpeg..."
    scoop install ffmpeg
}

function Install-Powertoys {
    Write-Output "Installing powertoys..."
    scoop install powertoys
}

function Install-7zip {
    Write-Output "Installing 7zip..."
    scoop install 7zip
}

function Install-Postgresql {
    Write-Output "Installing postgresql..."
    scoop install postgresql
}

function Install-MongoDB {
    Write-Output "Installing mongodb..."
    scoop install mongodb
}

function Install-Postman {
    Write-Output "Installing postman..."
    choco install postman
}

function Install-Docker {
    Write-Output "Installing docker..."
    choco install docker-desktop
}

function Install-LibreOffice {
    Write-Output "Installing libre office..."
    choco install libreoffice-still
}

function Install-Brave {
    Write-Output "Installing brave..."
    choco install brave
}

function Install-Chrome {
    Write-Output "Installing chrome..."
    choco install googlechrome
}

function Install-Firefox {
    Write-Output "Installing firefox..."
    choco install firefox
}

function Install-Windows-Terminal {
    Write-Output "Installing windows terminal..."
    choco install microsoft-windows-terminal
}

function Install-VLC {
    Write-Output "Installing vlc..."
    choco install vlc
}

function Install-OBS {
    Write-Output "Installing obs..."
    choco install obs
}

function Install-DJView {
    Write-Output "Installing DJView..."
    Write-Output "NOT IMPLEMENTED"
}

function Install-Discord {
    Write-Output "Installing discord..."
    choco install discord
}

function Install-Rampbox {
    Write-Output "Installing rampbox..."
    choco install rampbox
}

function Install-Ferdi {
    Write-Output "Installing ferdi..."
    choco install ferdi
}

function Install-Pipenv {
    Write-Output "Installing pipenv..."
    pip install pipenv
    $env:PIPENV_VENV_IN_PROJECT="enabled"
    [environment]::SetEnvironmentVariable('PIPENV_VENV_IN_PROJECT', $env:PIPENV_VENV_IN_PROJECT, 'user')
}


########## MENU ##########

function Show-Menu {
    param (
        [parameter(mandatory=$false)] [string]$title = " Select Setups or Bundles ",
        [parameter(mandatory=$false)] [hashtable[]]$options = @()
    )
    # Clear-Host
    $width = $host.ui.rawui.windowsize.width
    $separator = @("=") * (($width - ($title | Measure-Object -Character).characters)/2)
    Write-Output "$(-join $separator)$title$(-join $separator)"
    
    # Setup the menu
    $labels = @()
    $bundles = @()
    for ($option=0; $option -lt $options.length; $option++) {
        if (-not $options[$option].containskey("name")) {
            Write-Warning "$option option doesn't have name, check typos in the script"
            continue
        }
        $labels += "$option`: $($options[$option]["name"])"
        if (-not $options[$option].containskey("bundles")) {
            continue
        }
        foreach($bundle in $options[$option]["bundles"]) {
            [regex]$regex = "^([\d]+: $bundle)$"
            if (($bundles -match $regex).count -eq 0) {
                $number = $bundles.count + 1000
                $bundles += "$number`: $bundle"
            }
        }
    }
    # Print the menu
    Write-Output ""
    Write-Output "Setups:"
    $labels | Format-Wide {$_} -AutoSize -Force
    Write-Output "Bundles:"
    $bundles | Format-Wide {$_} -AutoSize -Force

    $separator = @("=") * $width
    Write-Output "$(-join $separator)"

    # Get the user input
    $selections = Read-Host "Select your setups/bundles by typing there name os number separated by spaces`n"
    $selections = $selections.split(" ")
    $selected_setups = @()
    # Find the already installed setups
    foreach ($option in $options) {
        if ($option.containskey("command")) {
            $option["completed"] = [boolean](Get-Command $option["command"] -errorAction SilentlyContinue)
        }
        else { $option["completed"] = $false }
    }
    # Process the user input
    foreach ($selection in $selections) {
        # Test if the selection is a number
        if ($selection -match "^[\d\.]+$") {
            $index = $selection -as [int]
            # Test if index is out of range
            if ($index -gt $options.length) {
                Write-Warning "$option out of range, check if you selected the right setup"
                continue
            }
            $selected_setups += $options[$index]
        }
        # If the selection is some text
        else {
            foreach($option in $options) {
                # Find if the selection is in the options
                if ($selection -eq $option["name"]){
                    $selected_setups += $option
                }
                # Find if the selection is in the bundles
                else {
                    foreach($bundle in $option["bundles"] | ? {$_ -eq $selection}) {
                        $selected_setups += $option
                    }
                }
            }
            Write-Warning "Select setups/bundles by name not implemented yet, skipping $selection"
            continue
        }
    }
    # Execute the user's queries
    foreach ($setup in $selected_setups) {
        # Test of the config is already executed
        if ($setup["completed"]) {
            Write-Output "$($setup[`"name`"]) has already been done"
            continue
        }
        # Execute the command
        Execute-Setup -setup $setup -options $options
    }
}

$current_principal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $current_principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
{
    $confirmation= Read-Host "You are not under administrator privilege some setups will return errors do you want to continue ? (y/n)"
    if ($confirmation -ne "y")
    {
	return 0
    }
}
Show-Menu -options $setups