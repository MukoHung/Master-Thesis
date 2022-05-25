#Predefine necessary information
$Username = "YOURDOMAIN\username"
$Password = "password"
$ComputerName = "server"
$Script = {notepad.exe}

#Create credential object
$SecurePassWord = ConvertTo-SecureString -AsPlainText $Password -Force
$Cred = New-Object -TypeName "System.Management.Automation.PSCredential" -ArgumentList $Username, $SecurePassWord

#Create session object with this
$Session = New-PSSession -ComputerName $ComputerName -credential $Cred
# Enter-PSSession

#Invoke-Command
$job = invoke-command -session $session -scriptblock $script
echo $job

#Close Session
Remove-PSSession -Session $Session

