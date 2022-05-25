Install-WindowsUpdate
Set-WindowsExplorerOptions -EnableShowHiddenFilesFoldersDrives -EnableShowFileExtensions
Set-TaskbarOptions -Size Large -Lock -Dock Top
Update-ExecutionPolicy
Enable-RemoteDesktop
cinst IIS-ManagementScriptingTools -source windowsfeatures -y
cinst powershell -y
cinst 7zip -y
cinst git -y
cinst poshgit -y
cinst irfanview -y
cinst sumatrapdf -y
cinst paint.net -y
cinst logparser -y
cinst googlechrome -y
cinst firefox -y
cinst fiddler4 -y
cinst graphviz -y
# prefer ublock lately
#cinst adblockplusfirefox -y
cinst linqpad -y
cinst microsoft-build-tools -y
cinst nunit -y
cinst visualfsharptools -y
cinst resharper -y
cinst javaruntime-preventasktoolbar -y
cinst jdk8 -y
cinst nodejs -y
cinst webdeploy -y
cinst webpi -y
cinst sliksvn -y
cinst emeditor -y
#cinst semanticmerge -y
#cinst mssqlservermanagementstudio2014express -y
# No VS2015 yet
#cinst visualstudio2013ultimateupdate2 -y
#cinst vs2013.4 -y
#cinst visualstudio2013-webessentials.vsix -y
cinst markdownpad2 -y
