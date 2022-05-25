# Valheim Plus Install Script
This script was created to make installing and updating the latest version of Valheim plus as simple as possible.



## Shortcut Method
To make a shortcut:
1. Right Click Desktop -> New Shortcut

![image](https://user-images.githubusercontent.com/15258962/110214629-50a3ca80-7e5a-11eb-9fc0-e3402ecee98d.png)
1. Paste the following into the shortcut box
```powershell
powershell.exe -command "iwr -useb 'git.io/ValheimPlusInstall' | iex;sleep 5"
```
1. Name the shortcut whatever you want (I recommend `Valheim Plus Updater`)
1. Click OK
1. Click the shortcut. You may need to Right Click -> Run as Administrator

## Command Line Method
1. Open an admin powershel prompt on your computer:
* Press the windows key
* type 'powershell'
* Type ctrl-shift-Enter to start powershell in admin mode (this is required because Valheim is typically stored in a location that requires admin access)
2. Copy and paste the following into the window
```powershell
iwr -useb 'git.io/ValheimPlusInstall' | iex
```
3. Latest version of valheim plus should automatically install
![InstallDemo](https://user-images.githubusercontent.com/15258962/110214543-f0148d80-7e59-11eb-95fd-77fb3662e2f0.gif)

## Advanced Usage
Install to pre-existing dedicated server. It will auto-detect the dedicated server `valheim-server.exe` and download the correct bits
```powershell
. ([scriptblock]::Create((iwr -useb 'git.io/ValheimPlusInstall'))) -Path C:\path\to\my\server
```