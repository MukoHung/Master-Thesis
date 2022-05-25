<#
Author: Alex Asplund

Description:
Will perform a series of health checks on AD.

Designed to be ran on a Domain Controller as a Domain Admin
Uses WSMAN, LDAP, RPC etc to speak to other DomainControllers.

#>

# Setting(s)
# Group with members to check for token bloat
# WARNING: Takes a loooooong time per user.
$BloatedTokenGroup = "MyAdmins"

########################################

Class AdhcResult {
    [string]$Source
    [string]$TestName
    [bool]$Pass
    $Was
    $ShouldBe
    [string]$Category
    [string]$Message
    $Data
    [string[]]$Tags

}

Function New-AdhcResult {
    [cmdletbinding()]
    param(
        # Source of the result. The computer that was tested
        [parameter(ValueFromPipelineByPropertyName)]
        [string]$Source = $env:COMPUTERNAME,

        # Name of the test
        [parameter(Mandatory,ValueFromPipelineByPropertyName)]
        [string]$TestName,

        # True = Test pass
        [parameter(Mandatory,ValueFromPipelineByPropertyName)]
        [bool]$Pass,

        [parameter(ValueFromPipelineByPropertyName)]
        $Was,

        [parameter(ValueFromPipelineByPropertyName)]
        $ShouldBe,

        # General category of the test. Like "Directory Services" or "DNS"
        [parameter(Mandatory,ValueFromPipelineByPropertyName)]
        [string]$Category,

        # Tags for this test like "Security", "Updates", "Logon"
        [parameter(Mandatory,ValueFromPipelineByPropertyName)]
        [string[]]$Tags,
        
        # General message
        [parameter(ValueFromPipelineByPropertyName)]
        [string]$Message,

        # Extra data to the test result. Like accountnames or SPN's etc.
        [parameter(ValueFromPipelineByPropertyName)]
        $Data

    )

    Begin {

    }

    Process {
        [AdhcResult]@{
            Source = $Source
            TestName = $TestName
            Pass = $Pass
            Was = $Was
            ShouldBe = $ShouldBe
            Category = $Category
            Message = $Message
            Data = $Data
            Tags = $Tags
        }
    }
    End { }
}

# DCDIAG

