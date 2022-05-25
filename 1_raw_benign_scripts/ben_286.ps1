<# examples:  
# generate a baseline policy.
powershell.exe -file applocker.ps1 -baseline -output c:\policies\baseline.xml

# generate an application-specific policy.
powershell.exe -file applocker.ps1 -application -in c:\policies\baseline.xml -out c:\policies\application.xml

# generate an adhoc policy.
powershell.exe -file applocker.ps1 -adhoc -in c:\path -filter *.* -out c:\policies\adhoc.xml

# merge policies.
powershell.exe -file applocker.ps1 -merge -in c:\policies -out c:\policies\merged.xml  
#>

<#  expected usage:  
1. run the script to generate a baseline. e.g.  
   powershell.exe -file applocker.ps1 -baseline -out c:\policies\baseline.xml
2. install an application.  
3. rerun the script to generate an application-specific policy. e.g.  
   powershell.exe -file applocker.ps1 -application -in c:\policies\baseline.xml -out c:\policies\someapp.xml
4. rerun the script to merge applocker policies under c:\policies. e.g.  
   powershell.exe -file applocker.ps1 -merge -in c:\policies -out c:\policies\soe.xml
#>

param(  
  [switch]$baseline,
  [switch]$application,
  [switch]$adhoc,
  [switch]$merge,
  [string]$in,
  [string]$filter,
  [string]$out
)

function log($message)   { write-host -foregroundcolor green $message }  
function error($message) { write-host -foregroundcolor magenta $message; exit }

# check baseline switches.
if ($baseline) {  
  if ($out -eq $null) { error 'Usage: powershell.exe -file applocker.ps1 -baseline -out c:\policies\baseline.xml' }
  if (! (test-path (split-path $out -parent))) { error 'The output folder does not exist.' }
}

# check application switches.
if ($application) {  
  if ($in -eq $null -or $out -eq $null) { error 'powershell.exe -file applocker.ps1 -application -in c:\policies\baseline.xml -out c:\policies\application.xml' }
  if (! (test-path $in)) { error 'The baseline policy does not exist.' }
  if (! (test-path (split-path $out -parent))) { error 'The output folder does not exist.' }
}

# check adhoc switches.
if ($adhoc) {  
  if ($in -eq $null -or $filter -eq $null -or $out -eq $null) { error 'powershell.exe -file applocker.ps1 -adhoc -in c:\path -filter *.* -out c:\policies\adhoc.xml' }
  if (! (test-path $in)) { error 'The input folder does not exist.' }
  if (! (test-path (split-path $out -parent))) { error 'The output folder does not exist.' }
}

# check merge switches.
if ($merge) {  
  if ($in -eq $null -or $out -eq $null) { error 'powershell.exe -file applocker.ps1 -merge -in c:\policies -out c:\policies\merged.xml' }
  if (! (test-path $in)) { error 'The input folder does not exist.' }
  if (! (test-path (split-path $out -parent))) { error 'The output folder does not exist.' }
}

# we will trust all products published by the following vendors.
$vendors = "O=MICROSOFT CORPORATION, L=REDMOND, S=WASHINGTON, C=US", "O=CITRIX SYSTEMS, INC., L=SANTA CLARA, S=CALIFORNIA, C=US"

# directories to scan.
$paths = @('C:\Program Files', 'C:\Program Files (x86)')

# rule collection types.
$types = 'Appx', 'Dll', 'Exe', 'Msi', 'Script'

# empty applocker policy.
$xml = [xml]@'
<AppLockerPolicy Version="1">  
<RuleCollection Type="Appx" EnforcementMode="Enabled" />  
<RuleCollection Type="Dll" EnforcementMode="Enabled" />  
<RuleCollection Type="Exe" EnforcementMode="Enabled" />  
<RuleCollection Type="Msi" EnforcementMode="Enabled" />  
<RuleCollection Type="Script" EnforcementMode="Enabled" />  
</AppLockerPolicy>  
'@

# empty publisher rule.
$publisher = [xml]@'
<FilePublisherRule Id="" Name="" Description="" UserOrGroupSid="S-1-1-0" Action="Allow">  
  <Conditions>
    <FilePublisherCondition PublisherName="" ProductName="*" BinaryName="*">
      <BinaryVersionRange LowSection="*" HighSection="*" />
    </FilePublisherCondition>
  </Conditions>
</FilePublisherRule>  
'@

# empty file hash rule.
$hash = [xml]@'
<FileHashRule Id="" Name="Windows 10 Hash Rules" Description="" UserOrGroupSid="S-1-1-0" Action="Allow">  
  <Conditions>
    <FileHashCondition />
  </Conditions>
