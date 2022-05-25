# This script only works when Google Drive is mounted at G:\
# Change the encoding to UTF-8-BOM before executing this script
# To run this file: powershell -noprofile -executionpolicy bypass -file ./PinGoogleDriveFS.ps1 [add/remove]

# Settings
$ErrorActionPreference = "Stop"
$clsid     = "{81539FE6-33C7-4CE7-90C7-1C7B8F2F2D41}" # CLSID for personal drive namespace
$clsid_i   = "{0E5AAE11-A475-4c5b-AB00-C66DE400274E}" # CLSID for personal drive instance
$clsid_g   = "{FB9411E2-c3F8-4004-BA95-47D459C219D1}" # CLSID for shared drive namespace
$clsid_g_i = "{1A223FF4-D08D-4B38-A051-5D2391FE655C}" # CLSID for shared drive instance

# Affected keys
$hkey_clsid = "HKCU:\Software\Classes\CLSID\$clsid"
$hkey_clsid64 = "HKCU:\Software\Classes\Wow6432Node\CLSID\$clsid"
$hkey_ns = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\$clsid"
$hkey_clsid_g = "HKCU:\Software\Classes\CLSID\$clsid_g"
$hkey_clsid_g64 = "HKCU:\Software\Classes\Wow6432Node\CLSID\$clsid_g"
$hkey_ns_g = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\$clsid_g"
$hkey_panel = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel"

