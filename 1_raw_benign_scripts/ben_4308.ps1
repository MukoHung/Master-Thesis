# Must be run under 32-bit PowerShell as ProfilesApi is x86
[System.Reflection.Assembly]::LoadFrom("C:\Program Files (x86)\Intel\Intel(R) Extreme Tuning Utility\Client\ProfilesApi.dll") | Out-Null

# This script programmatically applies an Intel XTU profile. 
# This script can replace the CLI method outlined here: https://www.reddit.com/r/Surface/comments/3vslko/change_cpu_voltage_offset_with_intel_xtu_on/ 

[ProfilesApi.XtuProfileReturnCode]$applyProfileResult = 0
$profileApi = [ProfilesApi.XtuProfiles]::new()
$profileApi.Initialize() | Out-Null

[ProfilesApi.XtuProfileReturnCode]$result = 0
$profiles = $profileApi.GetProfiles([ref] $result)

$profile = $profiles | Where-Object { $_.ProfileName -eq "Undervolt" } | Select-Object -First 1

if ($profile) {
    $applied = $profileApi.ApplyProfile($profile.ProfileID, [ref]$applyProfileResult)
    if ($applied) {
        Write-Host "$applyProfileResult. Profile applied"
    } else {
        Write-Host "$applyProfileResult. Profile not applied." 
    }
}

sleep 10