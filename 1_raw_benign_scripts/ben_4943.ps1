# .\InstallNCTSecurityModule.ps1

# This script will check for the needed admin credentials of the user to adjust PowerShell Modules
# Then copy the NCTSecurityModule to a local PowerShell module pathway.
# Then by Import-Module, it will call the .\NCTSecurityModule.psm1 import script.
# Then all of the NCTSecurityModule, and sub functions should be available to that user, on this machine.

# gl = get location, which is what the $PSScriptRoot does by capturing the pathway that this script is executed from.
# No matter where this install file is being held, it will gather that specific pathway.
# This is to make sure the system can also gather the Function files that are sitting next to this install script.
# A user can download the NCTSecurityModule directory anywhere, and it will always recognize that location.

#================================================================
$gl = $PSScriptRoot
# Should end up with something like:  "PS C:\Users\ncterry\Downloads\NCTSecurityModule> "
# The directory where this script is sitting.
$functionPath = $gl

# Create a test directory/file in the PowerShell module location to verify the needed admin credentials.
New-Item -ItemType Directory "C:\Program Files\WindowsPowerShell\Modules\AdminTEST"


# Create a test file, and check if we can add to that test file.
If (Test-Path -Path "C:\Program Files\WindowsPowerShell\Modules\AdminTEST") {
    New-Item -ItemType File "C:\Program Files\WindowsPowerShell\Modules\AdminTEST\adminTestFile.txt"
    Add-Content -Path "C:\Program Files\WindowsPowerShell\Modules\AdminTEST\adminTestFile.txt" -Value "Admin test text"

} Else {
    Write-Warning ("User does not have admin privileges to adjust WindowsPowerShell modules.")
} #End If/Else


# Remove the test 
Remove-Item -Path "C:\Program Files\WindowsPowerShell\Modules\AdminTEST" -Force -Recurse

# Copy the NCTSecurity Module directory into the Windows PowerShell Module directory.
Copy-Item $functionPath -Destination "C:\Program Files\WindowsPowerShell\Modules" -Recurse -Force

# We copied the directory to the PowerShell module pathway
# Now we can import that specific module NAME into the PowerShell Cache
Import-Module NCTSecurityModule -Force -Verbose

# Open the newly created Powershell Module directory
explorer.exe "C:\Program Files\WindowsPowerShell\Modules\NCTSecurityModule"
#================================================================
