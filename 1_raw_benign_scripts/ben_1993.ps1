[CmdletBinding(SupportsShouldProcess)]
param (
    # Path to the script with "requires module" statements
    [Parameter(Mandatory)]
    [string]
    $Path
)

 $dependencies = Get-ChildItem $Path | 
    Select-String -Pattern "^#Requires -Module (@{ ModuleName = '[^']+'; RequiredVersion = '[0-9.]+';? })" |
    Foreach-Object { [pscustomobject]($_.Matches.Groups[1].Value | Invoke-Expression) }
    
foreach ($dep in $dependencies) {

    $installedModule = Get-Module $dep.ModuleName -ListAvailable
    if ($null -eq $installedModule -or $installedModule.Version.toString() -ne $dep.RequiredVersion) {
        
        if ($PSCmdlet.ShouldProcess("$($dep.ModuleName) => $($dep.RequiredVersion)", "Install-Module")) {
            Write-Host "Installing $($dep.ModuleName) => $($dep.RequiredVersion)"
            Install-Module -Name $dep.ModuleName -RequiredVersion $dep.RequiredVersion -Scope CurrentUser -AllowClobber
        }
    }
    else {
        Write-Host "Already installed: $($dep.ModuleName) => $($dep.RequiredVersion)"
    }
}
