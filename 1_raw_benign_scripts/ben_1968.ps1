$version = '9.6.1'

# from /Applications/VMware Fusion.app/Contents/Library/isoimages/windows.iso
$iso_name = 'vmware_fusion_tools_windows_6.0.3.iso'
$download_url = "http://host.example.com/$iso_name"

(New-Object System.Net.WebClient).DownloadFile($download_url, "c:\windows\temp\$iso_name")
&c:\7-zip\7z.exe x "c:\windows\temp\$iso_name" -oc:\windows\temp\vmware -aoa | Out-Host
&c:\windows\temp\vmware\setup.exe /S /v`"/qn REBOOT=R`" | Out-Host

exit 0