# Requires:
# Set-ExecutionPolicy RemoteSigned -s CurrentUser

# Install apps
iex (New-Object Net.WebClient).DownloadString('https://get.scoop.sh')

scoop install git

scoop bucket add extras
scoop install vscode
scoop install sqlopsstudio
scoop install storageexplorer

$gist = 'https://gist.githubusercontent.com/loic-sharma/4782d0bceeee961bc25a0429a1afa899/raw/82165f0d4ba58a08eeb32ea379d3def1fdff48ca'

# Add PowerShell profile script
mkdir (Split-Path $profile)
(New-Object Net.WebClient).DownloadFile("$($gist)/profile.ps1", $profile)

# Add VSCode to Context Menus
(New-Object Net.WebClient).DownloadFile("$($gist)/vscode.reg", "$($env:temp)\\vscode.reg")
& reg import "$($env:temp)\\vscode.reg"

# Configure git
git config --global user.email "sharma.loic@gmail.com"
git config --global user.name "Loic Sharma"

git config --global alias.st status
git config --global alias.b branch
git config --global alias.co checkout

# Install codebases
mkdir ~\Code
cd ~\Code

git clone https://github.com/NuGet/NuGet.Client.git
git clone https://github.com/NuGet/NuGet.Jobs.git
git clone https://github.com/NuGet/NuGet.Services.EndToEnd.git
git clone https://github.com/NuGet/NuGet.Services.Metadata.git
git clone https://github.com/NuGet/NuGetGallery.git
git clone https://github.com/NuGet/ServerCommon.git