</FileHashRule>  
'@

# return the "real" extension of a file.
function get-filetype($path) {  
  $extension = [io.path]::getextension($path)
  $extensions = @('.dll', '.exe', '.js', '.msi', '.ps1', '.vbs')

  # extensions of file types that are actually dlls.
  $imposterdlls = @('.api', '.8bx')

  if ($extensions -contains $extension) { return $extension }

  # a hack for files which are dll's without a pe header.
  if ($imposterdlls -contains $extension) { return '.dll' }

  $bytes = get-content $path -readcount 0 -encoding byte
  $offset = $bytes[0x3c]
  $signature = [char[]] $bytes[$offset..($offset + 3)]

  if ([string]::join('', $signature) -eq "PE`0`0") {
    $header = $offset + 4
    $data = [bitconverter]::toint32($bytes, $header + 18)
    if ($data -band 0x2000) { return '.dll' } else { return '.exe' }
  }

  return $extension
}

# insert a rule based on $template, with a rule type of $class, under $parent, into $policy.
function insert-rule($policy, $parent, $template, $class) {  
  $rule = $template.clone()
  $rule.$class.id = [string]([guid]::newguid().guid)
  return $parent.appendchild($policy.importnode($rule.$class, $true))
}

# insert $hashes into $policy under $parent.
function insert-hashes($policy, $hashes, $parent) {  
  $hashes | %{ [void]$parent.conditions.firstchild.appendchild($policy.importnode($_, $true)) }
}

# insert $publishers into $policy under $parent.
function insert-publishers($policy, $publishers, $parent) {  
  $publishers | %{
    $_.conditions.filepublishercondition.binaryname = '*'
    $_.conditions.filepublishercondition.binaryversionrange.lowsection = '*'
    $_.conditions.filepublishercondition.binaryversionrange.highsection = '*'
    [void]$parent.appendchild($policy.importnode($_, $true))
  }
}

# insert $paths into $policy under $parent.
function insert-paths($policy, $paths, $parent) {  
  $paths | %{ [void]$parent.appendchild($policy.importnode($_, $true)) }
}

# insert conditions ($hashes and $publishers) into $policy under $parent.
function insert-conditions($policy, $parent, $hashes, $publishers) {  
  if ($hashes.count) {
    $node = insert-rule $policy $parent $hash 'filehashrule'
    insert-hashes $policy $hashes $node
  }

  if ($publishers.count) { insert-publishers $policy $publishers $parent }
}

# merge policy $one with $two and return union.
function merge-policies($one, $two) {  
  $target = $xml.clone()

  foreach ($type in $types) {
    $hashes = @($one.applockerpolicy.selectnodes("//RuleCollection[@Type='$type']//FileHash") +
                $two.applockerpolicy.selectnodes("//RuleCollection[@Type='$type']//FileHash") | sort-object -property data -unique)

    $publishers = @($one.applockerpolicy.selectnodes("//RuleCollection[@Type='$type']/FilePublisherRule") +
                    $two.applockerpolicy.selectnodes("//RuleCollection[@Type='$type']/FilePublisherRule") | sort-object -property name -unique)

    # this script will never generate path rules, but we need to cater for merging with a policy that does.
    $paths = @($one.applockerpolicy.selectnodes("//RuleCollection[@Type='$type']/FilePathRule") +
               $two.applockerpolicy.selectnodes("//RuleCollection[@Type='$type']/FilePathRule") | sort-object -property name -unique)

    $parent = $target.applockerpolicy.selectsinglenode("//RuleCollection[@Type='$type']")
    insert-conditions $target $parent $hashes $publishers
    insert-paths $target $paths $parent
  }

  return $target
}

# remove duplicate conditions between $one and $two and return result.
function remove-duplicates($one, $two) {  
  $target = $xml.clone()

  foreach ($type in $types) {
    $h1 = @($one.applockerpolicy.selectnodes("//RuleCollection[@Type='$type']//FileHash") | sort-object -property data)
    $h2 = @($two.applockerpolicy.selectnodes("//RuleCollection[@Type='$type']//FileHash") | sort-object -property data)
    $hashes = @(); compare-object -referenceobject $h1 -differenceobject $h2 -property data -passthru | ? { $_.sideindicator -eq '<=' } | %{ $hashes += $_ }

    $p1 = @($one.applockerpolicy.selectnodes("//RuleCollection[@Type='$type']/FilePublisherRule") | sort-object -property name)
    $p2 = @($two.applockerpolicy.selectnodes("//RuleCollection[@Type='$type']/FilePublisherRule") | sort-object -property name)
    $publishers = @(); compare-object -referenceobject $p1 -differenceobject $p2 -property name -passthru | ? { $_.sideindicator -eq '<=' } | %{ $publishers += $_ }

    $parent = $target.applockerpolicy.selectsinglenode("//RuleCollection[@Type='$type']")
    insert-conditions $target $parent $hashes $publishers
  }

  return $target
}

