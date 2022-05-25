<#
    .SYNOPSIS 
     Creates a number of NTFS Volume in AWS, attaches to an instance, formats, brings them online.
	.EXAMPLE
     _createVolumes.ps1 -zone ap-southeast-2a -type standard -instance i-12345678 -allocation 64
     This command creates volumes for instance i-12345678.
	 The Disks will be 64KB NTFS allocation.
#>

#No params supplied

#Input Parameters
param(
	[parameter(mandatory=$true)][string]$zone, #AWS Availability Zone
	[parameter(mandatory=$true)][string]$type, #EBS volume type
	[parameter(mandatory=$false)][int]$iops, #IOPS for iops types
	[parameter(mandatory=$true)][int]$allocation, #Disk allocation size
	[parameter(mandatory=$true)][string]$instance, #For Instance to attach to
	[parameter(mandatory=$true)][string]$name, #For tag name
	[parameter(mandatory=$false)][string]$owner, #For tag owner
	[parameter(mandatory=$false)][string]$stream, #For tag stream
	[parameter(mandatory=$false)][string]$project, #For tag project
	[parameter(mandatory=$false)][string]$environmentName #For tag environment name
)

# AWS-provided PowerShell module
if(Get-Module AWSPowerShell){
	Remove-Module AWSPowerShell
}
Import-Module AWSPowerShell -ErrorAction Stop #Required

#lowercase type
$type = $type.ToLower()

#validate disk type
If ("standard", "gp2", "iops" -NotContains $type) { 
            Throw "$($type) is not a valid type for Volumes! See http://docs.aws.amazon.com/sdkfornet/latest/apidocs/items/TEC2_VolumeType_NET3_5.html" 
}
#validate disk type
If ($type -eq "iops") { 
            if ($iops -eq $null) {
				Throw "-iops is required when -type iops is provided. The vvalue is the number of I/O operations per second (IOPS) to provision for the volume."
			}
}

#validate allocation size
If (4, 8, 16, 32, 64 -NotContains $allocation) { 
            Throw "$($allocation) is not a valid NTFS cluster size! See http://support.microsoft.com/kb/140365" 
}

#Validate Zone
$validzone = $false
$a = Get-EC2Region
foreach ($region in $a) {
	try {
		$b = Get-EC2AvailabilityZone -Region $region.RegionName
		foreach ($available in $b) {
			if ($available.ZoneName -eq $zone) { $validzone = $true }
		}
	} catch {
		#ignore regions we dont have access to
	}
}
If (!$validzone) { 
	Throw "$($zone) is not a valid AWS EC2 availability zone."
}

#Validate Instance exists
try {
	$instanceCheck = Get-EC2Instance -Instance $instance
	if ($instanceCheck.Instances.State.Name -ne "Running") {
		Throw
	}
} catch {
	Throw "$($instance) is not a valid or running AWS EC2 instance."
}

#Bulk Tags
$newvoltags = @()

#mandatory param for tag
$t = New-Object Amazon.EC2.Model.Tag
$t.Key = 'Name'
$t.Value = $name
$newvoltags += $t

[bool]$owner | Out-Null
if ($owner) {
	$t = New-Object Amazon.EC2.Model.Tag
	$t.Key = 'Owner'
	$t.Value = $owner
	$newvoltags += $t
}

[bool]$stream | Out-Null
if ($stream) {
	$t = New-Object Amazon.EC2.Model.Tag
	$t.Key = 'Stream'
	$t.Value = $stream
	$newvoltags += $t
}

[bool]$project | Out-Null
if ($project) {
	$t = New-Object Amazon.EC2.Model.Tag
	$t.Key = 'Project'
	$t.Value = $project
	$newvoltags += $t
}

[bool]$environmentName | Out-Null
if ($environmentName) {
	$t = New-Object Amazon.EC2.Model.Tag
	$t.Key = 'Environment Name'
	$t.Value = $environmentName
	$newvoltags += $t
}

$newvoltags

