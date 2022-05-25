# Simple script to remove the Windows 10 "Nag" Updates and telemetry additions for Windows 7 & 8 users
# This will uninstall the updates and hide them, preventing installation in the future
# Note: MUST BE RUN AS ADMINISTRATOR, setting updates to hidden requires admin permissions
# Updates removed:
# KB3035583 - Update installs Get Windows 10 app in Windows 8.1 and Windows 7 SP1
#   https://support.microsoft.com/en-us/kb/3035583
# KB2952664 - Compatibility update for upgrading Windows 7
#   https://support.microsoft.com/en-us/kb/2952664
# KB2976978 - Compatibility update for Windows 8.1 and Windows 8
#   https://support.microsoft.com/en-us/kb/2976978
# KB3021917 - Update to Windows 7 SP1 for performance improvements
#   https://support.microsoft.com/en-us/kb/3021917
# KB3044374 - Update that enables you to upgrade from Windows 8.1 to Windows 10
#   https://support.microsoft.com/en-us/kb/3044374
# KB2990214 - Update that enables you to upgrade from Windows 7 to a later version of Windows
#   https://support.microsoft.com/en-us/kb/2990214
# KB3022345 - Update for customer experience and diagnostic telemetry
#   https://support.microsoft.com/en-us/kb/3022345
# KB3075249 - Update that adds telemetry points to consent.exe in Windows 8.1 and Windows 7
#   https://support.microsoft.com/en-us/kb/3075249
# KB3080149 - Update for customer experience and diagnostic telemetry
#   https://support.microsoft.com/en-us/kb/3080149
$KBs = @("KB3035583","KB2952664","KB2976978","KB3021917","KB3044374","KB2990214","KB3022345","KB3075249","KB3080149")
$Updates = (New-Object -com "Microsoft.Update.Session").CreateupdateSearcher().Search("Type='Software'").Updates
foreach ($Update in $Updates) {
    $Id = $Update.KBArticleIDs
    if ($KBs -NotContains "KB$Id") { Continue }
    
    "Processing Windows Update KB$($Id):"
    "  Status:"
    "    Installed: $($Update.IsInstalled)"
    "    Hidden: $($Update.IsHidden)"
    if ($Update.IsInstalled) {
        "  Uninstalling Update: KB$Id..."
        Start-Process wusa -ArgumentList "/uninstall /kb:$Id /quiet /norestart" -Wait
    }
    if (-Not $Update.IsHidden) {
        "  Hiding Update: KB$Id"
        Try { 
            $Update.IsHidden = $true
        }
        Catch {
            Write-Warning "Unable to hide update, you must run this script as Administrator."
        }
    }
}