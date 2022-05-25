# Execute this on or against your Exchange Server:
# (Get-OwaVirtualDirectory).ExternalUrl.AbsoluteUri
[string]$ExchangeOWAURL = 'FILL_IN_THE_INFO'

# Execute this on or against your Exchange Server:
# (Get-EcpVirtualDirectory).ExternalUrl.AbsoluteUri
[string]$ExchangeECPURL = 'FILL_IN_THE_INFO'

<#
	Disclaimer:
	They use the same URL for internal and external access.
#>

# Create the new Rule
[string]$IssuanceAuthorizationRules = '@RuleTemplate = "AllowAllAuthzRule"

	=> issue(Type = "http://schemas.microsoft.com/authorization/claims/permit",
Value = "true");'

# Create the new Rule
[string]$IssuanceTransformRules = '@RuleName = "ActiveDirectoryUserSID"
	c:[Type == "http://schemas.microsoft.com/ws/2008/06/identity/claims/windowsaccountname", Issuer == "AD AUTHORITY"]

	=> issue(store = "Active Directory", types = ("http://schemas.microsoft.com/ws/2008/06/identity/claims/primarysid"), query = ";objectSID;{0}", param = c.Value); 

	@RuleName = "ActiveDirectoryUPN"
	c:[Type == "http://schemas.microsoft.com/ws/2008/06/identity/claims/windowsaccountname", Issuer == "AD AUTHORITY"] 

=> issue(store = "Active Directory", types = ("http://schemas.xmlsoap.org/ws/2005/05/identity/claims/upn"), query = ";userPrincipalName;{0}", param = c.Value);'

# Apply the new Rules
Add-ADFSRelyingPartyTrust -Name 'Outlook Web App' -Enabled $true -Notes ('This is a trust for {0}' -f $ExchangeOWAURL) -WSFedEndpoint $ExchangeOWAURL -Identifier $ExchangeOWAURL -IssuanceTransformRules $IssuanceTransformRules -IssuanceAuthorizationRules $IssuanceAuthorizationRules
Add-ADFSRelyingPartyTrust -Name 'Exchange Admin Center (EAC)' -Enabled $true -Notes ('This is a trust for {0}' -f $ExchangeECPURL) -WSFedEndpoint $ExchangeECPURL -Identifier $ExchangeECPURL -IssuanceTransformRules $IssuanceTransformRules -IssuanceAuthorizationRules $IssuanceAuthorizationRules