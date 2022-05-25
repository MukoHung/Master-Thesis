# Clear all Android packages and user data via ADB, by @noseratio
# Run: powershell -f adb-clear-packages.ps1
# To get ADB: https://community.chocolatey.org/packages/adb
#
# Q: Why not a factory reset? 
# A: https://www.reddit.com/r/Android/comments/naetg8/a_quick_powershell_script_for_clearing_user_data/gxtaswl?context=3

$confirmation = Read-Host "This will clear all packages data and user files. Are you sure you want to proceed? (y|n)"
if ($confirmation -ne 'y') {
  return
}

adb.exe shell "find /sdcard/ -type f -delete"

$rawList = $(adb.exe shell pm list packages | Sort-Object | Out-String)

$packages = [Regex]::Split($rawList, '\r?\n')

foreach ($package in $packages) {
  if ($package -match '^\s*package\s*:\s*(\S+?)\s*$') {
   	$packageName = $matches[1]
    echo $packageName
    adb.exe shell "pm clear $packageName"
  }    
}
