param(
[string]$type=$(Throw "Parameter Missing: -type ?barebone/webserver/database?"),
[string]$machinename=$(Throw "Parameter missing: -machinename <MACHINENAME>"),
[string]$size=$(Throw "Parameter missing: -size ?small/medium/large?"),
[string]$vlan=$(Throw "Parameter missing: -vlan ?TRAF-TRU/TRAF-TEST/TRAF-DMZ?"),
[string]$creator=$(Throw "Parameter missing: -creator <CREATOR>"),
[string]$ipaddress=$(Throw "Parameter missing: -ip <IPADDRESS>")
)

$vms = Get-VM



#set numCPU and memory according to size 
Switch ($size)
{
	'small' 	{$memory = 512; $numcpu = 1}
	'medium' 	{$memory = 2048; $numcpu = 1}
	'large'		{$memory = 4096; $numcpu = 2}
}

#Choose Pool Server based on type
Switch ($type)
{
	'barebone'	{$poolserverstr = 'bbpool'}
	'webserver'	{$poolserverstr = 'wspool'}
	'database'	{$poolserverstr = 'dbpool'}
}

#$poolserver = (Get-VM | ? {($_.name -match $poolserverstr) -and ((Get-Annotation -CustomAttribute Creator -Entity $_) -eq 'pool')})[0]
#$poolserverip = (Get-VMGuest $poolserver).ipaddress

$poolserver = Get-VM -Name 'TOMDEPLOYTEST2'
$poolserverip = 192.168.31.237

#Set annotation
echo Setting annotation 
Set-Annotation -Entity $poolserver -CustomAttribute 'Creator' -Value $creator

#Set name, RAM, NumCPUS
echo Setting name RAM NumCPUs
set-VM -VM $poolserver -Name $machinename -MemoryMB $memory -NumCpu $numcpu -Confirm:$false

#PrepOS
echo Prepping OS
Invoke-Expression "c:\bin\plink.exe deploy@$poolserverip 'sudo /opt/script/preparemachine.sh -i $ipaddress -n $machinename'"

#Set VLAN (assumes just 1 nic)
echo Setting VLAN
Get-NetworkAdapter -VM $machinename |   -NetworkName $vlan -Confirm:$false

#Reboot
echo Rebooting VM
Restart-VMGuest -VM $machinename

#svMotion 