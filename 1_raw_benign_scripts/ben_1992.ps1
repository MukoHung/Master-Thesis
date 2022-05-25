Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force

$library = "\\library\PoSh\00_Builds\00_SQLServer"
Push-Location -Path $library

Push-Location -Path "$library\Modules"
foreach($module in Get-ChildItem)
{
    Import-Module ".\$module"
}
Pop-Location

.\Install-WMF-5.0.ps1
.\Install-DotNet3.5Framework.ps1
.\SetupSQLDisks.ps1
.\TestServiceAccounts.ps1
.\SetupNodePrivileges.ps1         # psedit .\SetupNodePrivileges.ps1
.\Mount-SQL-DVD.ps1
.\InstallSQL.ps1                  # psedit .\InstallSQL.ps1
.\databaseMailSetup.ps1           # psedit .\databaseMailSetup.ps1
.\ConfigureTempDB.ps1             # psedit .\ConfigureTempDB.ps1
.\AdvancedSQLOptions.ps1          # psedit .\AdvancedSQLOptions.ps1
.\DatabaseMaintenancePlans.ps1    # psedit .\DatabaseMaintenancePlans.ps1
.\InstallTSM.ps1                  # psedit .\InstallTSM.ps1
.\AddSpotLightUser.ps1            # psedit .\AddSpotLightUser.ps1 


Pop-Location
pause
Restart-Computer -Force
