# List Windows advanced power settings as MarkDown
# Use:
# this-script.ps1 | Out-File power.md
# Use powercfg to show hidden settings:
# powercfg -attributes <Group GUID> <GUID> -ATTRIB_HIDE
# example:
# powercfg -attributes 54533251-82be-4824-96c1-47b60b740d00 06cadf0e-64ed-448a-8927-ce7bf90eb35d -ATTRIB_HIDE
# (c) Pekka "raspi" Järvinen 2017-

$powerSettingSubgroubTable = Get-WmiObject -Namespace root\cimv2\power -Class Win32_PowerSettingSubgroup | Where-Object {$_.ElementName -ne $null}
$powerSettingInSubgroubTable = Get-WmiObject -Namespace root\cimv2\power -Class Win32_PowerSettingInSubgroup
$powerSettingTable = Get-WmiObject -Namespace root\cimv2\power -Class Win32_PowerSetting
$powerSettingDefinitionPossibleValueTable = Get-WmiObject -Namespace root\cimv2\power -Class Win32_PowerSettingDefinitionPossibleValue
$powerSettingDefinitionRangeDataTable = Get-WmiObject -Namespace root\cimv2\power -Class Win32_PowerSettingDefinitionRangeData

$powerSettingSubgroubTable | foreach {
  $gname = $_.ElementName
  $gdescr = $_.Description
  
  $tmp = $_.InstanceId
  $tmp = $tmp.Remove(0, $tmp.LastIndexOf('{') + 1)
  $tmp = $tmp.Remove($tmp.LastIndexOf('}'))
  
  $gguid = $tmp  
  
  Write-Output ('# {0}' -f $gname)
  Write-Output ('{0}' -f $gdescr)
  Write-Output ('Group GUID: `{0}`' -f $gguid)
  Write-Output ""

  $settings = $powerSettingInSubgroubTable | Where-Object GroupComponent -Match "$gguid"
  
  $settings | foreach {
    $tmp = $_.PartComponent
    $tmp = $tmp.Remove(0, $tmp.LastIndexOf('{') + 1)
    $tmp = $tmp.Remove($tmp.LastIndexOf('}'))
  
    $guid = $tmp
  
    $s = $powerSettingTable -Match "$guid"
	
    Write-Output ('* {0}' -f $s.ElementName)
    Write-Output ('  * GUID: `{0}`' -f $guid)
    
    if ($s.Description) {
        Write-Output ('  * {0}' -f $s.Description)
    }
    
    $possible = ($powerSettingDefinitionPossibleValueTable | Where-Object InstanceId -Match "$guid" | select -ExpandProperty ElementName) -join ", "

    if ($possible) {
        Write-Output ('  * Possible values: {0}' -f $possible)
    }
    
    $units = $powerSettingDefinitionRangeDataTable | Where-Object InstanceId -Match "$guid"

    if ($units)
    {
        $u = $units[0].Description
    
        $tmp = @()
    
        $units | foreach {
            $tmp += '{0}: {1} {2}' -f $_.ElementName, $_.SettingValue, $u
        }
        
        Write-Output ('  * {0}' -f ($tmp -join " | "))
    }
    
  }
  
}