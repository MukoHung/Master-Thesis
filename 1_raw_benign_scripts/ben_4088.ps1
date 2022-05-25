<#
	.Synopsis
		Runs through a full test of the scripts against the AEC sample data for NT.
		Data is loaded into the database 'ElectoralAnalysisTest'.

	.Example
	    .\Test-AESampleData.ps1
		
#>
[CmdletBinding(SupportsShouldProcess=$false)]
param
(
	[string] $Database = "ElectoralAnalysisTest"
)
Set-StrictMode -Version Latest
$scriptRoot = $MyInvocation.MyCommand.Path | Split-Path
if ($PSCmdlet.MyInvocation.BoundParameters["ErrorAction"] -eq $null) {
  $ErrorActionPreference = 'Stop' # use default Stop, instead of Continue
}
if ($PSCmdlet.MyInvocation.BoundParameters["Verbose"] -eq $null) {
  $VerbosePreference = 'Continue' # use default Continue, instead of SilentlyContinue
}
$commonParameters = @{
	"Verbose" = ($PSCmdlet.MyInvocation.BoundParameters["Verbose"] -eq $true);
	"Debug" = ($PSCmdlet.MyInvocation.BoundParameters["Debug"] -eq $true)
}

Write-Host "`nRunning all scripts to load data for NT into '$Database'. This may take a while.`n"

.\Initialize-AEDatabase.ps1 -Database $Database -DeleteExisting -Confirm:$false

Set-Location $scriptRoot

.\Update-AEPartyLookup.ps1 -Database $Database -FilePath ".\PartyLookup.csv"

# NT 2013

.\Import-AERepresentativesTicket.ps1 -Database $Database -Election "2013 Federal" -FilePath "..\SampleData\2013\HouseCandidatesDownload-17496.csv"

.\Import-AERepresentativesVotes.ps1 -Database $Database -Election "2013 Federal" -State "NT" -FilePath "..\SampleData\2013\HouseStateFirstPrefsByPollingPlaceDownload-17496-NT.csv"

.\Import-AESenateTicket.ps1 -Database $Database -Election "2013 Federal" -FilePath "..\SampleData\2013\SenateFirstPrefsByStateByVoteTypeDownload-17496.csv"

.\Import-AESenateVotes2013.ps1 -Database $Database -Election "2013 Federal" -State "NT" -FilePath "..\SampleData\2013\SenateStateFirstPrefsByPollingPlaceDownload-17496-NT.csv"

.\Invoke-AETransformData.ps1 -Database $Database

# NT 2016

.\Import-AERepresentativesTicket.ps1 -Database $Database -Election "2016 Federal" -FilePath "..\SampleData\2016\HouseCandidatesDownload-20499.csv"

.\Import-AERepresentativesVotes.ps1 -Database $Database -Election "2016 Federal" -State "NT" -FilePath "..\SampleData\2016\HouseStateFirstPrefsByPollingPlaceDownload-20499-NT.csv"

.\Import-AESenateTicket.ps1 -Database $Database -Election "2016 Federal" -FilePath "..\SampleData\2016\SenateFirstPrefsByStateByVoteTypeDownload-20499.csv"

.\Import-AESenateVotes2016.ps1 -Database $Database -Election "2016 Federal" -State "NT" -FilePath "..\SampleData\2016\aec-senate-formalpreferences-20499-NT.csv"

.\Invoke-AETransformData.ps1 -Database $Database

# NT 2019

.\Import-AERepresentativesTicket.ps1 -Database $Database -Election "2019 Federal" -FilePath "..\SampleData\2019\HouseCandidatesDownload-24310.csv"

.\Import-AESenateTicket.ps1 -Database $Database -Election "2019 Federal" -FilePath "..\SampleData\2019\SenateFirstPrefsByStateByVoteTypeDownload-24310.csv"

.\Get-AEMissingPartyLookup -Database $Database
# .\Get-AEMissingPartyLookup -Database $Database | Export-Csv NewPartyNames.csv

.\Import-AERepresentativesVotes.ps1 -Database $Database -Election "2019 Federal" -State "NT" -FilePath "..\SampleData\2019\HouseStateFirstPrefsByPollingPlaceDownload-24310-NT.csv"

.\Invoke-AETransformData.ps1 -Database $Database

.\Import-AESenateVotes2019.ps1 -Database $Database -Election "2019 Federal" -State "NT" -FilePath "..\SampleData\2019\aec-senate-formalpreferences-24310-NT.csv"

.\Invoke-AETransformData.ps1 -Database $Database



