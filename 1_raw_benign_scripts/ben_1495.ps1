function Find-File([string[]]$patterns, [string]$extension, [string] $joinPattern = "[\w|/|\\]*") {
    $regex = $patterns -join $joinPattern
    ls -r -i "*.$extension" | where { $_.Fullname -match $regex } |% { $_.Fullname }
}
Set-Alias -Name ff -Value Find-File

function Find-Solution([string[]]$patterns){
    Find-File -e sln $patterns
}