Function Test-AdhcDCDiag {
    [cmdletbinding()]
    param(
        # Name of the DC
        [parameter(ValueFromPipeline)]
        [string]$ComputerName,

        # What DCDiag tests would you like to run?
        [ValidateSet(
            "All",
            "Advertising",
            "DNS",
            "NCSecDesc",
            "KccEvent",
            "Services",
            "NetLogons",
            "CrossRefValidation",
            "CutoffServers",
            "CheckSecurityError",
            "Intersite",
            "CheckSDRefDom",
            "Connectivity",
            "SysVolCheck",
            "Replications",
            "ObjectsReplicated",
            "DcPromo",
            "RidManager",
            "Topology",
            "MachineAccount",
            "LocatorCheck",
            "OutboundSecureChannels",
            "RegisterInDNS",
            "VerifyEnterpriseReferences",
            "KnowsOfRoleHolders",
            "VerifyReplicas",
            "VerifyReferences"
        )]
        [string[]]$Tests = "All",

        # Excluded tests
        [ValidateSet(
            "Advertising",
            "DNS",
            "NCSecDesc",
            "KccEvent",
            "Services",
            "NetLogons",
            "CrossRefValidation",
            "CutoffServers",
            "CheckSecurityError",
            "Intersite",
            "CheckSDRefDom",
            "Connectivity",
            "SysVolCheck",
            "Replications",
            "ObjectsReplicated",
            "DcPromo",
            "RidManager",
            "Topology",
            "MachineAccount",
            "LocatorCheck",
            "OutboundSecureChannels",
            "RegisterInDNS",
            "VerifyEnterpriseReferences",
            "KnowsOfRoleHolders",
            "VerifyReplicas",
            "VerifyReferences"
        )]
        [string[]]$ExcludedTests
        
    )
    Begin {

        $DCDiagTests = @{
            Advertising = @{}
            CheckSDRefDom = @{}
            CheckSecurityError = @{
	            ExtraArgs = @(
                    "/replsource:$((Get-ADDomainController -Filter *).HostName | ? {$_ -notmatch $env:computername} | Get-Random)"
                )
            }
            Connectivity = @{}
            CrossRefValidation = @{}
            CutoffServers = @{}
            DcPromo = @{
	            ExtraArgs = @(
                    "/ReplicaDC",
                    "/DnsDomain:$((Get-ADDomain).DNSRoot)",
                    "/ForestRoot:$((Get-ADDomain).Forest)"
                )
            }
            DNS = @{}
            SysVolCheck = @{}
            LocatorCheck = @{}
            Intersite = @{}
            KccEvent = @{}
            KnowsOfRoleHolders = @{}
            MachineAccount = @{}
            NCSecDesc = @{}
            NetLogons = @{}
            ObjectsReplicated = @{}
            OutboundSecureChannels = @{}
            RegisterInDNS = @{
	            ExtraArgs = "/DnsDomain:$((Get-ADDomain).DNSRoot)"
            }
            Replications = @{}
            RidManager = @{}
            Services = @{}
            Topology = @{}
            VerifyEnterpriseReferences = @{}
            VerifyReferences = @{}
            VerifyReplicas = @{}
        }

        $TestsToRun = $DCDiagTests.Keys | Where-Object {$_ -notin $ExcludedTests}

        If($Tests -ne 'All'){
            $TestsToRun = $Tests
        }
        
        if(($Tests | Measure-Object).Count -gt 1 -and $Tests -contains "All"){
            Write-Error "Invalid Tests parameter value: You can't use 'All' with other tests." -ErrorAction Stop
        }

        Write-Verbose "Executing tests: $($DCDiagTests.Keys -join ", ")"
    }
    Process {
        if(![string]::IsNullOrEmpty($ComputerName)) {
             $ServerArg = "/s:$ComputerName"
        }
        else {
            $ComputerName = $env:COMPUTERNAME
            $ServerArg = "/s:$env:COMPUTERNAME"
        }
        
        Write-Verbose "Starting DCDIAG on $ComputerName"



        $TestResults = @()

        $TestsToRun | Foreach {
            Write-Verbose "Starting test $_ on $ComputerName"

            $TestName = $_
            $ExtraArgs = $DCDiagTests[$_].ExtraArgs

            
            if($_ -in @("DcPromo", "RegisterInDNS")){
                if($env:COMPUTERNAME -ne $ComputerName){

                    Write-Verbose "Test cannot be performed remote, invoking dcdiag"
                    $Output = Invoke-Command -ComputerName $ComputerName -ArgumentList @($TestName,$ExtraArgs) -ScriptBlock {
                        $TestName = $args[0]
                        $ExtraArgs = $args[1]
                        dcdiag /test:$TestName $ExtraArgs
                    }
                }
                else {
                    $Output = dcdiag /test:$TestName $ExtraArgs
                }
            }
            else {
                $Output = dcdiag /test:$TestName $ExtraArgs $ServerArg    
            }
            

            $Fails = ($Output | Select-String -AllMatches -Pattern "fail" | Measure-Object).Count
            $Passes = ($Output | Select-String -AllMatches -Pattern "passed" | Measure-Object).Count 
            $Pass = ($Fails -eq 0 -and $Passes -gt 0)
            $ResultSplat = @{
                Source = $ComputerName
                TestName = "$_"
                Pass = ($Fails -eq 0 -and $Passes -gt 0)
                Was = $Fails,$Passes
                ShouldBe = 0,0
                Category = "DCDIAG"
                Message = $Output[-1]
                Data = $Output
                Tags = @('DCDIAG',$_)
            }

            New-AdhcResult @ResultSplat
        }
        $TestResults

    }
    End {

    }
}

$TestResults = @()

# Get all DCs
$DomainControllers = (Get-ADDomainController -Filter *).Name

#####################################
# Start domain wide dcdiag
#####################################
$DCDiagDomainTests = @(
    "CheckSDRefDom",
    "ObjectsReplicated",
    "NCSecDesc",
    "DNS",
    "DCPromo",
    "CrossRefValidation"
)

$TestResults += Test-AdhcDCDiag -Tests $DCDiagDomainTests

#####################################
# DC specific tests 
#####################################

$DCTests = @(
    "Advertising",
    "CheckSecurityError",
    "CutoffServers",
    "Intersite",
    "KccEvent",
    "KnowsOfRoleHolders",
    "LocatorCheck",
    "MachineAccount",
    "NetLogons",
    "RegisterInDNS",
    "Replications",
    "RidManager",
    "Services",
    "SysVolCheck",
    "Topology",
    "VerifyReferences",
    "VerifyReplicas"
)
$TestResults += $DomainControllers | Test-AdhcDCDiag -Tests $DCTests -Verbose


