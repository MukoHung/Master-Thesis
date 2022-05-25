function Get-CSharpProcess {
    $proclist = Get-Process
    foreach($proc in $proclist) {
        foreach($mod in $proc.Modules)
        {
            if($mod.ModuleName -imatch "mscoree")
            {
                Write-Output(".NET Found in:`t" + $proc.Name)
            }
        }
    }
}