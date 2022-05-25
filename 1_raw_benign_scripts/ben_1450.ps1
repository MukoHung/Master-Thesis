# http://d-fens.ch/2013/12/05/vcac-dynamically-execute-scripts-in-externalwfstubs-workflows-with-powershell/

# Machine is the currently processed virtual machine
# Path is a default path where the scripts are located
# ScriptName is the name of the PowerShell script passed from the custom properties
# htScriptParam is a hastable containing parameter name and raw expression

$ScriptName = Join-Path -Path $Path -ChildPath $ScriptName;
if( !(Test-Path -Path $ScriptName) ) {
  Write-Error ("ScriptName '{0}' does not exist." -f $ScriptName);
  return $null;
} # if
$Cmd = Get-Command $ScriptName;

$ScriptParams = '';
foreach($k in $htScriptParam.Keys) {

  if(!$Cmd.Parameters.ContainsKey($k)) {
    Write-Error ("'{0}' does not contain specified parameter '{1}'. Skipping ..." -f
	  $ScriptName, $k);
    continue;
  } # if
  $ScriptParam = $htScriptParam.$k;
  $ScriptParam = $ScriptParam.Replace('#Machine', '$Machine');
  if($ScriptParam -match "#Properties\.'([^\']+)'") {
    $p = $Machine.VirtualMachineProperties |? PropertyName -eq $Matches[1];
    if(!$p) {
      Write-Error ("Resolving '{0}' with ScriptParam '{1}' [{2}] FAILED." -f
	    $ScriptName, $k, $ScriptParam);
      continue;
    } # if
    $ScriptParam = $p.PropertyValue;
  } # if
  if($ScriptParam.StartsWith('$')) {
    Write-Debug ("ScriptParam in Invoke-Expression: '{0}'." -f $ScriptParam)
    $ScriptParam = Invoke-Expression -Command $ScriptParam;
  } # if
  $ScriptParams = "{0} -{1} '{2}'" -f $ScriptParams, $k, $ScriptParam;
} # foreach
$ScriptCommandline = "{0}{1}" -f $ScriptName, $ScriptParams;

PS > $ScriptCommandline;
C:\data\scripts\Set-VcacVirtualMachineName.ps1 -Name 'myNewVMName' -Fqdn 'example.com'
