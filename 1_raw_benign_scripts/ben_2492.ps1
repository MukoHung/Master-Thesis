$error.clear()
try {
New-Item –Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Force | New-ItemProperty -Name "DisableWindowsConsumerFeatures" -Value "1" -PropertyType "DWORD"
 }
catch { "Error occured" }
if ($error) {
Set-Itemproperty -path HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent -Name 'DisableWindowsConsumerFeatures' -value '1'
}

