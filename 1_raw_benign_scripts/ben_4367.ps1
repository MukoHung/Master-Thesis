function Update-VMHardware
{
    <#
    .SYNOPSIS
        A script to programmatically upgrade the vm hardware level
    .DESCRIPTION
        The script uses powercli to programmatically schedule the hardware upgrade to the specified hardware level.
        It presumes that the user is already connected to the vSphere server hosting the vm's to upgprade, and it automatically creates a snapshot of the VM before scheduling the upgrade.

    .EXAMPLE
        PS C:\> Update-VMHardware -ComputerName Demoserver1 -HardwareVersion 13 -UpgradePolicy always
        #
        VM           Name                                Description
        --           ----                                -----------

        Demoserver1  20190904_094407__PreHardwareUpgrade [20190904_090746] Taken before upgrading hardware
    .PARAMETER ComputerName
        These are the names of the VM's to upgrade

    .PARAMETER HardwareVersion
        This is the hardware level to upgrade the VM's.  The script does check the vSphere version and based on that, it will not allow the user to 
        set the VMware to a higher level than the vSphere allows.  The script is currently coded for up to vSphere 6.7 (Hardware version 14).
        If the vSphere version is outside of the known range (3 - 6.7) then the MaxHardware version is specified as '9999'. 

    .PARAMETER UpgradePolicy
        This is the VMware hardware upgrade policy.  It has 3 options:
        never - don't actually upgrade the hardware.  
        onSoftPowerOff - performs the upgrade when the VM is gracefully shutdown.
        always - Always do the hardware upgrade when possible

        The script defaults to 'always'

    .PARAMETER SnapShotPrefixName
        The is the first few characters attached to the snapshot that gets automatically created. 
        It defaults to a datetime stamp: 'yyyyMMdd_hhmmss_'
        yyyy = 4 digit year
        MM - 2 digit month
        dd - 2 digit date of month
        hh - 2 digit hour (24 hour format)
        mm - 2 digit minutes
        ss - 2 digit seconds

    .PARAMETER Force
        This switch overrides the restrictions on downgrading hardware, or running the hardware reconfigure if the VM is already at the specified level.

    .INPUTS
        [system.string]
        [int]
    .OUTPUTS
        none
    .NOTES
        General notes
    #>
    [cmdletbinding()]
    param(
        [parameter(Mandatory = $true, HelpMessage = 'The machine(s) to update hardware on', ValueFromPipelineByPropertyName = $true)]
        [string[]]$ComputerName,
   
        [parameter(Mandatory = $true, HelpMessage = 'The desired hardware version', ValueFromPipelineByPropertyName = $true)]
        [int]$HardwareVersion,

        [parameter(ValueFromPipelineByPropertyName = $true)]
        [ValidateSet('never', 'onSoftPowerOff', 'always')]
        [string]$UpgradePolicy = 'always',
    
        [parameter(ValueFromPipelineByPropertyName = $true)]
        [string]$SnapShotPrefixName = ([datetime]::Now.ToString('yyyyMMdd_hhmmss_')),
    
        [parameter(ValueFromPipelineByPropertyName = $true)]
        [switch]$Force
    )

    Import-Module -Name VMWare.vim 
    Import-Module -Name VMware.vimautomation.core

    if ($global:DefaultVIServer)
    {
        $VIServerVersion = ($global:DefaultVIServer | Select-Object -ExpandProperty Version).split('.')
        $MajorVersion = $VIServerVersion[0]
        $MinorVersion = $VIServerVersion[1]
  
        switch ($MajorVersion)
        {
            '2' 
            { 
                $MaxHWVersion = 3
                break 
            }
    
            '3' 
            { 
                $MaxHWVersion = 4
                break 
            }
    
            '4' 
            { 
                $MaxHWVersion = 7
                break 
            }
    
            '5' 
            { 
                switch ($MinorVersion)
                {
                    '0' 
                    { 
                        $MaxHWVersion = 8
                        break 
                    }
            
                    '1' 
                    { 
                        $MaxHWVersion = 9
                        break 
                    }
            
                    '5' 
                    { 
                        $MaxHWVersion = 10
                        break 
                    }
                }
            }
    
            '6'
            {
                switch ($MinorVersion)
                {
                    '0' 
                    { 
                        $MaxHWVersion = 11
                        break 
                    }
            
                    '5' 
                    { 
                        $MaxHWVersion = 13
                        break 
                    }
            
                    '7' 
                    { 
                        $MaxHWVersion = 14
                        break 
                    }
            
                }
            }
            default
            {
                Write-Warning -Message 'Unknown version of vSphere; setting the maximum hardware version to 9999' 
                $MaxHWVersion = 9999
            }   
        }
    }
    else 
    {
        throw 'This script requires you to be connected to a VIServer through PowerCLI, and looks for $global:DefaultVIServer'
    }

    if ($HardwareVersion -ge 3 -and $HardwareVersion -le $MaxHWVersion)
    {
        Write-Verbose -Message ('Hardware version is {0}; this is in the maximum range' -f $HardwareVersion)
        $VersionKey = 'vmx-{0}' -f $HardwareVersion
    }
    else 
    {
        throw ('The specified hardware version ({0}) is outside the acceptable range (3 - {1}); unable to continue' -f $HardwareVersion, $MaxHWVersion)
    }

    $VMSpec = New-Object -TypeName VMware.Vim.VirtualMachineConfigSpec
    $VMSpec.ScheduledHardwareUpgradeInfo = New-Object -TypeName VMware.Vim.ScheduledHardwareUpgradeInfo
    $VMSpec.ScheduledHardwareUpgradeInfo.UpgradePolicy = $UpgradePolicy
    $VMSpec.ScheduledHardwareUpgradeInfo.VersionKey = $VersionKey

    foreach ($Server in $ComputerName)
    {
        $vm = Get-VM -Name $Server
        $ExistingHWVersion = [int]($vm.HardwareVersion.Split('-')[1])
        
        $SnapshotProperties = @{
            Name = ('{0}_PreHardwareUpgrade' -f $SnapShotPrefixName)
            Description = ('[{0}] Taken before upgrading hardware' -f [datetime]::Now.ToString('yyyyMMdd_hhmmss'))
            VM = $vm 
            Confirm = $false 
        }
        $SnapshotProperties | Select-Object -Property VM,Name,Description 
        New-Snapshot @SnapshotProperties

        if ($ExistingHWVersion -lt $HardwareVersion)
        {
            Write-Verbose -Message ('Existing Hardware version ({0}) is less than the desired Hardware version ({1}); upgrading ({2})' -f $ExistingHWVersion, $HardwareVersion, $Server)
            $vm.ExtensionData.ReconfigVM_Task($VMSpec)
        }
        elseif ($ExistingHWVersion -gt $HardwareVersion -and $Force)
        {
            Write-Warning -Message ('Existing hardware version ({0}) is greater than the desired hardware version ({1}) and -Force HAS BEEN specified; downgrading ({2})' -f $ExistingHWVersion, $HardwareVersion, $Server )
            $vm.ExtensionData.ReconfigVM_Task($VMSpec)
        }
        elseif ($ExistingHWVersion -eq $HardwareVersion) 
        {
            Write-Verbose -Message ('Existing hardware version is the same as the desired hardware version ({0}); skipping this computer ({1})' -f $HardwareVersion, $Server)
        }
        elseif ($ExistingHWVersion -gt $HardwareVersion -and -not $Force)
        {
            Write-Warning -Message ('Existing hardware version ({0}) is greater than the desired hardware version ({1}) and -Force has not been specified, skipping this computer ({2})' -f $ExistingHWVersion, $HardwareVersion, $Server )
        }
    }
}
