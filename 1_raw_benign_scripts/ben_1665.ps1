<#
.SYNOPSIS
	Get-M365LicenseNamesFromGlueSniffingCSVFile.ps1
.DESCRIPTION
	Downloads CSV file from Microsoft, opens tube of model glue, sniffs it until 
	the entire tube is empty and dried up, then users the vapors to do a lookup 
	of information using the output from Get-MsolAccountSku properties as the input.
	No tubes of glue were harmed in the making of this script.
.PARAMETER LicenseSku
	SkuPartNumber from Get-MsolAccountSku output
.OUTPUTS
	Returns the CSV row for the matching LicenseSku name
.EXAMPLE
	Get-M365LicenseNameFromGlueSniffingCSVFile.ps1 -LicenseSku 'EXCHANGEENTERPRISE'
	
	Returns:

	Product_Display_Name                  : EXCHANGE ONLINE (PLAN 2)
	String_ Id                            : EXCHANGEENTERPRISE
	GUID                                  : 19ec0d23-8335-4cbd-94ac-6050e30712fa
	Service_Plan_Name                     : EXCHANGE_S_ENTERPRISE
	Service_Plan_Id                       : efb87545-963c-4e0d-99df-69c6916d9eb0
	Service_Plans_Included_Friendly_Names : EXCHANGE ONLINE (PLAN 2)
.NOTES
	If Microsoft modifies either the CSV file format, or the URL, this script will 
	self-destruct and may require additional use of alcohol.

	1.0.0.0 - 2022-01-21 - Skatterbrainz Imploding Extrapolation Services
#>
[CmdletBinding()]
[OutputType()]
param (
	[parameter(Mandatory=$True)][ValidateNotNullOrEmpty()][string]$LicenseSku
)

try {
	[string]$url = "https://download.microsoft.com/download/e/3/e/e3e9faf2-f28b-490a-9ada-c6089a1fc5b0/Product%20names%20and%20service%20plan%20identifiers%20for%20licensing.csv"
	[string]$csvFile = "$env:TEMP\m365licensedata.csv"
	if (Test-Path $csvFile) {
		Remove-Item -Path $csvFile -Force
	}
	(New-Object system.net.webclient).DownloadFile($url, $csvFile) | Out-Null
	if (Test-Path $csvFile) {
		$csvData = Import-Csv -Path $csvFile
		$result = $csvdata | Where-Object {$_.'String_ Id' -eq $LicenseSku}
		Get-Item -Path $csvFile | Remove-Item -Force -ErrorAction SilentlyContinue
	} else {
		throw "Failed to download file from source"
	}
}
catch {
	Write-Output $_.Exception
}
finally {
	$result
}