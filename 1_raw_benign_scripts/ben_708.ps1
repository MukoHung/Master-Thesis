[CmdletBinding(SupportsShouldProcess)]
param (
  [Parameter(Mandatory)]
  [String]
  $Url,
  [Parameter(Mandatory)]
  [String]
  $Solution,
  [Parameter(Mandatory)]
  [String]
  $ClientId,
  [Parameter(Mandatory)]
  [String]
  $TenantId,
  [Parameter(Mandatory)]
  [String]
  $RedirectUrl
)
$ErrorActionPreference = "Stop"
function Get-WebApiHeaders ($Url, $ClientId, $TenantId, $ClientSecret) {
  Write-Host "Getting access token for $Url for client ID $ClientId."
  $tokenResponse = Get-AdalToken -Resource $Url -ClientId $ClientId -Authority "https://login.microsoftonline.com/$TenantId" -RedirectUri $RedirectUrl -Verbose
  $token = $tokenResponse.AccessToken
  return @{
    "Authorization"    = "Bearer $token"
    "Content-Type"     = "application/json"
    "Accept"           = "application/json"
    "OData-MaxVersion" = "4.0"
    "OData-Version"    = "4.0"
    "Prefer"           = "odata.include-annotations=`"*`""
  }
}
$webApiHeaders = Get-WebApiHeaders -Url $Url -ClientId $ClientId -TenantId $TenantId -ClientSecret $ClientSecret
$webApiUrl = "$Url/api/data/v9.1"
function Get-UnchangedManagedComponentLayers () {
  Write-Host "Getting unchanged managed components in the $Solution solution."
  $solution = Invoke-RestMethod "$webApiUrl/solutions?`$filter=ismanaged eq false and uniquename eq '$Solution'&`$expand=solution_solutioncomponent(`$select=objectid,componenttype,rootcomponentbehavior,rootsolutioncomponentid)&`$top=1" -Headers $webApiHeaders
  if ($solution.value.Length -eq 0) {
    throw "Unable to find an unmanaged solution named $Solution."
  }
  Write-Host "Found solution with $($solution.value[0].solution_solutioncomponent.Length) solution components."
  $i = 0
  [System.Collections.ArrayList]$manualtasks = @()
  [System.Collections.ArrayList]$unchangedManagedComponents = @()
  $solution.value[0].solution_solutioncomponent | ForEach-Object {
    $solutionComponent = $_
    $progress = [Math]::Ceiling(($i++ / $solution.value[0].solution_solutioncomponent.Length) * 100)
    Write-Progress -Activity "Processing solution components" -Status "$progress% Complete:" -PercentComplete $progress;
    if ($null -eq $solutionComponent.'componenttype@OData.Community.Display.V1.FormattedValue') {
      Write-Verbose "Skipping object $($solutionComponent.objectid). Unable to determine component type $($solutionComponent.componenttype)."
      return
    }
    $componentTypeName = $solutionComponent.'componenttype@OData.Community.Display.V1.FormattedValue'.Replace(' ', '').Replace('SDK', 'Sdk')
    $componentId = $solutionComponent.objectid
    # Batch request should be more performant here - msdyn_componentlayers must be queried with the an eq filter on both msdyn_componentid and msdyn_solutioncomponentname
    Write-Verbose "Querying solution layers for $componentTypeName $componentId."
    $componentLayers = Invoke-RestMethod "$webApiUrl/msdyn_componentlayers?`$filter=msdyn_componentid eq '{$componentId}' and msdyn_solutioncomponentname eq '$componentTypeName'" -Headers $webApiHeaders
    $componentName = $componentLayers.value[0].msdyn_name
    $activeLayer = $componentLayers.value | Where-Object { $_.msdyn_solutionname -eq 'Active' }
    $managed = $null -eq $activeLayer -or $componentLayers.value.Length -gt 1
    if (!$managed) {
      Write-Verbose "Skipping unmanaged component $componentTypeName $componentName ($componentId)."
      return
    }
    if ($managed -and $componentTypeName -eq "Entity" -and $solutionComponent.rootcomponentbehavior -eq 0) {
      Write-Warning "Managed entity $componentName includes all subcomponents. Unable to determine changes."
      $manualtasks.Add(@{
          ComponentName     = $componentName
          ComponentTypeName = $componentTypeName
          ComponentId       = $componentId
          Task              = "Remove from the solution and add again without including all subcomponents. Manually include the changed sub-components."
        }) | Out-Null
      return
    }
    $unchanged = $false
    if ($null -eq $activeLayer) {
      Write-Host "No active layer found for $componentTypeName $componentName ($componentId)."
      $unchanged = $true
    }
    else {
      Write-Host "Active layer found for $componentTypeName $componentName ($componentId). Assessing changes."
      $changes = ConvertFrom-Json $activeLayer.msdyn_changes
      $changes.Attributes = $changes.Attributes | Where-Object { $_.Key -inotmatch '(modifiedon)|(autonumberformat)|(formuladefinition)|(validforcreateapi)|(validforupdateapi)|(displaymask)|(isretrievable)|(appdefaultvalue)' }
      $unchanged = $changes.Attributes.Length -eq 0
      if ($unchanged -eq $true) {
        Write-Host "Only active changes for $componentTypeName $componentName ($componentId) are due to platform updates."
      }
      else {
        Write-Host "Genuine changes found for $componentTypeName $componentName ($componentId)."
        if ($componentTypeName -eq "SystemForm") {
          $nonPlatformFormChanges = @($changes.Attributes | Where-Object { $_.Key -inotmatch '(formxml)|(formjson)' })
          if ($nonPlatformFormChanges.Length -eq 0) {
            Write-Warning "Unable to determine if changes have been introduced on $componentTypeName $componentName ($componentId). Review and remove manually if required."
            $manualtasks.Add(@{
                ComponentName     = $componentName
                ComponentTypeName = $componentTypeName
                ComponentId       = $componentId
                Task              = "Determine if changes have been made to this form. Remove from the solution if not."
              }) | Out-Null
          }
        }
      }
    }
    if ($componentTypeName -eq "Entity" -and $unchanged) {
      Write-Host "Checking if unchanged entity $componentName includes subcomponents."
      [array]$subcomponents = $solution.value[0].solution_solutioncomponent | Where-Object { $_.rootsolutioncomponentid -eq $solutionComponent.solutioncomponentid }
      $hasSubcomponents = $subcomponents.Length -gt 0
      if (!$hasSubcomponents) {
        Write-Host "Entity $componentName doesn't include subcomponents and can be removed."
      }
      else {
        $unchanged = $false
        Write-Host "Entity $componentName includes subcomponents and won't be removed."
        if ($subcomponent.rootcomponentbehavior -eq 1) {
          Write-Warning "Solution includes entity metadata for $componentName but with no changes. Entity metadata should be excluded."
          $manualtasks.Add(@{
              ComponentName     = $componentName
              ComponentTypeName = $componentTypeName
              ComponentId       = $componentId
              $Task             = "Exclude the entity metadata from the solution."
            }) | Out-Null
        }
      }
    }
    elseif ($componentTypeName -eq "OptionSet" -and $unchanged) {
      Write-Host "Checking if unchanged option set $componentName includes option changes."
      $optionSetActiveLayer = Invoke-RestMethod "$webApiUrl/msdyn_componentlayers?`$filter=msdyn_componentid eq '{$componentId}' and msdyn_solutioncomponentname eq '$componentTypeName' and msdyn_solutionname eq 'Active'" -Headers $webApiHeaders
      if ($optionSetActiveLayer.value[0].msdyn_children -like "*`"Key`":`"action`",`"Value`":`"updated`"*") {
        Write-Host "Option set $componentName includes option changes and won't be removed."
        $unchanged = $false
      }
    }
    if ($unchanged) {
      Write-Host "Adding $componentTypeName $componentName ($componentId) to list of unchanged components."
      $unchangedManagedComponents.Add(@{
          SolutionComponentName = $componentTypeName
          ComponentName         = $componentName
          ComponentType         = $solutionComponent.componenttype
          SolutionComponentId   = $solutionComponent.objectid
        }) | Out-Null
    }
  }
  $(foreach ($ht in $unchangedManagedComponents) { new-object PSObject -Property $ht }) | Export-Csv -Path unchanged.csv
  $(foreach ($ht in $manualtasks) { new-object PSObject -Property $ht }) | Export-Csv -Path manual.csv
  Write-Host "$($unchangedManagedComponents.Count) unchanged componets were found and $($manualtasks.Count) manual tasks were found."
  return $unchangedManagedComponents
}
function Remove-SolutionComponent {
  [CmdletBinding(SupportsShouldProcess)]
  param (
    [Parameter(Mandatory)]
    $Component
  )
  if ($PSCmdlet.ShouldProcess("$($Component.SolutionComponentName) $($Component.ComponentName)")) {
    $removeSolutionComponentRequest = @{
      SolutionUniqueName = $Solution
      ComponentType      = $Component.ComponentType
      SolutionComponent  = @{
        solutioncomponentid = $Component.SolutionComponentId
      }
    }
    try {
      Invoke-RestMethod -Uri "$webApiUrl/RemoveSolutionComponent" -Body (ConvertTo-Json $removeSolutionComponentRequest) -Method POST -Headers $webApiHeaders
    } catch {
      Write-Warning "$($Component.SolutionComponentName) $($Component.ComponentName) Failed"
    }
  }
}

$temp = Get-UnchangedManagedComponentLayers

#Get-Content .\ScottishWaterEntitySLABase-unchanged-6.csv | ConvertFrom-Csv | ForEach-Object { Remove-SolutionComponent($_) }

# Batch request does not work with msdyn_componentlayers (must be queried with a msdyn_componentid and an msdyn_solutioncomponentname)
# $boundary = "batch_retrievecomponentlayers"
# $webApiHeaders["Content-Type"] = "multipart/mixed; boundary=$boundary"
# $objectIds = $solution.value[0].solution_solutioncomponent.objectid
# $batchBody = "--$boundary`n" +
# "Content-Type: application/http`n" +
# "Content-Transfer-Encoding: binary`n`n" +
# "GET $webApiUrl/msdyn_componentlayers?`$filter=(Microsoft.Dynamics.CRM.In(PropertyName='msdyn_componentid', PropertyValues=['$($objectIds -join "', '")'])) HTTP/1.1`n" +
# "Accept: application/json`n`n"+
# "--$boundary--"
# Invoke-RestMethod "$webApiUrl/`$batch" -Body $batchBody -Headers $webApiHeaders -Method POST