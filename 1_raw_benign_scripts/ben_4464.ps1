# Editing a virtual machine file

# This PowerShell code takes an unregistered VMCX file
# It change the VM Name, disables Dynamic Memory, and sets the memory to 2GB
# It then saves the changed virtual machine configuration to a new path

# Parameters that will be changed
$VMConfigurationToEdit = "D:\VMs\Virtual Machines\3F99446F-1D9A-4010-8C8B-4E554E845181.vmcx"
$pathToSaveNewConfigTo = "D:\"
$newVMName= "NewVMName" 
$ammountOfMemory = 2048
$memoryWeight = 100

#Retrieve the virtual system management service 
$VSMS = Get-WmiObject -Namespace root\virtualization\v2 -Class Msvm_VirtualSystemManagementService 

# Import the VM, referencing the VM configuration
# Second parameter is the snapshot folder - but we are not editing snapshots so set it to null
# Third parameter says whether to generate a new VM ID or not
$importResult = $VSMS.ImportSystemDefinition($VMConfigurationToEdit, $null, $true)

ProcessResult $importResult "Virtual machine configuration loaded into memory." `
                            "Failed to load virtual machine configuration into memory."

#Retrieve the object referencing the planned VM (in memory VM) 
$plannedVM = [WMI]$importResult.ImportedSystem

#Retrieve the setting data for the planned VM 
$PVSD = ($plannedVM.GetRelated("Msvm_VirtualSystemSettingData", ` 
      "Msvm_SettingsDefineState", ` 
      $null, ` 
      $null, ` 
      "SettingData", ` 
      "ManagedElement", ` 
      $false, $null) | % {$_}) 

#Modify the name of the VM 
$PVSD.ElementName = $newVMName 
$nameChangeResult = $VSMS.ModifySystemSettings($PVSD.GetText(2))
ProcessResult $nameChangeResult "VM name has been updated." "Failed to update VM name."

#Modify the memory setting of the VM
$MemSetting = $PVSD.getRelated("Msvm_MemorySettingData") | select -first 1
$MemSetting.DynamicMemoryEnabled = 0
$MemSetting.Reservation = $AmmountOfMemory
$MemSetting.VirtualQuantity = $AmmountOfMemory
$MemSetting.Limit = $AmmountOfMemory
$MemSetting.Weight = $MemoryWeight

$memoryChangeResult = $VSMS.ModifyResourceSettings($MemSetting.GetText(1))
ProcessResult $memoryChangeResult "Memory settings have been updated." "Failed to update memory settings."

# Edit the Msvm_VirtualSystemExportSettingData to make sure we export only the VM configuration
$VMExportSD = ($plannedVM.GetRelated("Msvm_VirtualSystemExportSettingData",`
                                     "Msvm_SystemExportSettingData", `
                                     $null,$null, $null, $null, $false, $null)`
                                     | % {$_})
#CopySnapshotConfiguration - 1: ExportNoSnapshots - No snapshots will be exported with the VM.
$VMExportSD.CopySnapshotConfiguration = 1
#Indicates whether the VM runtime information will be copied when the VM is exported. (i.e. saved state)
$VMExportSD.CopyVmRuntimeInformation = $false
#Indicates whether the VM storage will be copied when the VM is exported.  (i.e. VHDs/VHDx files)
$VMExportSD.CopyVmStorage = $false
#Indicates whether a subdirectory with the name of the VM will be created when the VM is exported.
$VMExportSD.CreateVmExportSubdirectory = $True

#Export the edited virtual machine to a new file.
$exportResult = $VSMS.ExportSystemDefinition($plannedVM, $pathToSaveNewConfigTo, $VMExportSD.GetText(1))

ProcessResult $exportResult "Created new virtual machine confguration file." `
                            "Failed to create new virtual machine confguration file."

Write-Host "Virtual machine exported to $($pathToSaveNewConfigTo)$($newVMName)\Virtual Machines\$($plannedVM.Name).VMCX"

# This is my generic WMI job handler
Function ProcessResult($result, $successString, $failureString)
{
   #Return success if the return value is "0"
   if ($result.ReturnValue -eq 0)
      {write-host $successString} 
 
   #If the return value is not "0" or "4096" then the operation failed
   ElseIf ($result.ReturnValue -ne 4096)
      {write-host $failureString "  Error value:" $result.ReturnValue}
 
   Else
      {#Get the job object
      $job=[WMI]$result.job
 
      #Provide updates if the jobstate is "3" (starting) or "4" (running)
      while ($job.JobState -eq 3 -or $job.JobState -eq 4)
         {write-host $job.PercentComplete "% complete"
          start-sleep 1
 
          #Refresh the job object
          $job=[WMI]$result.job}
 
       #A jobstate of "7" means success
       if ($job.JobState -eq 7)
          {write-host $successString}
       Else
          {write-host $failureString
          write-host "ErrorCode:" $job.ErrorCode
          write-host "ErrorDescription:" $job.ErrorDescription}
       }
}