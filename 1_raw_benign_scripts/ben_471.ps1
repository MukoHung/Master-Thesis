# Setup Boxstarter
# . { iwr -useb https://boxstarter.org/bootstrapper.ps1 } | iex; get-boxstarter -Force

Disable-UAC
Disable-MicrosoftUpdate

Set-WindowsExplorerOptions -EnableShowHiddenFilesFoldersDrives -EnableShowProtectedOSFiles -EnableShowFileExtensions
Set-TaskbarOptions -Size small -Lock -Dock Left -Combine Always
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux

cinst -y vscode 
cinst -y virtualbox
cinst -y vagrant 
cinst -y cmder
cinst -y neovim
cinst -y 7zip 
cinst -y github
cinst -y autohotkey.install
cinst -y firefox
cinst -y nodejs-lts 
# Python2 required by NodeJS (apparently)
cinst -y python2
cinst -y git-credential-manager-for-windows 
cinst -y paint.net 
cinst -y foxitreader 
cinst -y steam
cinst -y vlc
cinst -y microsoftwebdriver

Invoke-WebRequest -Uri https://aka.ms/wsl-ubuntu-1804 -OutFile ~/Ubuntu.appx -UseBasicParsing
Add-AppxPackage -Path ~/Ubuntu.appx

code --install-extension ms-vscode.csharp
code --install-extension formulahendry.code-runner
code --install-extension naumovs.color-highlight
code --install-extension pranaygp.vscode-css-peek
code --install-extension hbenl.vscode-firefox-debug
code --install-extension joelday.docthis
code --install-extension waderyan.gitblame
code --install-extension abusaidm.html-snippets
code --install-extension waderyan.nodejs-extension-pack
code --install-extension IBM.output-colorizer
code --install-extension ms-vscode.powershell
code --install-extension minhthai.vscode-todo-parser
code --install-extension marcostazi.vs-code-vagrantfile
code --install-extension vscodevim.vim
code --install-extension christian-kohler.path-intellisense

Enable-UAC
Enable-MicrosoftUpdate
Install-WindowsUpdate -acceptEula