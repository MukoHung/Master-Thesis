Param( 
    [Parameter(Mandatory = $true)] 
    [string] $ResourceGroupName, 
    [Parameter(Mandatory = $true)] 
    [string] $AppServiceName, 
    [Parameter(Mandatory = $true)] 
    [string] $SubscriptionId, 
    [Parameter(Mandatory = $true)] 
    [string] $RulePriority
)

$ErrorActionPreference = "Stop"

$AvailabilityTestIpsFile = Get-Content "$PSScriptRoot/AvailabilityTestIps.txt"
$AvailabilityTestIpsLines = $AvailabilityTestIpsFile.Split([Environment]::NewLine)

$IsHeader = $True
$CurrentGroup = $Null;
$NewIpRestrictions = @();
ForEach($Line in $AvailabilityTestIpsLines){
    if($IsHeader){
        $CurrentGroup = $Line;
        $IsHeader = $False
        continue
    }

    if([System.String]::IsNullOrEmpty($Line)){
        $IsHeader = $True #next line will be header
        continue
    }

    $Ip = $Null
    if($Line.Contains("/")){
        $Ip = $Line;
    }else{
        $Ip = "$Line/32";
    }

    $NewIpRestrictions += @{
        ipAddress = $Ip; 
        action = "Allow";
        priority = $RulePriority;
        name = "Av IP $CurrentGroup";
        description = "Availability Test IP $CurrentGroup";
        tag = "Default";
    }
}

& "$PSScriptRoot\AddRestrictedIPAzureAppService.ps1" -ResourceGroupName $ResourceGroupName -AppServiceName $AppServiceName -SubscriptionId $SubscriptionId -NewIpRules $NewIpRestrictions