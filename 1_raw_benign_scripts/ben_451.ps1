#Requires -RunAsAdministrator

$FirewallRuleName = "WFBlock"

While($true){
    $Rule = netsh advfirewall firewall show rule name="$FirewallRuleName"
    if ($Rule[1] -eq "No rules match the specified criteria.") {
        netsh advfirewall firewall add rule name="$FirewallRuleName" dir=out protocol=UDP localport=4950-5000 action=block
        $Rule = netsh advfirewall firewall show rule name="$FirewallRuleName"
    }
    $Enabled = $Rule[3] -Match "Enabled:\s*Yes"
    $EnabledString = "disabled"
    if ($Enabled) {
        $EnabledString = "enabled"
    }
    Read-Host "Currently the firewall rule is [$EnabledString], continue?"
    if($Enabled){
        netsh advfirewall firewall set rule name="$FirewallRuleName" new enable=no > $null
        Write-Host "The rule is now disabled."
        Write-Host ""
    }
    else{
        netsh advfirewall firewall set rule name="$FirewallRuleName" new enable=yes > $null
        Write-Host "The rule is now enabled."
        Write-Host ""
    }
}