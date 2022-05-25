# http://d-fens.ch/2013/12/05/vcac-dynamically-execute-scripts-in-externalwfstubs-workflows-with-powershell/

PS > $Machine.GetType().FullName
DynamicOps.ManagementModel.VirtualMachine
PS > $m.GetType().FullName
DynamicOps.ManagementModel.ManagementModelEntities

# script main
$Write-Host ("{0}: Processing Machine entity: '{1}'." -f $Machine.VirtualMachineID, $Machine.VirtualMachineName);

$null = $m.LoadProperty($Machine, 'VirtualMachineProperties');
$hp = @{};
$m.LoadProperty($Machine, 'VirtualMachineProperties') | Select-Object PropertyName, PropertyValue, IsEncrypted |% {
  if($_.IsEncrypted) {
    $hp.Add($_.PropertyName, [DynamicOps.Common.Utils.ScramblerHelpers]::Unscramble($_.PropertyValue));
  } else {
    $hp.Add($_.PropertyName, $_.PropertyValue);
  } # if
};

# Get all properties for current machine state
$WorkflowStubIdentifier = 'ExternalWFStubs';
$ServerScripts = 'Scripts';
if($PSBoundParameters.ContainsKey('VirtualMachineState')) {
  $VirtualMachineState = $Machine.VirtualMachineState;
} # if
$ap = $hp.Keys -match ('^{0}\.{1}\.{2}\.' -f
  $WorkflowStubIdentifier, $VirtualMachineState, $ServerScripts) | Sort;

$al = New-Object System.Collections.ArrayList;
$PropertyScript = '';
$ScriptName = '';
foreach($p in $ap) {
  # Get script name
  $fMatch = $p -match ('^{0}\.{1}\.{2}\.({3}|{3}\.{4})$' -f
    $WorkflowStubIdentifier, $VirtualMachineState, $ServerScripts, '([^\.]+)', '([^\.]+)');
  if(!$fMatch) { continue; }
  if($Matches.Count -eq 3) {
    if($PropertyScript -And $ScriptName) {
      Write-Host $PropertyScript
      $ScriptCommand = New-ScriptCommandline
	    -Machine $Machine
		-ScriptName $ScriptName
		-htScriptParam $htScriptParam
		-Path $Path;
      if(!$ScriptCommand) {
        Write-Warning ("'{0}': '{1}' FAILED to extract command line." -f
		  $PropertyScript, $ScriptName);
      } # if
      $null = $al.Add($ScriptCommand);
    } # if
    $PropertyScript = $Matches[2];
    $ScriptName = $hp.$p;
    $htScriptParam = @{};
  } elseif($Matches.Count -eq 4) {
    $PropertyParam = $Matches[4];
    $ScriptParam = $hp.$p;
    $htScriptParam.$PropertyParam = $ScriptParam;
  } else {
    Write-Warning ("{0}: Matches.Count - continue" -f $p);
    continue;
  } # if
} # foreach
if($PropertyScript -And $ScriptName) {
  Write-Host $PropertyScript
  $ScriptCommand = New-ScriptCommandline
    -Machine $Machine
	-ScriptName $ScriptName
	-htScriptParam $htScriptParam
	-Path $Path;
  if(!$ScriptCommand) {
    Write-Warning ("'{0}': '{1}' FAILED to extract command line." -f
	  $PropertyScript, $ScriptName);
  } # if
  $null = $al.Add($ScriptCommand);
} # if

<#
 # This is an example output from the above generated array $al
 # all scripts are constructed from the properties attached to the virtual machine (including credentials)

C:\data\scripts\Set-DomainMembersip.ps1 -Username 'SHAREDOP\myUser' -Domain 'sharedop.org' -Passwod 'P@ssw0rd'
C:\data\scripts\New-CmdbEntry.ps1 -Machine 'vc100228' -Username 'SHAREDOP\Edgar' -Password 'P@ssw0rd'
C:\data\scripts\Set-VcacVirtualMachineName.ps1 -Name 'myNewVMName' -Fqdn 'example.com'

 #
 #>