# Run WSL git from Windows, mapping some paths between unix <-> Win
# To use with wslgit.cmd, place them in the same directory

Function ToUnix {
  # If the arg has a \, then it's probably a path. Convert it.
  if ($args[0] -match "\\") {
    $mapped = wsl wslpath -u `'$($args[0])`'
  } else {
    $mapped = $args[0]
  }
  # Add single quotes around each arg for bash
  "`'$mapped`'"
}

# Convert each arg with ToUnix
$mappedargs = $args | % { ToUnix $_ }

$out = wsl git $mappedargs
$gitExit = $LASTEXITCODE

# Mapping paths in the output is extremely difficult to get right
# in the general case. Luckily, VS Code seems happy with most of the
# output paths in unix format. However, it does depend on some
# responses mapping to Windows paths. Transforming single-word
# responses that look like paths seems to be sufficient for most
# common VS Code operations.
if ($out -is [string]) {
  $words = -split $out
  # Only map single words that have a /, but aren't a ref (which also has slashes)
  if (($words.Length -eq 1) -and ($words[0] -match "/") -and !($words[0] -match "^refs/")) {
    $out = wsl wslpath -w $words[0]
  }
}
$out
exit $gitExit
