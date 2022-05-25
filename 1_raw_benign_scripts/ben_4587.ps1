param(
    #File containing all users and administrators that should exist on the target computer
    [Parameter(Mandatory=$true)]
    [string]$userAccountsFilePath,

    #Default password to change bad passwords to
    [Parameter(Mandatory=$true)]
    [Security.SecureString]$defaultPassword,

    #Determines if scripts will output extra debug information.
    [switch]$enableAdvancedDebugMode
)

#Notifies the user if Advanced Debug Mode is enabled.
if($enableAdvancedDebugMode){
    Write-Host ""
    Write-Host "Advanced Debug Mode is now enabled."
}
Write-Host ""

while(!(Test-Path -Path $userAccountsFilePath)){
    if($enableAdvancedDebugMode){
        Write-Host "Output of Test-Path command was: " + (Test-Path -Path $userAccountsFilePath)
    }
    Write-Host "The userAccountsFile that you entered was invalid. Please enter a new file path."
    $userAccountsFilePath = Read-Host -Prompt "New path"
    Write-Host ""
}

$OSName = (Get-WmiObject win32_operatingsystem).name
if($enableAdvancedDebugMode){
    Write-Host "OS is $OSName."
}

#Call CheckAccounts.ps1 with parameter input
$ScriptPath = $PSScriptRoot + "\AllWindowsBuilds"
& "$($ScriptPath)\CheckAccounts.ps1" $userAccountsFilePath $enableAdvancedDebugMode

#Call CheckPassword.ps1 with parameter input
$ScriptPath = $PSScriptRoot + "\AllWindowsBuilds"
& "$($ScriptPath)\CheckPassword.ps1" $userAccountsFilePath $defaultPassword $enableAdvancedDebugMode

#Call SearchDirectories.ps1 with parameter input
$ScriptPath = $PSScriptRoot + "\AllWindowsBuilds"
& "$($ScriptPath)\SearchDirectories.ps1" $userAccountsFilePath $enableAdvancedDebugMode

#Call WindowsDefender.ps1 with parameter input
$ScriptPath = $PSScriptRoot + "\AllWindowsBuilds"
& "$($ScriptPath)\WindowsDefender.ps1" $enableAdvancedDebugMode

if($OSName -contains "server"){
    #Call CheckIIS(Server).ps1 with parameter input
    $ScriptPath = $PSScriptRoot + "\ServerSpecific"
    & "$($ScriptPath)\CheckIIS(Server).ps1" $enableAdvancedDebugMode
}

#Call WindowsUpdates.ps1 with parameter input
$ScriptPath = $PSScriptRoot + "\AllWindowsBuilds"
& "$($ScriptPath)\WindowsUpdates.ps1" $enableAdvancedDebugMode