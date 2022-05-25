# Understanding the Pipeline Variable ($_)

# References
# Arrays: https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_arrays?view=powershell-7.1
# Hashtables: https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_hash_tables?view=powershell-7.1
# Simple iteration with '$_': https://stackoverflow.com/questions/3494115/what-does-mean-in-powershell

# Setup some basic data structures
$array = "alpha", "bravo", "charlie", "delta"

# # Iterate over a simple array
Write-Output ""
Write-Output "Iterating over array with simple foreach"
foreach($a in $array) {
    Write-Output "writing out... $a"
}
