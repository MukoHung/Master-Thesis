<#
    Dumps capture group locations and names/numbers

    Example:
    > regexinfo 'Jenny: 555-867-5309' '(?<name>\w+):\s+(?<phone>(?:(?<area>\d{3})-)?(\d{3}-\d{4}))'
    [Jenny]: [[555]-[867-5309]]
    |        ||     |
    |        ||     1
    |        |area
    |        phone
    name
#>
function regexinfo {
    param(
        [ValidateNotNull()]
        [Parameter(Mandatory = $true)]
        [String] $InputString,

        [ValidateNotNull()]
        [Parameter(Mandatory = $true)]
        [String] $Pattern
    )

    $colors = @( [ConsoleColor]::Red, [ConsoleColor]::Magenta, [ConsoleColor]::Cyan, [ConsoleColor]::Green, [ConsoleColor]::Yellow, [ConsoleColor]::White )
    $openToken = '['
    $closeToken = ']'
    $r = [regex]$pattern
    $raw = $r.Match($inputString)
    $groupArray = $raw.Groups | % { $_ }
    $grpIndex = 1
    $groupData = $raw.Groups | select -skip 1 | sort-object @{E = 'Index'; Ascending = $true}, @{E = 'Length'; Descending = $true} | % {
        $group = $groupArray[$grpIndex]
        if ($group.Success) {
            [pscustomobject]@{
                Name       = $r.GroupNameFromNumber($grpIndex)
                GroupIndex = $grpIndex
                StartIndex = $group.Index
                EndIndex   = $group.Index + $group.Length
                Length     = $group.Length
                Color      = $colors[$grpIndex % $colors.Length]
            }
        }
        $grpIndex++
    }
    $openBrackets = $groupData  | % { [pscustomobject]@{ Token = $openToken; Color = $_.Color; Index = $_.StartIndex; Name = $_.Name; GroupIndex = $_.GroupIndex; Length = $_.Length } }
    $closeBrackets = $groupData | % { [pscustomobject]@{ Token = $closeToken; Color = $_.Color; Index = $_.EndIndex; Name = $_.Name; GroupIndex = $_.GroupIndex; Length = $_.Length } }
    $allBrackets = @(@($openBrackets) + @($closeBrackets))
    $iFinal = 0
    $pointers = @()
    for ($iStr = 0; $iStr -lt $inputString.Length; $iStr++) {
        $currBrackets = $allBrackets |? Index -eq $iStr `
            | Sort-Object @{ Descending = $true; Expression = {
                if ($_.Token -eq $closeToken -and $_.Length -ne 0) { 1 + (1/$_.Length) }
                elseif ($_.Token -eq $openToken -and $_.Length -eq 0) { 1 }
                elseif ($_.Token -eq $closeToken -and $_.Length -eq 0) { -1 }
                elseif ($_.Token -eq $openToken -and $_.Length -ne 0) { -1 - (1/$_.Length) }
              }},@{ Descending = $true; Expression = {
                if ($_.Token -eq $closeToken -and $_.Length -ne 0) { $_.GroupIndex }
                elseif ($_.Token -eq $openToken -and $_.Length -eq 0) { 1/$_.GroupIndex}
                elseif ($_.Token -eq $closeToken -and $_.Length -eq 0) { -(1/$_.GroupIndex)}
                elseif ($_.Token -eq $openToken -and $_.Length -ne 0) { -$_.GroupIndex }
              }}

        $currBrackets | % {
            Write-Host -nonew ($_.Token) -ForegroundColor ($_.Color)
            if ($_.Token -eq $openToken) {
                $pointers = $pointers + [pscustomobject]@{Padding = $iFinal; Color = $_.Color; Name = $_.Name }
            }
            $iFinal++
        }
        Write-Host -nonew $inputString[$iStr]
        $iFinal++
    }
    
    $currBrackets = $allBrackets |? Index -eq $inputString.Length `
      | Sort-Object @{ Descending = $true; Expression = {
          if ($_.Token -eq $closeToken -and $_.Length -ne 0) { 1 + (1/$_.Length) }
          elseif ($_.Token -eq $openToken -and $_.Length -eq 0) { 1 }
          elseif ($_.Token -eq $closeToken -and $_.Length -eq 0) { -1 }
          elseif ($_.Token -eq $openToken -and $_.Length -ne 0) { -1 - (1/$_.Length) }
        }},@{ Descending = $true; Expression = {
          if ($_.Token -eq $closeToken -and $_.Length -ne 0) { $_.GroupIndex }
          elseif ($_.Token -eq $openToken -and $_.Length -eq 0) { 1/$_.GroupIndex}
          elseif ($_.Token -eq $closeToken -and $_.Length -eq 0) { -(1/$_.GroupIndex)}
          elseif ($_.Token -eq $openToken -and $_.Length -ne 0) { -$_.GroupIndex }
        }}

    $currBrackets | % {
        Write-Host -nonew ($_.Token) -ForegroundColor ($_.Color)
        if ($_.Token -eq $openToken) {
          $pointers = $pointers + [pscustomobject]@{Padding = $iFinal; Color = $_.Color; Name = $_.Name }
        }
        $iFinal++
    }

    Write-Host
    for ($i = 0; $i -lt $iFinal; $i++) {
        $barGroup = $pointers |? Padding -eq $i
        if ($barGroup) {
            Write-Host -nonew '|' -ForegroundColor  $barGroup.Color
        }
        else {
            Write-Host -nonew ' '
        }
    }

    Write-host
    [array]::reverse($pointers)
    $pointers | % {
        for ($i = 0; $i -lt $_.Padding; $i++) {
            $barGroup = $pointers |? Padding -eq $i
            if ($barGroup) {
                Write-Host -nonew '|' -ForegroundColor  $barGroup.Color
            }
            else {
                Write-Host -nonew ' '
            }
        }
        Write-Host $_.Name -ForegroundColor $_.Color
    }
}