# Resets the password for the default LXSS / WSL bash user, based on https://askubuntu.com/a/808425/697555
$lxssUsername = (Get-ItemProperty HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Lxss).DefaultUsername
lxrun /setdefaultuser root
bash -c "passwd $lxssUsername"
lxrun /setdefaultuser $lxssUsername