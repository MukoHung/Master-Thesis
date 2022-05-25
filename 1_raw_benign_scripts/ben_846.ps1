$windowsFeatures = @(
    'Web-Server',
    'Web-WebServer',
    'Web-Mgmt-Console',
    'Web-Mgmt-Tools'
);

Install-WindowsFeature -Name $windowsFeatures

#Workaround for IIS Permissions Issues
New-SmbShare -Name vagrant -Path C:\vagrant -FullAccess @("IIS_IUSRS","IUSR", "Administrators")

Remove-Website 'Default Web Site'
New-Website -Name MyWebsite -Port 80 -HostHeader * -PhysicalPath \\localhost\vagrant