
# Update to Latest Windows 10 Spring Refresh

# Install WSL
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux

# Get Ubuntu installed - https://docs.microsoft.com/en-us/windows/wsl/install-on-server
wsl.exe

# Install ChefDK deb package

# Symlink Relevant Home Folders
cd ~
ln -s /mnt/c/Users/DwyerB/.aws/ .
ln -s /mnt/c/Users/DwyerB/.chef/ .
ln -s /mnt/c/Users/DwyerB/.ssh/ .

# Enable Regular Permissions
# /etc/wsl.conf
[automount]
enabled = true
options = "metadata,umask=77" # fmask=111 ? Not sure what fmask does yet

# Make it take effect Immediately
sudo umount /mnt/c
sudo mount -t drvfs C: /mnt/c -o metadata,uid=1000,gid=1000,umask=77



# Create Relevant PowerShell Functions
function kitchen
{
  wsl kitchen $args
}

function knife
{
  wsl knife $args
}