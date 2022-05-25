<#
.Synopsis
This function will set the proxy settings provided as input to the cmdlet.
.Description
This function will set the proxy server.
.Parameter ProxyServer
This parameter is set as the proxy for the system.
Data from. This parameter is Mandatory
.Example
Set-Proxy -proxy "127.0.0.1:7080"
#>

Function Set-Proxy
{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
        [String[]]$Proxy
    )

    Begin
    {
        $regKey="HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings"
    }
    
    Process
    {
        Set-ItemProperty -path $regKey ProxyEnable -value 1
        Set-ItemProperty -path $regKey ProxyServer -value $proxy
        Set-ItemProperty -Path $regKey ProxyOverride -value '<local>'

        [Environment]::SetEnvironmentVariable('http_proxy', $proxy, 'User')
        [Environment]::SetEnvironmentVariable('https_proxy', $proxy, 'User')
    } 
    
    End
    {
        Write-Output "Proxy is now enabled"
        Write-Output "Proxy Server : $proxy"
    }
}


<#
.Synopsis
This function will clear the proxy settings provided as input to the cmdlet.
.Description
This function will clear the proxy server.
.Example
Clear-Proxy
#>

Function Clear-Proxy
{
    Begin
    {
        $regKey="HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings"
    }
    
    Process
    {
        Set-ItemProperty -path $regKey ProxyEnable -value 0
        Set-ItemProperty -path $regKey ProxyServer -value ''
        Set-ItemProperty -Path $regKey ProxyOverride -value ''

        [Environment]::SetEnvironmentVariable('http_proxy', $null, 'User')
        [Environment]::SetEnvironmentVariable('https_proxy', $null, 'User')
    } 
    
    End
    {
        Write-Output "Proxy is now clean"
    }
}
