#install features on win10
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All

#execution-policy
https://vladtalkstech.com/2015/03/windows-powershell-updated-execution-policy-successfully-setting-overridden-policy-defined-specific-scope.html
https://vladtalkstech.com/2014/03/change-powershell-machinepolicy-execution-policy-windows-server-2012r2.html

#get all the features
Get-WindowsCapability -online

#get all features that have rsat
get-windowscapability -online -name RSAT*

#Install all rsat features
get-windowscapability -online -name RSAT* | Add-WindowsCapability -Online

#powershell remoting

# interactive remote session
$cred = Get-Credential
Enter-PSSession -ComputerName computer -Credential $cred

# create a new session and copy files to it
$s = New-PSSession -ComputerName computer
Copy-Item -Path c:\dir\ -Destination c:\ -Recurse -ToSession $s

# interactive remote session 
Enter-PSSession $s

# send commands to a remote machine
Invoke-Command -ComputerName computer -ScriptBlock {Get-Service}

# send commands to multiple machines
Invoke-Command -ComputerName computer,computer -ScriptBlock {Get-Service wuau*}

# run a powershell script on multiple machines
Invoke-Command -ComputerName computer, computer -FilePath c:\dir\powershell.ps1

#allow scripts
get-executionPolicy
set-executionpolicy -ExecutionPolicy RemoteSigned

# When managing from a win 10 machine you need to add the below into the client win 10 machine

winrm quickconfig
winrm set winrm/config/client '@{TrustedHosts="Computer1,Computer2"}'

