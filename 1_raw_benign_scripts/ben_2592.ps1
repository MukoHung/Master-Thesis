# Check the working directory for modified files
# Exit with an error if there are any
$modified = git ls-files --modified
if ($modified -ne $null) {
    Write-Error "Working directory contains modified files: $modified"
    exit 1
}