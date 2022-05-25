#requires -version 5.1
#requires -module GroupPolicy,ActiveDirectory

Function Get-GPLink {
<#
.Synopsis
Get Group Policy Object links
.Description
This command will display the links to existing Group Policy objects. You can filter for enabled or disabled links. The default user domain is queried although you can specify an alternate domain and/or a specific domain controller. There is no provision for alternate credentials.

The command writes a custom object to the pipeline. There are associated custom table views you can use. See examples.
.Parameter Name
Enter a GPO name. Wildcards are allowed. This parameter has an alias of gpo.
.Parameter Server
Specify the name of a specific domain controller to query.
.Parameter Domain
Enter the name of an Active Directory domain. The default is the current user domain. Your credentials must have permission to query the domain. Specify the DNS domain name, i.e. company.com
.Parameter Enabled
Only show links that are enabled.
.Parameter Disabled
Only show links that are Disabled.

.Example
PS C:\> Get-GPLink

Target                                  DisplayName                       Enabled Enforced Order
------                                  -----------                       ------- -------- -----
dc=company,dc=pri                       Default Domain Policy             True    True         1
dc=company,dc=pri                       PKI AutoEnroll                    True    False        2
ou=domain controllers,dc=company,dc=pri Default Domain Controllers Policy True    False        1
ou=it,dc=company,dc=pri                 Demo 2                            True    False        1
ou=dev,dc=company,dc=pri                Demo 1                            True    False        1
ou=dev,dc=company,dc=pri                Demo 2                            False   False        2
ou=sales,dc=company,dc=pri              Demo 1                            True    False        1
...

If you are running in the console, False values under Enabled will be displayed in red. Enforced values that are True will be displayed in Green.
.Example
PS C:\> Get-GPLink -Disabled

Target                             DisplayName Enabled Enforced Order
------                             ----------- ------- -------- -----
ou=dev,dc=company,dc=pri           Demo 2      False   False        2
ou=foo\,bar demo,dc=company,dc=pri Gladys      False   False        1

Get disabled Group Policy links.

.Example
PS C:\> Get-GPLink gladys | get-gpo

DisplayName      : Gladys
DomainName       : Company.Pri
Owner            : COMPANY\Domain Admins
Id               : 7551c3d8-99fa-4bc6-85a2-bd650124f11a
GpoStatus        : AllSettingsEnabled
Description      :
CreationTime     : 1/11/2021 2:34:37 PM
ModificationTime : 1/11/2021 2:34:38 PM
UserVersion      : AD Version: 0, SysVol Version: 0
ComputerVersion  : AD Version: 0, SysVol Version: 0
WmiFilter        :

.Example
PS C:\>  Get-GPLink | Where TargetType -eq "domain"

Target            DisplayName           Enabled Enforced Order
------            -----------           ------- -------- -----
dc=company,dc=pri Default Domain Policy True    True         1
dc=company,dc=pri PKI AutoEnroll        True    True         2

Other possible TargetType values are OU and Site.

.Example
PS C:\>  Get-GPLink | sort Target | Format-Table -view link


   Target: dc=company,dc=pri

DisplayName                         Enabled    Enforced    Order
-----------                         -------    --------    -----
PKI AutoEnroll                      True       False           2
Default Domain Policy               True       True            1


   Target: ou=dev,dc=company,dc=pri

DisplayName                         Enabled    Enforced    Order
-----------                         -------    --------    -----
Demo 1                              True       False           1
Demo 2                              False      False           2
...

.Example
PS C:\> Get-GPLink | Sort TargetType | Format-Table -view targetType

   TargetType: Domain

Target                          DisplayName                  Enabled    Enforced     Order
------                          -----------                  -------    --------     -----
dc=company,dc=pri               PKI AutoEnroll               True       True             2
dc=company,dc=pri               Default Domain Policy        True       True             1


   TargetType: OU

Target                            DisplayName                Enabled    Enforced     Order
------                            -----------                -------    --------     -----
ou=accounting,dc=company,dc=pri   Accounting-dev-test-foo    True       False            1
ou=sales,dc=company,dc=pri        Demo 1                     True       False            1
...

.Example
PS C:\> Get-GPLink | Sort Name | Format-Table -view gpo


   DisplayName: Default Domain Controllers Policy

Target                                        Enabled    Enforced    Order
------                                        -------    --------    -----
ou=domain controllers,dc=company,dc=pri       True       False           1


   DisplayName: Default Domain Policy

Target                                        Enabled    Enforced    Order
------                                        -------    --------    -----
dc=company,dc=pri                             True       True            1


   DisplayName: Demo 1

Target                                        Enabled    Enforced    Order
------                                        -------    --------    -----
ou=dev,dc=company,dc=pri                      True       False           1
CN=Default-First-Site-Name,cn=Sites,CN=Config True       True            2
uration,DC=Company,DC=Pri
...
.Example
PS C:\> Get-GPLink | Format-Table -GroupBy Domain -Property Link,GPO,Enabled,Enforced

   Domain: Company.Pri

Link                                    GPO                               Enabled Enforced
----                                    ---                               ------- --------
dc=company,dc=pri                       Default Domain Policy                True     True
dc=company,dc=pri                       PKI AutoEnroll                       True    False
ou=domain controllers,dc=company,dc=pri Default Domain Controllers Policy    True    False
ou=it,dc=company,dc=pri                 Demo 2                               True    False
ou=dev,dc=company,dc=pri                Demo 1                               True    False
ou=dev,dc=company,dc=pri                Demo 2                              False    False
ou=sales,dc=company,dc=pri              Demo 1                               True    False
ou=foo\,bar demo,dc=company,dc=pri      Gladys                              False    False
ou=foo\,bar demo,dc=company,dc=pri      Demo 2                               True    False
.Link
Get-GPO
.Link
Set-GPLink
.Inputs
System.String
.Notes
Learn more about PowerShell: http://jdhitsolutions.com/blog/essential-powershell-resources/

    #>
    [cmdletbinding(DefaultParameterSetName = "All")]
    [outputtype("myGPOLink")]
    Param(
        [parameter(Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName, HelpMessage = "Enter a GPO name. Wildcards are allowed")]
        [alias("gpo")]
        [ValidateNotNullOrEmpty()]
        [string]$Name,
        [Parameter(HelpMessage = "Specify the name of a specific domain controller to query.")]
        [ValidateNotNullOrEmpty()]
        [string]$Server,
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string]$Domain,
        [Parameter(ParameterSetName = "enabled")]
        [switch]$Enabled,
        [Parameter(ParameterSetName = "disabled")]
        [switch]$Disabled
    )

    Begin {
        Write-Verbose "Starting $($myinvocation.mycommand)"
        #display some metadata information in the verbose output
        Write-Verbose "Running as $($env:USERDOMAIN)\$($env:USERNAME) on $($env:Computername)"
        Write-Verbose "Using PowerShell version $($psversiontable.PSVersion)"
        Write-Verbose "Using ActiveDirectory module $((Get-Module ActiveDirectory).version)"
        Write-Verbose "Using GroupPolicy module $((Get-Module GroupPolicy).version)"

        #define a helper function to get site level GPOs
        #It is easier for this task to use the Group Policy Management COM objects.
        Function Get-GPSiteLink {
            [cmdletbinding()]
            Param (
                [Parameter(Position = 0,ValueFromPipelineByPropertyName,ValueFromPipeline)]
                [alias("Name")]
                [string[]]$SiteName = "Default-First-Site-Name",
                [Parameter(Position = 1)]
                [string]$Domain,
                [string]$Server
            )

            Begin {
                Write-Verbose "Starting $($myinvocation.mycommand)"

                #define the GPMC COM Objects
                $gpm = New-Object -ComObject "GPMGMT.GPM"
                $gpmConstants = $gpm.GetConstants()

            } #Begin

            Process {
                $getParams = @{Current = "LoggedonUser"; ErrorAction = "Stop" }
                if ($Server) {
                    $getParams.Add("Server", $Server)
                }
                if ( -Not $PSBoundParameters.ContainsKey("Domain")) {
                    Write-Verbose "Querying domain"
                    Try {
                        $Domain = (Get-ADDomain @getParams).DNSRoot
                    }
                    Catch {
                        Write-Warning "Failed to query the domain. $($_.exception.message)"
                        #Bail out of the function since we need this information
                        return
                    }
                }

                Try {
                    $Forest = (Get-ADForest @getParams).Name
                }
                Catch {
                    Write-Warning "Failed to query the forest. $($_.exception.message)"
                    #Bail out of the function since we need this information
                    return
                }

                $gpmDomain = $gpm.GetDomain($domain, $server, $gpmConstants.UseAnyDC)
                foreach ($item in $siteName) {
                    #connect to site container
                    $SiteContainer = $gpm.GetSitesContainer($forest, $domain, $null, $gpmConstants.UseAnyDC)
                    Write-Verbose "Connected to site container on $($SiteContainer.domainController)"
                    #get sites
                    Write-Verbose "Getting $item"
                    $site = $SiteContainer.GetSite($item)
                    Write-Verbose "Found $($sites.count) site(s)"
                    if ($site) {
                        Write-Verbose "Getting site GPO links"
                        $links = $Site.GetGPOLinks()
                        if ($links) {
                            #add the GPO name
                            Write-Verbose "Found $($links.count) GPO link(s)"
                            foreach ($link in $links) {
                                [pscustomobject]@{
                                    GpoId       = $link.GPOId -replace ("{|}", "")
                                    DisplayName = ($gpmDomain.GetGPO($link.GPOID)).DisplayName
                                    Enabled     = $link.Enabled
                                    Enforced    = $link.Enforced
                                    Target      = $link.som.path
                                    Order       = $link.somlinkorder
                                } #custom object
                            }
                        } #if $links
                    } #if $site
                } #foreach site
            } #process

            End {
                Write-Verbose "Ending $($myinvocation.MyCommand)"
            } #end
        } #end function

    } #begin
    Process {
        Write-Verbose "Using these bound parameters"
        $PSBoundParameters | Out-String | Write-Verbose

        #use a generic list instead of an array for better performance
        $targets = [System.Collections.Generic.list[string]]::new()

        #use an internal $PSDefaultParameterValues instead of trying to
        #create parameter hashtables for splatting
        if ($Server) {
            $script:PSDefaultParameterValues["Get-AD*:Server"] = $server
            $script:PSDefaultParameterValues["Get-GP*:Server"] = $Server
        }

        if ($domain) {
            $script:PSDefaultParameterValues["Get-AD*:Domain"] = $domain
            $script:PSDefaultParameterValues["Get-ADDomain:Identity"] = $domain
            $script:PSDefaultParameterValues["Get-GP*:Domain"] = $domain
        }

        Try {
            Write-Verbose "Querying the domain"
            $mydomain = Get-ADDomain -ErrorAction Stop
            #add the DN to the list
            $targets.Add($mydomain.distinguishedname)
        }
        Catch {
            Write-Warning "Failed to get domain information. $($_.exception.message)"
            #bail out if the domain can't be queried
            Return
        }

        if ($targets) {
            #get OUs
            Write-Verbose "Querying organizational units"
            Get-ADOrganizationalUnit -Filter * |
            ForEach-Object { $targets.add($_.Distinguishedname) }

            #get all the links
            Write-Verbose "Getting GPO links from $($targets.count) targets"
            $links = [System.Collections.Generic.list[object]]::New()
            Try {
                ($Targets | Get-GPInheritance -ErrorAction Stop).gpolinks | ForEach-Object { $links.Add($_) }
            }
            Catch {
                Write-Warning "Failed to get GPO inheritance. If specifying a domain, be sure to use the DNS name. $($_.exception.message)"
                #bail out
                return
            }

            Write-Verbose "Querying sites"
            $getADO = @{
                LDAPFilter = "(Objectclass=site)"
                properties = "Name"
                SearchBase = (Get-ADRootDSE).ConfigurationNamingContext
            }
            $sites = (Get-ADObject @getADO).name
            if ($sites) {
                Write-Verbose "Processing $($sites.count) site(s)"
                #call the private helper function
                $sites | Get-GPSiteLink | ForEach-Object { $links.add($_) }
            }

            #filter for Enabled or Disabled
            if ($enabled) {
                Write-Verbose "Filtering for Enabled policies"
                $links = $links.where( { $_.enabled })
            }
            elseif ($Disabled) {
                Write-Verbose "Filtering for Disabled policies"
                $links = $links.where( { -Not $_.enabled })
            }

            if ($Name) {
                Write-Verbose "Filtering for GPO name like $name"
                #filter by GPO name using v4 filtering feature for performance
                $results = $links.where({ $_.displayname -like "$name" })
            }
            else {
                #write all the links
                Write-Verbose "Displaying ALL GPO Links"
                $results = $links
            }
            if ($results) {
                #insert a custom type name so that formatting can be applied
                $results.GetEnumerator().ForEach( { $_.psobject.TypeNames.insert(0, "myGPOLink") })
                $results
            }
            else {
                Write-Warning "Failed to find any GPO using a name like $Name"
            }
        } #if targets
    } #process
    End {
        Write-Verbose "Ending $($myinvocation.mycommand)"
    } #end
} #end function

#define custom type extensions
Update-TypeData -MemberType AliasProperty -MemberName GUID -Value GPOId -TypeName myGPOLink -Force
Update-TypeData -MemberType AliasProperty -MemberName Name -Value DisplayName -TypeName myGPOLink -Force
Update-TypeData -MemberType AliasProperty -MemberName GPO -Value DisplayName -TypeName myGPOLink -Force
Update-TypeData -MemberType AliasProperty -MemberName Link -Value Target -TypeName myGPOLink -Force
Update-TypeData -MemberType AliasProperty -MemberName Domain -Value GpoDomainName -TypeName myGPOLink -Force
Update-TypeData -MemberType ScriptProperty -MemberName TargetType -Value {
    switch -regex ($this.target) {
        "^((ou)|(OU)=)" { "OU" }
        "^((dc)|(DC)=)" { "Domain" }
        "^((cn)|(CN)=)" { "Site" }
        Default { "Unknown"}
    }
} -TypeName myGPOLink -Force

#define custom formatting
Update-FormatData $PSScriptRoot\mygpolink.format.ps1xml