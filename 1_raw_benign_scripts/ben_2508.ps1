function Import-NAVBCAdminModule
{
    [CmdletBinding()]
    Param (
        [parameter(Mandatory = $true)]
        [int] $NavVersion
    )

    Process
    {        
        $AdminModule = ""
        if ($NavVersion -ge 130) {            
            $AdminModule = "C:\Program Files\Microsoft Dynamics 365 Business Central\$($NavVersion)\Service\NavAdminTool.ps1"
        }
        else {
            $AdminModule = "C:\Program Files\Microsoft Dynamics NAV\$($NavVersion)\Service\NavAdminTool.ps1"
        }

        if (Test-Path -Path $AdminModule){
            Import-Module $AdminModule    
        }else{
            Write-Error "Path can't be found $($AdminModule)"         
        }        
    }    
}

Export-ModuleMember -Function Import-NAVBCAdminModule