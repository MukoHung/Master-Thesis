#--- HELP ---#
#region Help

<# 
.SYNOPSIS
Change the system proxy value script by Steven JALABERT.

.DESCRIPTION
This script will change the system proxy value.

.NOTES
This script does not require an elevated account for execution.
#>

#endregion

#--- ATTRIBUTES ---#
#region Constants
$proxyRegistryKeyPath = 'hkcu:Software\Microsoft\Windows\CurrentVersion\Internet Settings'
$proxyURL = ''
#endregion

#--- FUNCTIONS ---#
#region Functions
Function pause ($message)
{
    # Check if running Powershell ISE
    if ($psISE)
    {
        Add-Type -AssemblyName System.Windows.Forms
        [System.Windows.Forms.MessageBox]::Show("$message")
    }
    else
    {
        Write-Host "$message" -ForegroundColor Yellow
        $x = $host.ui.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    }
}
#endregion

#--- SCRIPT ---#
#region Script
try
{
    get-itemproperty -path $proxyRegistryKeyPath -Name AutoConfigURL | Write-Output
    set-itemproperty -path $proxyRegistryKeyPath -Name AutoConfigURL -value $proxyURL -type string
    get-itemproperty -path $proxyRegistryKeyPath -Name AutoConfigURL | Write-Output
    Write-Host "Successfully Changed proxy configuration to new URL." -ForegroundColor Green
}
Catch
{
    write-host $_.Exception.Message
}

pause('Press any key to continue...');
#endregion