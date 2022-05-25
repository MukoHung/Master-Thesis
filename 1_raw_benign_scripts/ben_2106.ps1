$DefaultRuntime = "8";

function Get-Executable([String] $Platform) {
  if ($Platform -eq "windows") {
    return "java.exe";
  } else {
    return "java";
  }
}

function Get-Locations([String] $Platform) {
  if ($Platform -eq "windows") {
    return @(
      "C:\Program Files\AdoptOpenJDK",
      "C:\Program Files\Java",
      "$env:USERPROFILE\.gradle\jdks"
      "$env:JAVA_HOME"
    );
  }
}

function Get-Platform() {
  if (!$PSVersionTable -or !$PSVersionTable.PSEdition) {
    throw "PowerShell Edition Unavailable";
  } elseif ($PSVersionTable.PSEdition -eq "Core") {
    if (!$PSVersionTable.Platform) {
      throw "PowerShell Platform Unavailable";
    } elseif ($PSVersionTable.Platform -eq "Unix") {
      return "linux";
    } elseif ($PSVersionTable.Platform -eq "Win32NT") {
      return "windows";
    } else {
      throw "PowerShell Platform Unsupported";
    }
  } elseif ($PSVersionTable.PSEdition -eq "Desktop") {
    return "windows";
  } else {
    throw "PowerShell Edition Unsupported"
  }
}

function Check-Version([String] $Name, [String] $Runtime) {
  if ($Name.StartsWith("jdk$Runtime") -or $Name.StartsWith("jdk-$Runtime")) {
    return $true;
  }

  # Transforms '1.8.0_292' -> '8u292'
  if ($Runtime.StartsWith("1.8.0_")) {
    return Check-Version -Name $Name -Runtime ("8u" + $Runtime.Remove(0, 6));
  }

  # Transforms '1.8.0' -> '8u'
  if ($Runtime.StartsWith("1.8.0")) {
    return Check-Version -Name $Name -Runtime ("8u" + $Runtime.Remove(0, 5));
  }

  return $false;
}

function Get-Version([String] $Name) {
  # Removes 'jdk-' from 'jdk-11.0.11+9'
  if ($Name.StartsWith("jdk-")) {
    $Name = $Name.Remove(0, 4);
  }

  # Removes 'jdk' from 'jdk8u292-b10-jre'
  if ($Name.StartsWith("jdk")) {
    $Name = $Name.Remove(0, 3);
  }

  # Transforms '8u292-b10-jre' -> '1.8.0_292-b10-jre'
  if ($Name.StartsWith("8u")) {
    $Name = "1.8.0_" + $Name.Remove(0, 2);
  }

  # Removes '-jre' from '1.8.0_292-b10-jre'
  if (($Index = $Name.LastIndexOf("-jre")) -ne -1) {
    $Name = $Name.Substring(0, $Index);
  }

  # Removes '-b10' from '1.8.0_292-b10'
  if (($Index = $Name.LastIndexOf('-')) -ne -1) {
    $Name = $Name.Substring(0, $Index);
  }

  # Removes '+9' from '11.0.11+9'
  if (($Index = $Name.LastIndexOf('+')) -ne -1) {
    $Name = $Name.Substring(0, $Index);
  }

  return $Name;
}

function Get-Runtimes([String] $Platform, [String] $Runtime) {
  $Executable = Get-Executable -Platform $Platform;
  [Array] $Locations = Get-Locations -Platform $Platform;

  if (!$Locations -or $Locations.Count -eq 0) {
    throw "Locations Unavailable";
  }

  $Entries = @();
  ForEach ($Location in $Locations) {
    if (!$Location -or !(Test-Path -LiteralPath $Location)) {
      continue;
    }

    ForEach ($File in Get-ChildItem -LiteralPath $Location -Filter $Executable -File -Depth 2) {
      $Directory = (Get-Item -LiteralPath $File.FullName).Directory.Parent;
      if ($Directory.Name -eq "jre") {
        $Directory = $Directory.Parent;
      }

      if ($Runtime -and !(Check-Version -Name $Directory.Name -Runtime $Runtime)) {
        continue;
      }

      $Entries += @{
        Executable = $File.FullName;
        Location = $Directory.Parent.FullName;
        Version = (Get-Version -Name $Directory.Name);
      };
    }
  }

  if ($Entries.Count -eq 0) {
    throw "Java Runtime Unavailable";
  }

  return $Entries;
}

$Platform = Get-Platform;
$Runtime = $DefaultRuntime;

$Key = $args[0];
if ($Key -and $Key.StartsWith("-")) {
  $Key = $Key.TrimStart("-");

  if ($Key -eq "List-Runtimes" -or $Key -eq "ListRuntimes") {
    [Array] $Entries = Get-Runtimes -Platform $Platform | Sort-Object -Property { $_.Version };
    $Padding = ($Entries | Measure-Object -InputObject { $_.Version.Length } -Maximum).Maximum;
    ForEach ($Entry in $Entries) {
      Write-Host "$($Entry.Version.PadRight($Padding, " ")) [$($Entry.Location)]";
    }

    return;
  }

  if ($Key -eq "Runtime") {
    $Value = $args[1];
    if (!$Value) {
      throw "Expected a value after Runtime";
    }

    $Runtime = $Value;
    $args = $args[2..($args.Length)];
  }
}

[Array] $Entries = Get-Runtimes -Platform $Platform -Runtime $Runtime;
& $Entries[0].Executable $args;