#####################################
# Test DFSR event logs for errors
#####################################

# Collect them as a job
$Job = Invoke-Command -AsJob -ComputerName $DomainControllers -ScriptBlock {
    $Events = Get-EventLog -LogName "DFS Replication" -EntryType Error -After (get-date).AddDays(-1)
    
    $Filter = {$_.EventId -ne 5014 -and $_.ReplacementStrings[6] -ne 9036}
    $Events | Where-Object $Filter 
}

$Job | Wait-Job
$Logs = $Job | Receive-Job | Group PSComputerName


$Logs | Foreach {
    $ErrorCount = ($_.Group | Measure-Object).Count
    $ResultSplat = @{
        Source = $_.Name
        TestName = "DfsrEvent"
        Pass = $ErrorCount -eq 0
        Was = $ErrorCount
        ShouldBe = 0
        Category = "EventLog"
        Message = "Dfsr log errors"
        Data = $_.group
        Tags = @('Sysvol','Event')
    }

    $TestResults += New-AdhcResult @ResultSplat
}

$DomainControllers | ? {$_ -notin $Logs.Name} | Foreach {
    $ResultSplat = @{
        Source = $_
        TestName = "DfsrEvent"
        Pass = $True
        Was = 0
        ShouldBe = 0
        Category = "EventLog"
        Message = "Dfsr log errors"
        Data = $_.group
        Tags = @('Sysvol','Event')
    }

    $TestResults += New-AdhcResult @ResultSplat
}

#####################################
# Test system event logs for errors
#####################################

# Collect them as a job
$Job = Invoke-Command -AsJob -ComputerName $DomainControllers -ScriptBlock {
    $Filter = {
        # Filter out computers unable to contact domain because they're removed or disabled
        ($_.Source -eq 'NetLogon' -and $_.eventid -notin @(5805,5723, 5722)) -and
        
        # Filter TGS/TGT events
        ($_.Source -ne 'KDC' -and $_.EventId -notin @(16,11)) -and
        
        # Filter out DCOM errors
        ($_.Source -ne "DCOM" -and $_.EventId -ne 10016)
    
    }
    $Errors = Get-EventLog -ComputerName $ComputerName -LogName "System" -EntryType Error -After (Get-Date).AddDays(-1)
    $Errors | Where-Object $Filter
}

$Job | Wait-Job
$Logs = $Job | Receive-Job | Group PSComputerName

$Logs | Foreach {
    $ErrorCount = ($_.Group | Measure-Object).Count
    $ResultSplat = @{
        Source = $_.Name
        TestName = "SystemEvent"
        Pass = $ErrorCount -eq 0
        Was = $ErrorCount
        ShouldBe = 0
        Category = "EventLog"
        Message = "System log errors"
        Data = $_.group
        Tags = @('System','Event')
    }

    $TestResults += New-AdhcResult @ResultSplat
}

$DomainControllers | ? {$_ -notin $Logs.Name} | Foreach {
    $ResultSplat = @{
        Source = $_
        TestName = "SystemEvent"
        Pass = $True
        Was = 0
        ShouldBe = 0
        Category = "EventLog"
        Message = "System log errors"
        Data = $_.group
        Tags = @('System','Event')
    }

    $TestResults += New-AdhcResult @ResultSplat
}


#####################################
# Test for duplicate UPN
#####################################

# Get all AD-objects containing a UPN
$ADUserPrincipalNames = (Get-ADObject -LDAPFilter "UserPrincipalName=*" -Properties UserPrincipalName).UserPrincipalName

# Create the hashtable
$UPNCount = @{}

# Loop through all UPN's and +1 on their key in the hashtable
$ADUserPrincipalNames | foreach {
    $UPNCount["$_"]++
}

# Get all UPN's where value -gt 1
$DuplicateUPNs = $ADUserPrincipalNames | Where-Object {$UPNCount["$_"] -gt 1} | Select-Object -Unique
$DuplicateCount = ($DuplicateUPNs | Measure-Object).Count

