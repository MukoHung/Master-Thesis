<# 
    Created by Tony Sangha
    July 2017
    tonysangha.com
    version 0.1

    Modified by Shane White
    October 2017
    Version 1.0
         
####################################
macOS PowerCLI specific commands

Get-Module -ListAvailable PowerCLI* | Import-Module
Get-Module -ListAvailable PowerNSX* | Import-Module

Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false

#>



param( [string[]] $param)


$networkno = $param.Count -3
$networkno = $networkno /2


$log_path = "c:\scripts\"
$log_name = $param[1]  + ".bubble"
$log_file = $log_path + $log_name

if ((Test-Path $log_file)) {
Write-Output "That bubble exists"
throw "That bubble network exists"
}



#######################################
### Edit any parameters here only   ###
#######################################


if ($param[0] -eq "NSX-1") {
    write-output "Connecting to NSX Site 1"
    Connect-NsxServer -NsxServer vsnsxmgr01.vsnsx-1.local -Username "admin" -Password "VMware1!" -VIUserName "administrator@vsphere.local" -VIPassword "VMware1!"
    $nsx_manager_ip = '10.10.10.111'
    $transport_zone_name = "NSX-Site1"
    $datastore = "ReadyNAS_NFS_NSX"
    $edge_cluster = "NSX"
    $esg_uplink_ls = "Transit"
}


ElseIF ($param[0] -eq "NSX-2") {
    write-output "Connecting to NSX Site 2"
    Connect-NsxServer -NsxServer vsnsxmgr02.vsnsx-1.local -Username "admin" -Password "VMware1!" -VIUserName "administrator@vsphere.local" -VIPassword "VMware1!"
    $nsx_manager_ip = '10.10.20.101'
    $transport_zone_name = "NSX-Site-2"
    $datastore = "ReadyNAS_NFS"
    $edge_cluster = "Site-2"
    $esg_uplink_ls = "Transit"
}
ElseIF ($param[0] -eq "NSX-3")  {
    write-output "Connecting to NSX Site 3"
    Connect-NsxServer -NsxServer vsnsxmgr00.vsphere.local -Username "admin" -Password "VMware1!" -VIUserName "administrator@vsphere.local" -VIPassword "VMware1!"
    $nsx_manager_ip = '10.10.30.101'
    $transport_zone_name = "vSoft"
    $datastore = "ReadyNAS_NFS"
    $edge_cluster = "vSoft"
    $esg_uplink_ls = "Transit"
}


# DLR, ESG and Sec & Grp names, will be created randomly if not changed here
$bubble_name = $param[1]
$dlr_name = "DLR-" + $bubble_name.toString()
$esg_name = "ESG-" + $bubble_name.toString()
$sg_name = "SG-BUBBLE-" + $bubble_name.toString()
$sec_name = "BUBBLE-NETWORK-" + $bubble_name.toString()

<# Logical Switch and IP Addressing for the Edge Services Gateway Bubble Router
   Logical Switch, IP and Next Hop IP's are required for Uplink and Internal 
   Interfaces. Uplink logical switch should already be available in NSX-v and 
   will not be dynamically created by this script #>

$esg_uplink_ls = "Transit"
$esg_uplink_ip = $param[2]
$esg_uplink_next_hop = "192.168.1.1"
$esg_internal_ip = "192.168.0.254/24"



<# Logical Switch and IP Information for Internal networks and for HA/Uplink 
  interfaces on the DLR. Variable $logical_switch_name_ip can be appended to
  with interfaces and IP Addresses as required #>

$dlr_uplink_transit = 'ls_transit ' + $bubble_name
$dlr_uplink_ls_ip = @{$dlr_uplink_transit ='192.168.0.1/24'}
$dlr_ha_mgmt_ls = "ls_ha_mgmt " + $bubble_name

$ls_1 = "ls_" + $param[3] + "-" + $bubble_name
$logical_switch_name_ip= @{$ls_1 =$param[4]}
$networkno--

$paramcount = 5

while ($networkno -ne 0) {
#write-output "I'm in the loop"
$ls_1 = "ls_"+$param[$paramcount] + "-" +$bubble_name
$logical_switch_name_ip.add($ls_1, $param[$paramcount+1])
$paramcount = $paramcount +2

$networkno--

}


# Use a Summary route if possible for logical switches created above or append
$esg_to_dlr_static_routes=@('192.168.0.0/21','10.10.10.0/24')



####################################
### DO NOT EDIT BEYOND THIS LINE ###
####################################

