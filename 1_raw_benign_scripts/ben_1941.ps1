# Install package
Write-Host -ForegroundColor green "Installing package..."
& sfdx force:package:install -p [package id] -u $orgName -s AllUsers -r -w 10 -k [package password]
if ($LASTEXITCODE -ne 0) {
	exit 1
}
Write-Host ""