$ResultSplat = @{
    Source = "Directory"
    TestName = "DuplicateUPN"
    Pass = $DuplicateCount -eq 0
    Was = $DuplicateCount
    ShouldBe = 0
    Category = "Duplicate Attributes"
    Message = ""
    Data = $DuplicateUPNs
    Tags = @('Attributes','UPN','UserPrincipalName')
}

$TestResults += New-AdhcResult @ResultSplat

#####################################
# Check for duplicate 
#####################################

# Get all objects containting SPN's
$ServicePrincipalNames = (Get-ADObject -LDAPFilter "ServicePrincipalName=*" -Properties ServicePrincipalName).ServicePrincipalName

# Create hashtable
$SPNCount = @{}

# Loop through all SPN's and increment on it's hashtable key
$ServicePrincipalNames | Foreach {
    $SPNCount["$_"]++
}

# Get all SPN's where value -gt 1
$DuplicateSPNs = $ServicePrincipalNames | Where-Object {$SPNCount["$_"] -gt 1} | Select-Object -Unique

$DuplicateCount = ($DuplicateSPNCount | Measure-Object).Count

$ResultSplat = @{
    Source = "Directory"
    TestName = "DuplicateSPNs"
    Pass = $DuplicateCount -eq 0
    Was = $DuplicateCount
    ShouldBe = 0
    Category = "Duplicate Attributes"
    Message = ""
    Data = $DuplicateSPNs
    Tags = @('Attributes','SPN','ServicePrincipalNames')
}

$TestResults += New-AdhcResult @ResultSplat


#####################################
# Check for duplicate mail
#####################################

# Get all AD objects containing mail-attribute
$MailAttributes = (Get-ADObject -LDAPFilter "mail=*" -Properties mail).mail

# Create hashtable
$MailCount = @{}

# Increment key
$MailAttributes | Foreach {
    $MailCount["$_"]++
}

# Get all mail's where value -gt 1
$DuplicateMail = $MailAttributes | ? {$MailCount["$_"] -gt 1}

$DuplicateCount = ($DuplicateMail | Measure-Object).Count

$ResultSplat = @{
    Source = "Directory"
    TestName = "DuplicateMail"
    Pass = $DuplicateCount -eq 0
    Was = $DuplicateCount
    ShouldBe = 0
    Category = "Duplicate Attributes"
    Message = ""
    Data = $DuplicateMail
    Tags = @('Attributes','Mail')
}

$TestResults += New-AdhcResult @ResultSplat

#####################################
# Check for duplicate ProxyAddresses
#####################################

# Get all objects containing ProxyAddresses
$ProxyAddresses = (Get-ADObject -LDAPFilter "ProxyAddresses=*" -Properties ProxyAddresses).ProxyAddresses

# Create hashtable
$ProxyAddressCount = @{}

# Increment key
$ProxyAddresses | Foreach {$ProxyAddressCount["$_"]++}

# Get all ProxyAddresses where value -gt 1
$DuplicateProxyAddresses = $ProxyAddresses | ? {$ProxyAddressCount["$_"] -gt 1}

$DuplicateCount = ($DuplicateProxyAddresses | Measure-Object).Count

$ResultSplat = @{
    Source = "Directory"
    TestName = "DuplicateProxyAddresses"
    Pass = $DuplicateCount -eq 0
    Was = $DuplicateCount
    ShouldBe = 0
    Category = "Duplicate Attributes"
    Message = ""
    Data = $DuplicateProxyAddresses
    Tags = @('Attributes','ProxyAddresses')
}

$TestResults += New-AdhcResult @ResultSplat

#####################################
# Check for bloated tokens
#####################################

# WARNING: This will take an extremely long time and will be resource intensive
# You might want to limit a regular run to admins only and run through on the whole domain once in a while.
$UserDNs = (Get-ADGroup -Identity $BloatedTokenGroup -Properties members).Members

$TokenSizes = @()

Foreach($UserDN in $UserDNs) {

    # Get all nested groups using LDAP_IN_CHAIN (1.2.840.113556.1.4.1941)
    $Groups = Get-ADGroup -LDAPFilter "(member:1.2.840.113556.1.4.1941:=$UserDN)" -Properties sIDHistory
    
    $Object = [PSCustomObject]@{
        DistinguishedName = $UserDN
        UserTokenSize = 1200
    }

    foreach ($Group in $Groups){
        if ($Group.SIDHistory.Count -ge 1){
            # Groups with sidhistory always counts as +40
            $Object.TokenSize = 40
        }
        switch($Group.GroupScope){
            'Global' {$Object.UserTokenSize+=8}
            'Universal' {$Object.UserTokenSize+=8}
            'DomainLocal' {$Object.UserTokenSize+=40}
        }
    }

    $TokenSizes += $Object
}


