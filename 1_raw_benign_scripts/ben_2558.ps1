# Ensure chocolatey is already installed!

$packages = 'googlechrome', 'git', 'notepadplusplus', 'winrar', 'vscode', 'cmder', '7zip', 'adobereader', 'sysinternals', 'python', 'python2', 'jdk8', 'advanced-ip-scanner', 'registrychangesview'

ForEach ($PackageName in $Packages)
{
    # change to install if there's no need to upgrade
    choco upgrade $PackageName -y
}