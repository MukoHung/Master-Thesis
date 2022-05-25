# Assign permission set
Write-Host -ForegroundColor green "Assigning permission set..."
& sfdx force:user:permset:assign --permsetname [permission set name] -u $orgName
if ($LASTEXITCODE -ne 0) {
	exit 1
}
Write-Host ""