# applocker cannot handle more than 1,500 or so hashes in a single rule. let's break into blocks of 1000.
function split-hashes($applocker) {  
  foreach ($type in $types) {
    $collection = $applocker.applockerpolicy.selectsinglenode("//RuleCollection[@Type='$type']")
    $hashes = @($applocker.applockerpolicy.selectnodes("//RuleCollection[@Type='$type']//FileHash") | sort-object -property data)

    if ([math]::floor($hashes.count) -gt 0) {
      [void]$collection.removechild($collection.filehashrule)
    }

    $min = 0; while ($min -lt $hashes.count) {
      $max = $min + 999
      insert-conditions $applocker $collection $hashes[$min..$max] $null
      $min = $max + 1
    }
  }
}

# initialise policy.
$applocker = $xml.clone()

# initialise rules array.
$rules = @()

# if merging policies.
if ($merge) {  
  $applocker = $xml.clone()

  get-childitem $in\*.xml -exclude (split-path $out -leaf) | %{
    log "Merging AppLocker policy $($_.name)."
    $applocker = merge-policies $applocker ([xml](get-content $_.fullname -encoding utf8))
  }

  log "Chunking hashes into blocks of 1,000."
  split-hashes $applocker

  log "Saving the merged policy."
  $applocker.save($out)
  return
}

# if generating an adhoc policy.
if ($adhoc) {  
  log "Creating adhoc AppLocker rules for $filter in folder $in."

  $rules +=  get-childitem -path $in -filter $filter -recurse | select -expandproperty fullname | get-applockerfileinformation -ea silentlycontinue
  $rules | %{
    $_.path = $_.path -replace '%OSDRIVE%', 'C:'
    $extension = [io.path]::getextension($_.path)
    $_.path = $_.path -replace $extension, (get-filetype $_.path)
  }

  $policy = [xml]($rules | new-applockerpolicy -ruletype publisher, hash -user everyone -xml -ignoremissingfileinformation)
} else {
  log "Creating AppLocker rules for the requested paths."
  $paths | %{ $rules += get-applockerfileinformation -directory $_ -recurse -ea silentlycontinue }
  $policy = [xml]($rules | new-applockerpolicy -ruletype publisher, hash -user everyone -xml -ignoremissingfileinformation)
}

log "Optimising rules."  
foreach ($type in $types) {  
  $parent = $applocker.applockerpolicy.selectsinglenode("//RuleCollection[@Type='$type']")

  $hashes = @($policy.applockerpolicy.selectnodes("//RuleCollection[@Type='$type']//FileHash") | sort-object -property data -unique)
  $publishers = @($policy.applockerpolicy.selectnodes("//RuleCollection[@Type='$type']/FilePublisherRule") | %{
    $_.name = "{0} - {1}" -f $_.conditions.filepublishercondition.publishername, $_.conditions.filepublishercondition.productname; $_
  } | sort-object -property name -unique)

  insert-conditions $applocker $parent $hashes $publishers
}

log "Consolidating file publisher conditions for trusted vendors."  
foreach ($vendor in $vendors) {  
  $node = $publisher.clone()
  $node.filepublisherrule.name = [string]"$vendor - *"
  $node.filepublisherrule.conditions.filepublishercondition.publishername = [string]$vendor

  foreach ($type in $types) {
    $parent = $false

    $applocker.applockerpolicy.selectnodes("//RuleCollection[@Type='$type']/FilePublisherRule[contains(@Name, '$vendor')]") | %{
      $parent = $_.parentnode
      [void]($parent.removechild($_))
    }

    if ($parent -ne $false) {
      $node.filepublisherrule.id = [string]([guid]::newguid().guid)
      [void]$parent.appendchild($applocker.importnode($node.filepublisherrule, $true))
    }
  }
}

if ($application) {  
  log "Comparing the new policy with the baseline and removing duplicate conditions."
  $applocker = remove-duplicates $applocker ([xml](get-content $in -encoding utf8))
}

log "Removing publisher rule wildcards."  
foreach ($type in $types) {  
  $applocker.applockerpolicy.selectnodes("//RuleCollection[@Type='$type']/FilePublisherRule/Conditions/FilePublisherCondition/BinaryVersionRange") | %{
    $_.LowSection  = "*"
    $_.HighSection = "*"
  }
}

log "Saving the policy."  
$applocker.save($out)