write-host -ForegroundColor Magenta `
"  ____        _     _     _        _   _      _                      _    `
 |  _ \      | |   | |   | |      | \ | |    | |                    | |    `
 | |_) |_   _| |__ | |__ | | ___  |  \| | ___| |___      _____  _ __| | __ `
 |  _ <| | | | '_ \| '_ \| |/ _ \ | . ` |/ _ \ __\ \ /\ / / _ \| '__| |/ / `
 | |_) | |_| | |_) | |_) | |  __/ | |\  |  __/ |_ \ V  V / (_) | |  |   <  `
 |____/ \__,_|_.__/|_.__/|_|\___| |_| \_|\___|\__| \_/\_/ \___/|_|  |_|\_\ `
                                                                           `
                                                                          "
write-host -ForegroundColor DarkYellow "Starting Execution of PowerNSX Script"

#######################################
### Create Local Logical Switches   ###
#######################################

# Get and Store Transport Zone object in a variable
$tz = get-nsxtransportzone $transport_zone_name

<# Create NSX Logical switches in the designated transport zone, by looping
   though the $logical_switch_name_ip hash table #>

foreach($item in $logical_switch_name_ip.keys){

    $ls = new-nsxlogicalswitch -name $item -transportzone $tz `
        -Description "Created with PowerNSX"
    write-host -ForegroundColor cyan "Created Switch:" $ls.name
}

# Create Logical Switch for DLR HA/MGMT network and Bubble Internal Transit

$ls = new-nsxlogicalswitch -name $dlr_uplink_ls_ip.keys -transportzone $tz
write-host -ForegroundColor cyan "Created Switch:" $ls.name

$ls = new-nsxlogicalswitch -name $dlr_ha_mgmt_ls -transportzone $tz
write-host -ForegroundColor cyan "Created Switch:" $ls.name

#######################################
### Create Distributed Logical Router #
#######################################

# Create empty hash table to store internal interface specs for the DLR
$internal_int_specs = New-Object System.Collections.ArrayList

<# Loop over the logical_switch_name_ip hashtable and add interface specs
   to empty specs table created above #>
   
