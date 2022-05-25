# Populate test data
Write-Host -ForegroundColor green "Creating test data..."
& sfdx force:data:tree:import -u $orgName --plan [json data file]
if ($LASTEXITCODE -ne 0) {
	exit 1
}
Write-Host ""