if (($args.Count -eq 0) -or ($args[0].ToLower() -eq "add"))
{
	trap { "Please run remove first."; break; }

    # Find the path and folder
    $gexec = (Get-ItemProperty HKCU:\Software\Classes\GoogleDriveFS.gdoc\DefaultIcon).'(default)'
    $iconidx = $gexec.Length-2
    $drive_icon = $gexec.Remove($iconidx).Insert($iconidx,"16")
    $drive_icon_g = $gexec.Remove($iconidx).Insert($iconidx,"18")
    switch ([System.Threading.Thread]::CurrentThread.CurrentCulture.Name) {
        "en-US" { $folder = "My Drive"; $folder_g = "Shared drives" }
        "zh-CN" { $folder = "我的云端硬盘" ; $folder_g = "共享云端硬盘" }
		"nl-BE" { $folder = "Mijn Drive"; $folder_g = "Gedeelde drives" }
        Default { $folder = "My Drive"; $folder_g = "Shared drives" }
    }
    
    # Update Registry for personal drive
    New-Item $hkey_clsid -itemType String -value "Google Drive"
    New-ItemProperty $hkey_clsid -name "System.IsPinnedToNamespaceTree" -propertyType DWord -value 1
    New-ItemProperty $hkey_clsid -name "SortOrderIndex" -propertyType DWord -value 0x00000040
    New-Item $hkey_clsid\InProcServer32 -itemType ExpandString -value "%SYSTEMROOT%\system32\shell32.dll"
    New-Item $hkey_clsid\ShellFolder
    New-ItemProperty $hkey_clsid\ShellFolder -name "FolderValueFlags" -propertyType DWord -value 0x00000028
    New-ItemProperty $hkey_clsid\ShellFolder -name "Attributes" -propertyType DWord -value 0xf080004d
    New-Item $hkey_clsid\DefaultIcon -itemType String -value $drive_icon
    New-Item $hkey_clsid\Instance
    New-ItemProperty $hkey_clsid\Instance -name "CLSID" -propertyType String -value "$clsid_i"
    New-Item $hkey_clsid\Instance\InitPropertyBag
    New-ItemProperty $hkey_clsid\Instance\InitPropertyBag -name "Attributes" -propertyType DWord -value 0x00000011
    New-ItemProperty $hkey_clsid\Instance\InitPropertyBag -name "TargetFolderPath" -propertyType String -value "G:\$folder"

    New-Item $hkey_clsid64 -itemType String -value "Google Drive"
    New-ItemProperty $hkey_clsid64 -name "System.IsPinnedToNamespaceTree" -propertyType DWord -value 1
    New-ItemProperty $hkey_clsid64 -name "SortOrderIndex" -propertyType DWord -value 0x00000040
    New-Item $hkey_clsid64\InProcServer32 -itemType ExpandString -value "%SYSTEMROOT%\system32\shell32.dll"
    New-Item $hkey_clsid64\ShellFolder
    New-ItemProperty $hkey_clsid64\ShellFolder -name "FolderValueFlags" -propertyType DWord -value 0x00000028
    New-ItemProperty $hkey_clsid64\ShellFolder -name "Attributes" -propertyType DWord -value 0xf080004d
    New-Item $hkey_clsid64\DefaultIcon -itemType String -value $drive_icon
    New-Item $hkey_clsid64\Instance
    New-ItemProperty $hkey_clsid64\Instance -name "CLSID" -propertyType String -value "$clsid_i"
    New-Item $hkey_clsid64\Instance\InitPropertyBag
    New-ItemProperty $hkey_clsid64\Instance\InitPropertyBag -name "Attributes" -propertyType DWord -value 0x00000011
    New-ItemProperty $hkey_clsid64\Instance\InitPropertyBag -name "TargetFolderPath" -propertyType String -value "G:\$folder"

    New-ItemProperty $hkey_panel -name $clsid -propertyType DWord -value 1
    New-Item $hkey_ns  -itemType String -value "Google Drive"
	
    # Update Registry for shared drives
	if(Test-Path "G:\$folder_g")
	{
		New-Item $hkey_clsid_g -itemType String -value "Google Shared Drives"
		New-ItemProperty $hkey_clsid_g -name "System.IsPinnedToNamespaceTree" -propertyType DWord -value 1
		New-ItemProperty $hkey_clsid_g -name "SortOrderIndex" -propertyType DWord -value 0x00000041
		New-Item $hkey_clsid_g\InProcServer32 -itemType ExpandString -value "%SYSTEMROOT%\system32\shell32.dll"
		New-Item $hkey_clsid_g\ShellFolder
		New-ItemProperty $hkey_clsid_g\ShellFolder -name "FolderValueFlags" -propertyType DWord -value 0x00000028
		New-ItemProperty $hkey_clsid_g\ShellFolder -name "Attributes" -propertyType DWord -value 0xf080004d
		New-Item $hkey_clsid_g\DefaultIcon -itemType String -value $drive_icon_g
		New-Item $hkey_clsid_g\Instance
		New-ItemProperty $hkey_clsid_g\Instance -name "CLSID" -propertyType String -value "$clsid_g_i"
		New-Item $hkey_clsid_g\Instance\InitPropertyBag
		New-ItemProperty $hkey_clsid_g\Instance\InitPropertyBag -name "Attributes" -propertyType DWord -value 0x00000011
		New-ItemProperty $hkey_clsid_g\Instance\InitPropertyBag -name "TargetFolderPath" -propertyType String -value "G:\$folder_g"

		New-Item $hkey_clsid_g64 -itemType String -value "Google Shared Drives"
		New-ItemProperty $hkey_clsid_g64 -name "System.IsPinnedToNamespaceTree" -propertyType DWord -value 1
		New-ItemProperty $hkey_clsid_g64 -name "SortOrderIndex" -propertyType DWord -value 0x00000041
		New-Item $hkey_clsid_g64\InProcServer32 -itemType ExpandString -value "%SYSTEMROOT%\system32\shell32.dll"
		New-Item $hkey_clsid_g64\ShellFolder
		New-ItemProperty $hkey_clsid_g64\ShellFolder -name "FolderValueFlags" -propertyType DWord -value 0x00000028
		New-ItemProperty $hkey_clsid_g64\ShellFolder -name "Attributes" -propertyType DWord -value 0xf080004d
		New-Item $hkey_clsid_g64\DefaultIcon -itemType String -value $drive_icon_g
		New-Item $hkey_clsid_g64\Instance
		New-ItemProperty $hkey_clsid_g64\Instance -name "CLSID" -propertyType String -value "$clsid_g_i"
		New-Item $hkey_clsid_g64\Instance\InitPropertyBag
		New-ItemProperty $hkey_clsid_g64\Instance\InitPropertyBag -name "Attributes" -propertyType DWord -value 0x00000011
		New-ItemProperty $hkey_clsid_g64\Instance\InitPropertyBag -name "TargetFolderPath" -propertyType String -value "G:\$folder_g"

		New-ItemProperty $hkey_panel -name $clsid_g -propertyType DWord -value 1
		New-Item $hkey_ns_g  -itemType String -value "Google Shared Drives"
	}
	
    Write-Output "Add successfully"
}
elseif ($args[0].ToLower() -eq "remove")
{
    if (Test-Path $hkey_clsid) { Remove-Item $hkey_clsid -recurse }
    if (Test-Path $hkey_clsid64) { Remove-Item $hkey_clsid64 -recurse }
    if (Test-Path $hkey_ns) { Remove-Item $hkey_ns -recurse }
    if (Test-Path $hkey_clsid_g) { Remove-Item $hkey_clsid_g -recurse }
    if (Test-Path $hkey_clsid_g64) { Remove-Item $hkey_clsid_g64 -recurse }
    if (Test-Path $hkey_ns_g) { Remove-Item $hkey_ns_g -recurse }
    if ((Get-Item $hkey_panel -EA Ignore).Property -contains $clsid) { Remove-ItemProperty $hkey_panel $clsid }
    if ((Get-Item $hkey_panel -EA Ignore).Property -contains $clsid_g) { Remove-ItemProperty $hkey_panel $clsid_g }
    
    Write-Output "Remove successfully."
}
else
{
    Write-Error "The valid option are 'add' and 'remove'"
}