foreach($item in $logical_switch_name_ip.GetEnumerator()){
  
  $ip_address = $item.Value.split('/') 

  $internal = New-NsxLogicalRouterinterfacespec -Name $item.Name `
            -Type internal `
            -ConnectedTo (Get-NsxLogicalSwitch -TransportZone $tz `
            -name $item.Name) `
            -PrimaryAddress $ip_address[0] `
            -SubnetPrefixLength $ip_address[1] 

  $x = $internal_int_specs.Add($internal)
}

# Create Interface Specification for Uplink Interface
$dlr_uplink_int_spec = New-NsxLogicalRouterinterfacespec -Name `
            $dlr_uplink_ls_ip.keys -Type uplink `
            -ConnectedTo (Get-NsxLogicalSwitch -TransportZone $tz `
            -name $dlr_uplink_ls_ip.keys) `
            -PrimaryAddress ($dlr_uplink_ls_ip.values.split('/')[0]) `
            -SubnetPrefixLength ($dlr_uplink_ls_ip.values.split('/')[1])

<# Create Distributed Logical Router, attach interfaces and configure static
   routes.#>

write-host -ForegroundColor cyan "Creating Logical Router (DLR):" $dlr_name

$dlr_rtr = New-NsxLogicalRouter -Name $dlr_name -ManagementPortGroup `
           (Get-NsxLogicalSwitch $dlr_ha_mgmt_ls)  `
           -Interface $dlr_uplink_int_spec `
           -Cluster (Get-Cluster $edge_cluster) -Datastore `
           (get-datastore $datastore)

# Add Internal interfaces to newly created Distributed Logical Router

write-host -ForegroundColor yellow "Adding Logical Switches to:" $dlr_name

foreach($item in $internal_int_specs){

  write-host -ForegroundColor cyan $item.Name "LS added to:" $dlr_name

   $x = New-NsxLogicalRouterInterface -LogicalRouter `
       (get-nsxlogicalrouter $dlr_name) `
        -ConnectedTo (Get-NsxLogicalSwitch $item.Name) `
        -Name $item.Name -Type "Internal" `
        -PrimaryAddress $item.addressGroups.addressGroup.primaryAddress `
        -SubnetPrefixLength $item.addressGroups.addressGroup.subnetPrefixLength   
}

# Add static default route to ESG Internal Interface
$route = New-NsxLogicalRouterStaticRoute -LogicalRouter `
          (get-nsxlogicalrouter $dlr_name | Get-NsxLogicalRouterRouting) `
          -NextHop $esg_internal_ip.split('/')[0] `
          -Network '0.0.0.0/0' -confirm:$false

write-host -ForegroundColor yellow $route.network "route created on:" `
             $dlr_name

#######################################
### Edge Services Gateway           ###
#######################################

$esg_uplink_int_spec = New-NsxEdgeInterfaceSpec -Name $esg_uplink_ls `
                      -Type Uplink `
                      -ConnectedTo (Get-NsxLogicalSwitch $esg_uplink_ls) `
                      -PrimaryAddress $esg_uplink_ip.split('/')[0] `
                      -SubnetPrefixLength $esg_uplink_ip.split('/')[1] -Index 0

$esg_internalint_spec = New-NsxEdgeInterfaceSpec -Name $dlr_uplink_ls_ip.keys `
                     -Type Internal `
                     -ConnectedTo (Get-NsxLogicalSwitch $dlr_uplink_ls_ip.keys) `
                     -PrimaryAddress $esg_internal_ip.split('/')[0] `
                     -SubnetPrefixLength $esg_internal_ip.split('/')[1] -Index 1

write-host -ForegroundColor cyan "Creating Edge Services Router:" $esg_name

$esg_rtr = New-NsxEdge -Name $esg_name -Datastore (get-datastore $datastore) `
            -cluster (get-cluster $edge_cluster) -Username admin `
            -Password VMware1!VMware1! -FormFactor compact -AutoGenerateRules `
            -FwEnabled -Interface $esg_uplink_int_spec,$esg_internalint_spec

# Create static routes back to the DLR
write-host -ForegroundColor cyan "Creating Routes on ESG:" $esg_name

foreach($item in $esg_to_dlr_static_routes){

    $x = Get-NsxEdge $esg_name | Get-NsxEdgeRouting | New-NsxEdgeStaticRoute `
      -Network $item -NextHop $dlr_uplink_ls_ip.Values.split('/')[0] `
      -confirm:$false

    write-host -ForegroundColor yellow $item "route created on:" `
      $esg_name
  }

# Create Default Route 0/0 to Perimeter Edge Services Gateway
$route = Get-NsxEdge $esg_name | Get-NsxEdgeRouting | New-NsxEdgeStaticRoute `
      -Network '0.0.0.0/0' -NextHop $esg_uplink_next_hop -confirm:$false

write-host -ForegroundColor yellow $route.network "route created on:" `
             $esg_name

#######################################
###       DFW Firewall Rules        ###
#######################################

# Create Security Group containing all logical switches
write-host -ForegroundColor cyan "Creating Security Group"

$sg = New-NsxSecurityGroup -name $sg_name

write-host -ForegroundColor yellow "Security Group " $sg.name " created"

foreach($item in $internal_int_specs){

  Add-NsxSecurityGroupMember (Get-NsxSecurityGroup $sg_name) `
                     -Member (Get-NsxLogicalSwitch $item.Name)      
}

# Create new NSX Firewall Section
write-host -ForegroundColor cyan "Creating Firewall Section" $sec_name

$section = New-NsxFirewallSection -name $sec_name

write-host -ForegroundColor cyan "Creating Rules in Section" $sec_name

$rule = Get-NsxFirewallSection $section.name | New-NsxFirewallRule -Name `
                        "$sg_name -> any - deny" -Source $sg `
                        -Action 'deny'

write-host -ForegroundColor yellow "Rule ID" $rule.id "created"

$rule = Get-NsxFirewallSection $section.name | New-NsxFirewallRule  -Name `
                        "any -> $sg_name - deny" `
                        -Destination $sg `
                        -Action 'deny'

write-host -ForegroundColor yellow "Rule ID" $rule.id "created"

$rule = Get-NsxFirewallSection $section.name | New-NsxFirewallRule -Name `
                        "$sg_name -> $sg_name - allow" -Source $sg `
                        -Destination $sg `
                        -Action 'allow'

write-host -ForegroundColor yellow "Rule ID" $rule.id "created"

Disconnect-NsxServer

$logical_switch_name_ip.add($dlr_name, "DLR")
$logical_switch_name_ip.add($esg_name, "ESG")
$logical_switch_name_ip.add($sg_name,"Security_group")
$logical_switch_name_ip.add($Sec_name,"Firewall_rules")
$logical_switch_name_ip.add($dlr_ha_mgmt_ls,"LS")
$logical_switch_name_ip.add($dlr_uplink_transit,"LS")

#$log_name = $bubble_name.ToString() + '.bubble'
$log_path = "c:\scripts\"
#$log_name = $Bubble_name + ".bubble"
$log_file = $log_path + $log_name
$logical_switch_name_ip | out-file $log_file
$bubble_name | Add-Content $log_file
$param[0] | add-content $log_file


write-host -ForegroundColor yellow "Settings saved to file" $log_name 
