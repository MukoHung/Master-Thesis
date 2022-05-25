Write-Host "Creating necessary user account"
$pw = ConvertTo-SecureString -String "sshd_password" -AsPlainText -Force
New-LocalUser -Name sshd -Password $pw -PasswordNeverExpires -AccountNeverExpires
Add-LocalGroupMember -Group Administrators -Member sshd

Write-Host "Installing Cygwin"
Invoke-WebRequest https://cygwin.com/setup-x86_64.exe -OutFile C:\setup-x86_64.exe
Start-Process C:\setup-x86_64.exe -Wait -NoNewWindow -ArgumentList "-q -n -l C:\cygwin64\packages -s http://mirrors.kernel.org/sourceware/cygwin/ -R C:\cygwin64 -P python-devel,openssh,cygrunsrv,wget,tar,qawk,bzip2,subversion,vim,make,gcc-fortran,gcc-g++,gcc-core,make,openssl,openssl-devel,libffi-devel,libyaml-devel,git,zip,unzip,gdb,libsasl2,gettext"
Remove-Item C:\setup-x86_64.exe

Write-Host "Setting path"
$newPath = 'C:\cygwin64\bin;\cygwin\bin;' + [Environment]::GetEnvironmentVariable("PATH", [EnvironmentVariableTarget]::Machine)
[Environment]::SetEnvironmentVariable("PATH", $newPath, [EnvironmentVariableTarget]::Machine)

Write-Host "Setting Cygwin"
Start-Process C:\cygwin64\bin\bash.exe -Wait -NoNewWindow -ArgumentList "C:\cygwin64\bin\ssh-host-config --yes -c '' -u sshd -w sshd_password"

Write-Host "Write pub key to authorized_keys for password-less login"
MKDIR C:\cygwin64\home\Administrator\.ssh
Move-Item C:\authorized_keys C:\cygwin64\home\sshd\.ssh\authorized_keys -Force
C:\cygwin64\bin\chmod 700 /home/Administrator/.ssh
C:\cygwin64\bin\chmod 640 /home/Administrator/.ssh/authorized_keys
C:\cygwin64\bin\chown -R Administrator /home/Administrator

MKDIR C:\cygwin64\home\sshd
MKDIR C:\cygwin64\home\sshd\.ssh
Move-Item C:\authorized_keys C:\cygwin64\home\sshd\.ssh\authorized_keys -Force
C:\cygwin64\bin\chmod 700 /home/sshd/.ssh
C:\cygwin64\bin\chmod 640 /home/sshd/.ssh/authorized_keys
C:\cygwin64\bin\chown -R sshd /home/sshd

Write-Host "Start sshd service"
net start sshd

Write-Host "Setting firewall rule"
netsh advfirewall firewall add rule name="ssh" dir=in action=allow protocol=TCP localport=22
