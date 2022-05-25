# Set Processor Scheduling to "Programs" (default: "Background services")
echo 'Windows Registry Editor Version 5.00

[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\PriorityControl]
"Win32PrioritySeparation"=dword:00000026

' > PriorityControl.reg
regedit /s PriorityControl.reg

# install chocolatey
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# install packages
choco install -y git azure-cli az.powershell vscode dotnet-6.0-sdk-1xx microsoftazurestorageexplorer googlechrome setdefaultbrowser azure-data-studio microsoft-windows-terminal GoogleJapaneseInput powershell-core sakuraeditor quicklook sharex wox copyq insomnia-rest-api-client postman velocity

# install Azure Function Core Tools 4.x (choco has only 3.x)
iwr -outf func-cli-x64.msi https://go.microsoft.com/fwlink/?linkid=2174087
msiexec /i "func-cli-x64.msi" /passive /norestart

# install httprepl
& "C:\Program Files\dotnet\dotnet.exe tool install -g Microsoft.dotnet-httprepl"

refreshenv

# set Edge as default browser
# SetDefaultBrowser.exe HKLM "Microsoft Edge" delay=1000
SetDefaultBrowser.exe chrome

# set Timezone
tzutil.exe /s "Tokyo Standard Time"