#new SQL2014 volumes (size in GiB)
############################################################################################
$size = 1331
$device0 = "xvdg" #E
$size0 = $size * 0.5 #Equally divide disks for striping
$device1 = "xvdh" #E
$size1 = $size * 0.5 #Equally divide disks for striping
$thisvolume0 = New-EC2Volume -Size $size0 -VolumeType $type -AvailabilityZone $zone #create
$thisvolume1 = New-EC2Volume -Size $size1 -VolumeType $type -AvailabilityZone $zone #create
New-EC2Tag -Resources @( $thisvolume0.VolumeId, $thisvolume1.VolumeId ) -Tags $newvoltags #bulk tags
New-EC2Tag -Resources $thisvolume0.VolumeId -Tags @( @{ Key="Letter"; Value="E0" }, @{ Key="Device"; Value=$device0 } ) #tag with vol specifics #specific tags
New-EC2Tag -Resources $thisvolume1.VolumeId -Tags @( @{ Key="Letter"; Value="E1" }, @{ Key="Device"; Value=$device1 } ) #tag with vol specifics #specific tags
#wait
Start-Sleep -s 10
$attach0 = Add-EC2Volume -VolumeId $thisvolume0.VolumeId -InstanceId $instance -Device $device0 #attach
$attach1 = Add-EC2Volume -VolumeId $thisvolume1.VolumeId -InstanceId $instance -Device $device1 #attach
#wait
Start-Sleep -s 10
& .\createStripedVolume.ps1 -letter F -allocation 8 -label MyDisk
#############################################################################################
$size = 10
$device = "xvdi" #F
$thisvolume = New-EC2Volume -Size $size -VolumeType $type -AvailabilityZone $zone #create
New-EC2Tag -Resources $thisvolume.VolumeId -Tags $newvoltags #bulk tags
New-EC2Tag -Resources $thisvolume.VolumeId -Tags @( @{ Key="Letter"; Value="F" }, @{ Key="Device"; Value=$device } ) #tag with vol specifics #specific tags
#wait
Start-Sleep -s 10
$attach = Add-EC2Volume -VolumeId $thisvolume.VolumeId -InstanceId $instance -Device $device #attach
#wait
Start-Sleep -s 10
& .\createSingleVolume.ps1 -letter G -allocation 16 -label "My New Disk"
#############################################################################################
$size = 50
$device = "xvdj" #G
$thisvolume = New-EC2Volume -Size $size -VolumeType $type -AvailabilityZone $zone #create
New-EC2Tag -Resources $thisvolume.VolumeId -Tags $newvoltags #bulk tags
New-EC2Tag -Resources $thisvolume.VolumeId -Tags @( @{ Key="Letter"; Value="G" }, @{ Key="Device"; Value=$device } ) #tag with vol specifics #specific tags
#wait
Start-Sleep -s 10
$attach = Add-EC2Volume -VolumeId $thisvolume.VolumeId -InstanceId $instance -Device $device #attach
#wait
Start-Sleep -s 10
& .\createSingleVolume.ps1 -letter G -allocation 16 -label "My New Disk"
#############################################################################################
$size = 10
$device = "xvdk" #H
$thisvolume = New-EC2Volume -Size $size -VolumeType $type -AvailabilityZone $zone #create
New-EC2Tag -Resources $thisvolume.VolumeId -Tags $newvoltags #bulk tags
New-EC2Tag -Resources $thisvolume.VolumeId -Tags @( @{ Key="Letter"; Value="H" }, @{ Key="Device"; Value=$device } ) #tag with vol specifics #specific tags
#wait
Start-Sleep -s 10
$attach = Add-EC2Volume -VolumeId $thisvolume.VolumeId -InstanceId $instance -Device $device #attach
#wait
Start-Sleep -s 10
& .\createSingleVolume.ps1 -letter G -allocation 16 -label "My New Disk"
#############################################################################################
$size = 2870
$device0 = "xvdl" #J
$size0 = $size * (1/3) #Equally divide disks for striping
$device1 = "xvdm" #J
$size1 = $size * (1/3)
$device2 = "xvdn" #J
$size2 = $size * (1/3)
$thisvolume0 = New-EC2Volume -Size $size0 -VolumeType $type -AvailabilityZone $zone #create
$thisvolume1 = New-EC2Volume -Size $size1 -VolumeType $type -AvailabilityZone $zone #create
$thisvolume2 = New-EC2Volume -Size $size2 -VolumeType $type -AvailabilityZone $zone #create
New-EC2Tag -Resources @( $thisvolume0.VolumeId, $thisvolume1.VolumeId, $thisvolume2.VolumeId, $thisvolume3.VolumeId ) -Tags $newvoltags #bulk tags
New-EC2Tag -Resources $thisvolume0.VolumeId -Tags @( @{ Key="Letter"; Value="J0" }, @{ Key="Device"; Value=$device0 } ) #tag with vol specifics #specific tags
New-EC2Tag -Resources $thisvolume1.VolumeId -Tags @( @{ Key="Letter"; Value="J1" }, @{ Key="Device"; Value=$device1 } ) #tag with vol specifics #specific tags
New-EC2Tag -Resources $thisvolume2.VolumeId -Tags @( @{ Key="Letter"; Value="J2" }, @{ Key="Device"; Value=$device2 } ) #tag with vol specifics #specific tags
#wait
Start-Sleep -s 10
$attach0 = Add-EC2Volume -VolumeId $thisvolume0.VolumeId -InstanceId $instance -Device $device0 #attach
$attach1 = Add-EC2Volume -VolumeId $thisvolume1.VolumeId -InstanceId $instance -Device $device1 #attach
$attach2 = Add-EC2Volume -VolumeId $thisvolume2.VolumeId -InstanceId $instance -Device $device2 #attach
#############################################################################################
$size = 10
$device = "xvdo" #K
$thisvolume = New-EC2Volume -Size $size -VolumeType $type -AvailabilityZone $zone #create
New-EC2Tag -Resources $thisvolume.VolumeId -Tags $newvoltags #bulk tags
New-EC2Tag -Resources $thisvolume.VolumeId -Tags @( @{ Key="Letter"; Value="K" }, @{ Key="Device"; Value=$device } ) #tag with vol specifics #specific tags
#wait
Start-Sleep -s 10
$attach = Add-EC2Volume -VolumeId $thisvolume.VolumeId -InstanceId $instance -Device $device #attach
#wait
Start-Sleep -s 10
& .\createSingleVolume.ps1 -letter G -allocation 16 -label "My New Disk"
#############################################################################################
$size = 466
$device = "xvdp" #M
$thisvolume = New-EC2Volume -Size $size -VolumeType $type -AvailabilityZone $zone #create
New-EC2Tag -Resources $thisvolume.VolumeId -Tags $newvoltags #bulk tags
New-EC2Tag -Resources $thisvolume.VolumeId -Tags @( @{ Key="Letter"; Value="M" }, @{ Key="Device"; Value=$device } ) #tag with vol specifics #specific tags
#wait
Start-Sleep -s 10
$attach = Add-EC2Volume -VolumeId $thisvolume.VolumeId -InstanceId $instance -Device $device #attach
#wait
Start-Sleep -s 10
& .\createSingleVolume.ps1 -letter G -allocation 16 -label "My New Disk"
#############################################################################################
$size = 60
$device = "xvdq" #N
$thisvolume = New-EC2Volume -Size $size -VolumeType $type -AvailabilityZone $zone #create
New-EC2Tag -Resources $thisvolume.VolumeId -Tags $newvoltags #bulk tags
New-EC2Tag -Resources $thisvolume.VolumeId -Tags @( @{ Key="Letter"; Value="N" }, @{ Key="Device"; Value=$device } ) #tag with vol specifics #specific tags
#wait
Start-Sleep -s 10
$attach = Add-EC2Volume -VolumeId $thisvolume.VolumeId -InstanceId $instance -Device $device #attach
#wait
Start-Sleep -s 10
& .\createSingleVolume.ps1 -letter G -allocation 16 -label "My New Disk"
