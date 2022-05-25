# https://gist.github.com/jchandra74/5b0c94385175c7a8d1cb39bc5157365e
$ModulePath = $Env:PSModulePath.Split(";")[0]
Write-Host "It is needed to have installed the PowerLine fonts for Windows"
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
Install-Module -Name 'posh-git' -Scope CurrentUser
Install-Module -Name 'oh-my-posh' -Scope CurrentUser
if(!(Test-Path -Path "$ModulePath\Get-ChildItemColor")) {
    New-Item -ItemType Directory -Path "$ModulePath\Get-ChildItemColor" -Force
} else {
    if(Test-Path -Path "$ModulePath\Get-ChildItemColor") {
        Remove-Item -Path "$ModulePath\Get-ChildItemColor" -Recurse -Force
    }
}
git clone https://github.com/cmilanf/Get-ChildItemColor.git "$ModulePath\Get-ChildItemColor"
Copy-Item -Path powershell_profile.ps1 -Destination $PROFILE -Force
#Get-Content -Path powershell_profile.ps1 | Set-Content -Path $env:ConEmuDir\..\profile.ps1