param([string]$VMNameStr)
# Trim whitepsace on input string,
# then split at commas (surrounded by 0 or more whitespace chars on each side)
$VMNameStr.Trim() -split "\s*,\s*"
