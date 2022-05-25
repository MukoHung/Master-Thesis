# Script will add Device to autopilot. Will add Device group that you choose.

# Sets execution policy that allows to run powershell script
Set-ExecutionPolicy -ExecutionPolicy bypass

#While loop until user choose one option
$data = $true
while($data) {

# Asking customer to install    
# When adding new customer remove <# move it to next empty name!
$customer = Read-Host "You can choose one from list or enter address manually." `n"1: Enter address manually" `n"2: CustomerName" `n"3: CustomerName" `n"3: CustomerName" `n"6: CustomerName" `n"7: CustomerName" `n"8: CustomerName" `n"Choose customer"


# Check if AutoPilotScript is installed
# Collect Windows Autopilot info and Upload it to Azure

switch ($customer) {
    1 { $customerChoice = Read-Host "Enter customer manually"
        # Remove # to get script ask group tag
        #$groupName = Read-Host "Enter GroupTag"
        $InstalledScripts = Get-InstalledScript
        If ($InstalledScripts.name -notcontains "Upload-WindowsAutopilotDeviceInfo") {
        Install-Script -Name Upload-WindowsAutopilotDeviceInfo -force
        }
        Upload-WindowsAutopilotDeviceInfo.ps1 -TenantName "$customerChoice" -Verbose
        # Remove # from orderidentifier if you want to give group tag manually
        #-OrderIdentifier "$groupName"
        $data = $false; break;} 

    2 { $InstalledScripts = Get-InstalledScript
        If ($InstalledScripts.name -notcontains "Upload-WindowsAutopilotDeviceInfo") {
        Install-Script -Name Upload-WindowsAutopilotDeviceInfo -force
        }
        Upload-WindowsAutopilotDeviceInfo.ps1 -TenantName "AddCustomerHere.onmicrosoft.com" -Verbose 
        # Remove # from orderidentifier if you want to give group tag manually
        #-OrderIdentifier "CustomerGroupTag"
        $data = $false; break;}

    

    3 { $InstalledScripts = Get-InstalledScript
        If ($InstalledScripts.name -notcontains "Upload-WindowsAutopilotDeviceInfo") {
        Install-Script -Name Upload-WindowsAutopilotDeviceInfo -force
        }
        Upload-WindowsAutopilotDeviceInfo.ps1 -TenantName "AddCustomerHere.onmicrosoft.com" -Verbose 
        # Remove # from orderidentifier if you want to give group tag manually
        #-OrderIdentifier "CustomerGroupTag"
        $data = $false; break;}



    4 { $InstalledScripts = Get-InstalledScript
        If ($InstalledScripts.name -notcontains "Upload-WindowsAutopilotDeviceInfo") {
        Install-Script -Name Upload-WindowsAutopilotDeviceInfo -force
        }
        Upload-WindowsAutopilotDeviceInfo.ps1 -TenantName "AddCustomerHere.onmicrosoft.com" -Verbose 
        # Remove # from orderidentifier if you want to give group tag manually
        #-OrderIdentifier "CustomerGroupTag"
        $data = $false; break;}



    5 { $InstalledScripts = Get-InstalledScript
        If ($InstalledScripts.name -notcontains "Upload-WindowsAutopilotDeviceInfo") {
        Install-Script -Name Upload-WindowsAutopilotDeviceInfo -force
        }
        Upload-WindowsAutopilotDeviceInfo.ps1 -TenantName "AddCustomerHere.onmicrosoft.com" -Verbose 
        # Remove # from orderidentifier if you want to give group tag manually
        #-OrderIdentifier ""
        $data = $false; break;}



    6 { $InstalledScripts = Get-InstalledScript
        If ($InstalledScripts.name -notcontains "Upload-WindowsAutopilotDeviceInfo") {
        Install-Script -Name Upload-WindowsAutopilotDeviceInfo -force
        }
        Upload-WindowsAutopilotDeviceInfo.ps1 -TenantName "AddCustomerHere.onmicrosoft.com" -Verbose 
        # Remove # from orderidentifier if you want to give group tag manually
        #-OrderIdentifier "CustomerGroupTag"
        $data = $false; break;}



    7 { $InstalledScripts = Get-InstalledScript
        If ($InstalledScripts.name -notcontains "Upload-WindowsAutopilotDeviceInfo") {
        Install-Script -Name Upload-WindowsAutopilotDeviceInfo -force
        }
        Upload-WindowsAutopilotDeviceInfo.ps1 -TenantName "AddCustomerHere.onmicrosoft.com" -Verbose 
        # Remove # from orderidentifier if you want to give group tag manually
        #-OrderIdentifier "CustomerGroupTag"
        $data = $false; break;}

     default {break;}
}
}

# Restart Computer so AutoPilot will get certs
Restart-Computer    