# Max default token size for 2012R2 is 48000
$BloatedTokens = $TokenSizes | ? {$_.UserTokenSize -gt 48000}
$BloatedTokenCount = ($BloatedTokens | Measure-Object).Count

$ResultSplat = @{
    Source = "Directory"
    TestName = "BloatedTokens"
    Pass = $BloatedTokenCount -eq 0
    Was = $BloatedTokenCount
    ShouldBe = 0
    Category = "Kerberos"
    Message = ""
    Data = $BloatedTokens
    Tags = @('Groups','Tokens','Kerberos')
}

$TestResults += New-AdhcResult @ResultSplat

#####################################
# Check for no client site
#####################################

$Job = Invoke-Command -AsJob -ComputerName $DomainControllers -ScriptBlock {
    $NetLogonLog = Import-Csv "$env:SystemRoot\Debug\netlogon.log" -Delimiter " " -Header Date,Time,Pid,Domain,Message,ComputerName,IpAddress
    $NoClientSite = $NetlogonLog | Where-Object Message -eq "NO_CLIENT_SITE:" | Select ComputerName,IpAddress

    Return $NoClientSite
}

$Job | Wait-Job

$NoClientSiteResults = $Job | Receive-Job | Select-Object ComputerName,IpAddress
$NoClientSiteCount = ($NoClientSiteResults | Measure-Object).Count

Remove-Variable -Name NoClientSiteResults


$ResultSplat = @{
    Source = "Directory"
    TestName = "NoClientSite"
    Pass = $NoClientSiteCount -eq 0
    Was = $NoClientSiteCount
    ShouldBe = 0
    Category = "NetLogon"
    Message = ""
    Data = $NoClientSiteResults
    Tags = @('Netlogon','Sites')
}

$TestResults += New-AdhcResult @ResultSplat

#####################################
# Check for unlinked GPO's
#####################################

[xml]$GPOXmlReport = Get-GPOReport -All -ReportType Xml
$UnlinkedGPOs = ($GPOXmlReport.GPOS.GPO | Where-Object {$_.LinksTo -eq $null}).Name

$UnlinkedGPOCount = ($UnlinkedGPOs | Measure-Object).Count

$ResultSplat = @{
    Source = "Directory"
    TestName = "UnlinkedGPO"
    Pass = $UnlinkedGPOCount -eq 0
    Was = $UnlinkedGPOCount
    ShouldBe = 0
    Category = "Group Policy"
    Message = ""
    Data = $UnlinkedGPOs
    Tags = @('Group Policy')
}

$TestResults += New-AdhcResult @ResultSplat

#####################################
# Check GPO's containing cPassword
#####################################

$Path = "C:\Windows\SYSVOL\domain\Policies\"

# Get all GPO XMLs
$XMLs = Get-ChildItem $Path -recurse -Filter *.xml

# GPO's containing cpasswords
$cPasswordGPOs = @()

# Loop through all XMLs and use regex to parse out cpassword
# Return GPO display name if it returns
Foreach($XMLFile in $XMLs){
    $Content = Get-Content -Raw -Path $XMLFile.FullName
    if($Content.Contains("cpassword")){

        [string]$CPassword = [regex]::matches($Content,'(cpassword=).+?(?=\")')
        $CPassword = $CPassword.split('(\")')[1]
        if($CPassword){
            [string]$GPOguid = [regex]::matches($XMLFile.DirectoryName,'(?<=\{).+?(?=\})')
            $GPODetail = Get-GPO -guid $GPOguid
            $cPasswordGPOs += $GPODetail.DisplayName   
        }
    }
}

$cPasswordGPOsCount = ($cPasswordGPOs | Measure-Object).Count
$ResultSplat = @{
    Source = "Directory"
    TestName = "GPOContainingCPassword"
    Pass = $cPasswordGPOsCount -eq 0
    Was = $cPasswordGPOsCount
    ShouldBe = 0
    Category = "Group Policy"
    Message = "GPO's containing cPassword can easily be decrypted and used"
    Data = $cPasswordGPOs
    Tags = @('Group Policy','cPassword','Security')
}

$TestResults += New-AdhcResult @ResultSplat