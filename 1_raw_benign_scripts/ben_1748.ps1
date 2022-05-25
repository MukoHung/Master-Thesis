[System.Net.WebRequest]::DefaultWebProxy.Credentials = [System.Net.CredentialCache]::DefaultCredentials 
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls11 -bor [System.Net.SecurityProtocolType]::Tls12   


<# 
    ** NOTE ** 
    Not all workflow will log default entries to a workflow history list (WHL). Unless the workflow logs 
    entries automatically (i.e an approval workflow) or the workflow explicitly logs to the WHL, this script
    will not report on workflow executions without WFH entires (I can't report on data that doesn't exist).  
#>

Import-Module SharePointPnPPowerShellOnline -WarningAction SilentlyContinue

<#
.SYNOPSIS
Gets the unique web urls (Site Url column) from the rows in ModernizationWorkflowScanResults.csv
   
.DESCRIPTION
Gets the unique web urls (Site Url column) from the rows in ModernizationWorkflowScanResults.csv

.PARAMETER ModernizationScannerRows
    

.EXAMPLE
Get-UniqueWebUrls -ModernizationScannerRows $modernizationScannerRows

.EXAMPLE
Get-WorkflowAssociationAggregations -ClientId $clientId -CertificatePath $certificatePath -CertificatePassword $certificatePassword -Tenant "$tenant.onmicrosoft.com" -CreatedAfter ([DateTime]::Today).AddDays(-90) -CsvPath $modernizationScannerCsvPath

.OUTPUTS
Array of strings containing the unique web urls

#>
function Get-UniqueWebUrls
{
    [cmdletbinding()]
    param
    (
        # This is the same as .Parameter
        [Parameter(Mandatory=$true)][object[]]$ModernizationScannerRows
    )
    
    Write-Verbose "$(Get-Date) - Getting unique web urls from moderization scanner output"

    $rows = @($modernizationScannerRows | SELECT -Unique "Site Url" | SELECT -ExpandProperty "Site Url")

    Write-Verbose "$(Get-Date) - Discovered $($rows.Count) unique web Urls."

    return $rows
}

<#
.SYNOPSIS

   Adds additional columns to the default columns created by the modernization scanner.
   
.DESCRIPTION

   Adds additional columns to the default columns created by the modernization scanner.

.EXAMPLE

    Add-SupplementalColumns -ModernizationScannerRows $modernizationScannerRows

.EXAMPLE

    Add-SupplementalColumns -ModernizationScannerRows $modernizationScannerRows -AddWorkflowAuthorAndEditorColumns

.EXAMPLE

    Add-SupplementalColumns -ModernizationScannerRows $modernizationScannerRows -AddPrimaryColumns

.EXAMPLE

    Add-SupplementalColumns -ModernizationScannerRows $modernizationScannerRows -AddListMetadataColumns

.OUTPUTS
   None
#>
function Add-SupplementalColumns
{
    [cmdletbinding()]
    param
    (
        [Parameter(Mandatory=$true)][object[]]$ModernizationScannerRows,
        [Parameter(Mandatory=$false)][switch]$AddWorkflowAuthorAndEditorColumns,
        [Parameter(Mandatory=$false)][switch]$AddPrimaryColumns,
        [Parameter(Mandatory=$false)][switch]$AddListMetadataColumns
    )

    process
    {
        Write-Verbose "$(Get-Date) - Adding additional columns to $($modernizationScannerRows.Count) scanner file rows."

        # add five extra properties to the original csv file objects
        foreach( $row in $modernizationScannerRows )
        { 
            $row | Add-Member -MemberType NoteProperty -Name "ExecutionCountLastSixtyDays"  -Value ""
            $row | Add-Member -MemberType NoteProperty -Name "WorkflowHistoryListUrl"       -Value ""
            $row | Add-Member -MemberType NoteProperty -Name "WebLastItemModifiedDate"      -Value ""
            $row | Add-Member -MemberType NoteProperty -Name "WebLastItemUserModifiedDate"  -Value ""

            if( $AddListMetadataColumns.IsPresent )
            {
                $row | Add-Member -MemberType NoteProperty -Name "ListLastItemDeletedDate"      -Value ""
                $row | Add-Member -MemberType NoteProperty -Name "ListLastItemModifiedDate"     -Value ""
                $row | Add-Member -MemberType NoteProperty -Name "ListLastItemUserModifiedDate" -Value ""
                $row | Add-Member -MemberType NoteProperty -Name "ListItemCount"                -Value ""
            }

            if( $AddWorkflowAuthorAndEditorColumns.IsPresent )
            {
                $row | Add-Member -MemberType NoteProperty -Name "WorkflowAuthor" -Value "" 
                $row | Add-Member -MemberType NoteProperty -Name "WorkflowEditor" -Value ""
            }

            if( $AddPrimaryColumns.IsPresent )
            {
                $row | Add-Member -MemberType NoteProperty -Name "SitePrimaryOwnerLogin" -Value ""
                $row | Add-Member -MemberType NoteProperty -Name "SitePrimaryOwnerEmail" -Value ""
            }
        }
    }
}

<#
.SYNOPSIS

   Adds the primary owner of the site to each row in the modernization scanner dataset
   
.DESCRIPTION

   Adds the primary owner of the site to each row in the modernization scanner dataset

.EXAMPLE

    Add-PrimaryOwner -ModernizationScannerRows $modernizationScannerRows -ClientId $clientId -CertificatePath $certificatePath -CertificatePassword $secureCertificatePassword -Tenant "contoso.onmicrosoft.com"

.OUTPUTS
   None
#>
function Add-PrimaryOwner
{
    [cmdletbinding()]
    param
    (
        # Modernization Scanner array
        [Parameter(Mandatory=$true)][object[]]$ModernizationScannerRows,
        # Client Id
        [Parameter(Mandatory=$true)][string]$ClientId,
        # Certificate Path
        [Parameter(Mandatory=$true)][string]$CertificatePath,
        # Certificate Password Secure String
        [Parameter(Mandatory=$true)][System.Security.SecureString]$CertificatePassword,
        # Tenant Name
        [Parameter(Mandatory=$true)][string]$Tenant
    )

    begin
    {
        $count = 0
    }
    process
    {
        Write-Verbose "$(Get-Date) - Searching for unique site collections from scanner input file."

        $siteUrls = $ModernizationScannerRows | SELECT -Unique "Site Collection Url" | SELECT -ExpandProperty "Site Collection Url"

        Write-Verbose "$(Get-Date) - Discovered $($siteUrls.Count) site collections"

        foreach( $siteUrl in $siteUrls )
        {
            $count++

            Write-Verbose "$(Get-Date) - $($count)/$($siteUrls.Count) - Processing $siteUrl"

            # connect to each site
            $connection = Connect-PnPOnline -Url $siteUrl -ClientId $ClientId -CertificatePath $CertificatePath -CertificatePassword $CertificatePassword -Tenant $Tenant -ReturnConnection -WarningAction SilentlyContinue
        
            if( -not $? -or $connection -eq $null )
            {
                continue
            }

            $site = Get-PnPSite -Connection $connection

            if( -not $? -or $site -eq $null )
            {
                Write-Warning "Site not found: $siteUrl"
                continue
            }

            Get-PnPProperty -ClientObject $site -Property Owner -Connection $connection | Out-Null

            $rows = $modernizationScannerRows | ? 'Site Collection Url' -eq $siteUrl

            foreach( $row in $rows )
            {
                $row.SitePrimaryOwnerLogin = $site.Owner.LoginName -replace "i:0#\.f\|membership\|", ""
                $row.SitePrimaryOwnerEmail = $site.Owner.Email
            }

            Disconnect-PnPOnline -Connection $connection
        }
    }
    end
    {
    }
}

<#
.SYNOPSIS

   Adds the LastItemModifiedDate and LastItemUserModifiedDate to each row in the modernization scanner dataset
   
.DESCRIPTION

   Adds the LastItemModifiedDate and LastItemUserModifiedDate to each row in the modernization scanner dataset

.EXAMPLE

   Add-WebMetadata -ModernizationScannerRows $modernizationScannerRows -Connection $connection -Web $web

.OUTPUTS
   None
#>
function Add-WebMetadata
{
    [cmdletbinding()]
    param
    (
        # Target web
        [Parameter(Mandatory=$true)][Microsoft.SharePoint.Client.Web]$Web,
        # Target web PnP Connection
        [Parameter(Mandatory=$true)][object]$Connection,
        # Modernization Scanner array
        [Parameter(Mandatory=$true)][object[]]$ModernizationScannerRows
    )

    process
    {
        Write-Verbose "$(Get-Date) - Recording web last modified properties for $($web.Url)"

        foreach( $row in $ModernizationScannerRows )
        {
            $row.WebLastItemModifiedDate     = $web.LastItemModifiedDate
            $row.WebLastItemUserModifiedDate = $web.LastItemUserModifiedDate
        }

        Write-Verbose "$(Get-Date) - Recorded web metadata for $($web.Url)"
    }
}

<#
.SYNOPSIS

   Adds the ItemCount, LastItemModifiedDate, LastItemUserModifiedDate and LastItemDeletedDate property values to each list reported in the modernization scanner dataset
   
.DESCRIPTION

   Adds the LastItemModifiedDate and LastItemUserModifiedDate to each row in the modernization scanner dataset

.EXAMPLE

   Add-ListMetadata -ModernizationScannerRows $modernizationScannerRows -Connection $connection -Web $web

.OUTPUTS
   None
#>
function Add-ListMetadata
{
    [cmdletbinding()]
    param
    (
        # Target web
        [Parameter(Mandatory=$true)][Microsoft.SharePoint.Client.Web]$Web,
        # Target web PnP Connection
        [Parameter(Mandatory=$true)][object]$Connection,
        # Modernization Scanner array
        [Parameter(Mandatory=$true)][object[]]$ModernizationScannerRows
    )

    process
    {
        Write-Verbose "$(Get-Date) - Adding List Metadata"

        $rows = $ModernizationScannerRows | ? { $_."Site Url" -eq $web.Url -and $_.Scope -eq "List" }

        foreach( $row in $rows )
        {
            Write-Verbose "$(Get-Date) - Processing list $($row.'List Id') on web $($web.Url)"
                
            $list = Get-PnPList -Identity $row.'List Id' -Includes "ItemCount", "LastItemDeletedDate", "LastItemModifiedDate", "LastItemUserModifiedDate" -Connection $Connection -ErrorAction SilentlyContinue

            if( $list -ne $null )
            {
                $row.ListItemCount                = $list.ItemCount
                $row.ListLastItemModifiedDate     = $list.LastItemModifiedDate
                $row.ListLastItemUserModifiedDate = $list.LastItemUserModifiedDate
                $row.ListLastItemDeletedDate      = $list.LastItemDeletedDate
            }
            else
            {
                Write-Warning "List not found: '$($row.'List Id')'"
            }
        }

        Write-Verbose "$(Get-Date) - Completed List Metadata"
    }
}

<#
.SYNOPSIS

   Looks up each OOB 2010 list based workflow in the scanner reports and adds the author and editor values to the modernization scanner dataset
   
.DESCRIPTION

   Looks up each OOB 2010 list based workflow in the scanner report and adds the author and editor values to the modernization scanner dataset

.EXAMPLE

   Add-WorkflowOwnership -ModernizationScannerRows $modernizationScannerRows -Connection $connection -Web $web

.OUTPUTS
   None
#>
function Add-WorkflowOwnership
{
    [cmdletbinding()]
    param
    (
        # Target web
        [Parameter(Mandatory=$true)][Microsoft.SharePoint.Client.Web]$Web,
        # Target web PnP Connection
        [Parameter(Mandatory=$true)][object]$Connection,
        # Modernization Scanner array
        [Parameter(Mandatory=$true)][object[]]$ModernizationScannerRows
    )

    begin
    {
    }
    process
    {
        $site      = Get-PnPSite -Connection $Connection
        $wfList    = Get-PnPList -Connection $Connection -Web $Web          -Includes BaseTemplate, RootFolder | ? BaseTemplate -eq 117
        $wfPubList = Get-PnPList -Connection $Connection -Web $site.RootWeb -Includes BaseTemplate, RootFolder | ? BaseTemplate -eq 122
                
        # get all the non-oob 2010 workflows reported in this web
        $2010WorkflowInstances = @($ModernizationScannerRows | ? { $_.'Site url' -eq $webUrl -and $_.Version -eq "2010" -and $_.'Is OOB' -eq "FALSE" -and $_.'List Id' -ne [Guid]::Empty.ToString() }) 

        # enum each workflow
        foreach( $2010WorkflowInstance in $2010WorkflowInstances )
        {
            $xomlPaths = @()

            if( $wfList -ne $null )
            {
                $xomlPaths += "{0}/{1}/{2}.xoml" -f $wfList.RootFolder.ServerRelativeUrl, $2010WorkflowInstance.'Definition Name', $2010WorkflowInstance.'Definition Name'
            }

            if( $wfPubList -ne $null )
            {
                $xomlPaths += "{0}/{1}/{2}.xoml" -f $wfPubList.RootFolder.ServerRelativeUrl, $2010WorkflowInstance.'Definition Name', $2010WorkflowInstance.'Definition Name'
            }

            foreach( $xomlPath in $xomlPaths )
            {
                Write-Verbose "$(Get-Date) - Checking for WF definition at $xomlPath"

                $xomlFile = Get-PnPFile -Url $xomlPath -AsListItem -Connection $connection -ErrorAction SilentlyContinue
                    
                if( $xomlFile )
                {
                    # pull author and editor
                    Write-Verbose "$(Get-Date) - Workflow Definition '$($2010WorkflowInstance.'Definition Name')' found at $xomlPath"

                    $author = $xomlFile.FieldValues["Created_x0020_By"]  -replace "i:0#\.f\|membership\|", ""
                    $editor = $xomlFile.FieldValues["Modified_x0020_By"] -replace "i:0#\.f\|membership\|", ""
                    
                    $row = $modernizationScannerRows | ? 'Subscription Id' -eq $2010WorkflowInstance.'Subscription Id'
                    $row.WorkflowAuthor = $author
                    $row.WorkflowEditor = $editor

                    break
                }
                else
                {
                    Write-Verbose "$(Get-Date) - Workflow Definition '$($2010WorkflowInstance.'Definition Name')' not found at $xomlPath"
                }
            }
        }
    }
    end
    {
    }
}

<#
.SYNOPSIS

   Returns each workflow history list that has and ItemCount greater than zero for the provided Web
   
.DESCRIPTION

   Returns each workflow history list that has and ItemCount greater than zero for the provided Web

.EXAMPLE

   Get-WorkflowHistoryLists -Connection $connection -Web $web

.OUTPUTS
   Zero or more Workflow History List objects
#>
function Get-WorkflowHistoryLists
{
    [cmdletbinding()]
    param
    (
        # Target web
        [Parameter(Mandatory=$true)][Microsoft.SharePoint.Client.Web]$Web,
        # Target web PnP Connection
        [Parameter(Mandatory=$true)][object]$Connection
    )

    process
    {
        Write-Verbose "$(Get-Date) - Retrieving Workflow History lists for web $($web.Url)"

        Get-PnPList -Web $Web -Connection $Connection -Includes BaseTemplate, DefaultViewUrl, ItemCount, ParentWeb | ? { $_.BaseTemplate -eq 140 -and $_.ItemCount -gt 0 }
    }
}

<#
.SYNOPSIS

   Returns rows that have a unique WorkflowHistoryParentInstance and WorkflowAssociationId value combination
   
.DESCRIPTION

   Returns rows that have a unique WorkflowHistoryParentInstance and WorkflowAssociationId value combination

.EXAMPLE

   Get-DistinctObjects -Objects $objects

.OUTPUTS
   Zero or more PSCustomObject objects
#>
function Get-DistinctObjects
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true)][PSCustomObject[]]$Objects
    )

    begin
    {
        $hashset = New-Object 'System.Collections.Generic.HashSet[string]'
    }
    process
    {
        Write-Verbose "$(Get-Date) - Removing duplicate items"

        foreach( $object in $Objects.GetEnumerator() )
        {
            $key = "{0}_{1}" -f $object.WorkflowHistoryParentInstance, $object.WorkflowAssociationId

            # automatically de-dupes, returns false if duplicate
            $added = $hashset.Add($key)

            if( $added )
            {
                $object
            }
        }

        Write-Verbose "$(Get-Date) - Removed duplicate items"
    }
    end
    {
    }
}

<#
.SYNOPSIS

   Groups the provided object array by the WorkflowAssociationId column
   
.DESCRIPTION

   Groups the provided object array by the WorkflowAssociationId column

.EXAMPLE

   Get-GroupedObject -Objects $objects

.OUTPUTS
   Zero or more PSCustomObject objects
#>
function Get-GroupedObject
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true)][PSCustomObject[]]$Objects
    )

    begin
    {
        $keySelector = [Func[Object,string]] { param($object) $object.WorkflowAssociationId }
    }
    process
    {
        Write-Verbose "$(Get-Date) - Grouping Results (this can take several hours on very large lists)"

        $aggregrates = [Linq.Enumerable]::GroupBy($Objects, $keySelector) | SELECT @{N="Name";E={$_.Key}}, @{N="Count"; E={$_.Count}}

        Write-Verbose "$(Get-Date) - Grouping Results completed"
    
        return $aggregrates
    }
    end
    {
    }
}

<#
.SYNOPSIS

   Filters the provided ModernizationScannerRows array to just 'Site Url' values that match the web URL
   
.DESCRIPTION

   Filters the provided ModernizationScannerRows array to just 'Site Url' values that match the provided web URL

.EXAMPLE

   Get-WebSpecificRows -ModernizationScannerRows $modernizationScannerRows -WebUrl "https://contoso.sharepoint.com/sites/teamsite/subsite"

.EXAMPLE

   Get-WebSpecificRows -ModernizationScannerRows $modernizationScannerRows -WebUrl $Web

.OUTPUTS
   Zero or more PSCustomObject objects
#>
function Get-WebSpecificRows
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true)][PSCustomObject[]]$ModernizationScannerRows,
        [Parameter(Mandatory=$true)][string]$WebUrl
    )

    begin
    {
    }
    process
    {
        Write-Verbose "$(Get-Date) - Getting web specific rows for $WebUrl"

        $rows = $ModernizationScannerRows | ? 'Site Url' -eq $WebUrl

        Write-Verbose "$(Get-Date) - Discovered $($rows.Count) web specific rows"
        
        return $rows
    }
    end
    {
    }

}

<#
.SYNOPSIS

   Reads the list items from the provided Workflow History list and provides zero or more PSCUstomObject objects with WorkflowHistoryParentInstance, WorkflowAssociationId, Created properties
   
.DESCRIPTION

   Reads the list items from the provided Workflow History list and provides zero or more PSCUstomObject objects with WorkflowHistoryParentInstance, WorkflowAssociationId, Created properties

.EXAMPLE

   Get-NormalizedWorkflowHistoryListItems -WorkflowHistoryList $wfList -Connection $connection

.OUTPUTS
   Zero or more PSCustomObject objects
#>
function Get-NormalizedWorkflowHistoryListItems
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true)][Microsoft.SharePoint.Client.List]$WorkflowHistoryList,
        [Parameter(Mandatory=$true)][object]$Connection
    )

    begin
    {
    }
    process
    {
        Write-Verbose "$(Get-Date) - Reading $($workflowHistoryList.ItemCount) items from Workflow History list at $($workflowHistoryList.DefaultViewUrl)"

        $items = @(Get-PnPListItem -List $WorkflowHistoryList -PageSize 5000 -Connection $Connection -Web $WorkflowHistoryList.ParentWeb -Fields WorkflowAssociation, WorkflowInstance, Created)

        Write-Verbose "$(Get-Date) - Read $($items.Count) list items"

        Write-Verbose "$(Get-Date) - Normalizing Results"

        #return @($items | SELECT -ExpandProperty FieldValues | SELECT `
        #                                                @{Name="WorkflowHistoryParentInstance"; E={$_.WorkflowInstance.Trim("{").Trim("}")}}, 
        #                                                @{Name="WorkflowAssociationId";         E={$_.WorkflowAssociation.Trim("{").Trim("}")}},
        #                                                @{Name="Created";                       E={$_.Created}})
    
        foreach( $item in $items )
        {
            [PSCustomObject] @{
                WorkflowHistoryParentInstance = $item.FieldValues["WorkflowInstance"]    -replace "{|}", ""
                WorkflowAssociationId         = $item.FieldValues["WorkflowAssociation"] -replace "{|}", ""
                Created                       = $item.FieldValues["Created"]
            }
        }

        Write-Verbose "$(Get-Date) - Normalizing Results Completed"
    }
    end
    {
    }
}

<#
.SYNOPSIS

   Reads the workflow history lists identified in the ModernizationWorkflowScanResults.csv file and attempts to collect workflow execution counts based on entries in the workflow history list.
   
.DESCRIPTION

   Reads the workflow history lists identified in the ModernizationWorkflowScanResults.csv file and attempts to collect workflow execution counts based on entries in the workflow history list.  This process is 
   flawed from the start since not all workflows will log entries to the Workflow History list.  Since I can't report on data that doesn't exist, this is as good as it gets for reporting on "workflow usage" for 
   particual workflows

.EXAMPLE

    Get-WorkflowAssociationAggregations -ClientId $clientId -CertificatePath $certificatePath -CertificatePassword $certificatePassword -Tenant "$tenant.onmicrosoft.com" -CsvPath $modernizationScannerCsvPath

.EXAMPLE

    Get-WorkflowAssociationAggregations -ClientId $clientId -CertificatePath $certificatePath -CertificatePassword $certificatePassword -Tenant "$tenant.onmicrosoft.com" -CreatedAfter ([DateTime]::Today).AddDays(-90) -CsvPath $modernizationScannerCsvPath

.OUTPUTS
   
   Adds a SitePrimaryOwnerLogin, SitePrimaryOwnerEmail, WorkflowAssociationId, WorkflowHistoryListUrl and ExecutionCountLastSixtyDays column to the data set provided in ModernizationWorkflowScanResults.csv.  Returns the updated dataset.

#>
function Get-WorkflowAssociationAggregations
{
    [CmdletBinding()]
    param
    (
        # Azure AD Client/Application ID
        [Parameter(Mandatory=$true)][string]$ClientId,

        # Azure AD Tenant Name (without the .onmicrosoft.com suffix)
        [Parameter(Mandatory=$true)][string]$Tenant,

        # Path to the Azure AD App Principal PFX Certificate
        [Parameter(Mandatory=$true)][string]$CertificatePath,

        # Password for supplied PFX certificate
        [Parameter(Mandatory=$true)][System.Security.SecureString]$CertificatePassword,

        # Path to the Modernizations Scanner output file: ModernizationWorkflowScanResults.csv
        [Parameter(Mandatory=$true)][string]$CsvPath,

        # Filter parameter for removing list items created before a certain date.  Completed and errored workflows will their workflow associations deleted automatically after 60 day by SharePoint.
        [Parameter(Mandatory=$false)][DateTime]$CreatedAfter,

        # Switch to enabled reporting of the Author and Editor of non-OOB 2010 workflow definitions
        [Parameter(Mandatory=$false)][switch]$ReportWorkflowAuthorAndEditor,

        # Switch to enabled reporting of the Primary Site Collection Admin
        [Parameter(Mandatory=$false)][switch]$ReportPrimarySiteAdmin,

        # Switch to enabled reporting of "ItemCount", "LastItemDeletedDate", "LastItemModifiedDate", "LastItemUserModifiedDate" values for List workflows
        [Parameter(Mandatory=$false)][switch]$ReportAssociatedListMetadata
    )

    begin
    {
        $filterPredicate = [Func[Object,bool]] { param($object) $object.Created -ge $CreatedAfter }
        $count = 0
    }
    process
    {
        if( -not (Test-Path -Path $CsvPath -PathType Leaf) )
        {
            Write-Error "File not found: $CsvPath"
            return
        }

        $modernizationScannerRows = @(Import-Csv -Path $CsvPath)

        if( $modernizationScannerRows.Count -eq 0 )
        {
            Write-Error "Zero rows found in $CsvPath"
            return
        }

        Add-SupplementalColumns -ModernizationScannerRows $modernizationScannerRows -AddWorkflowAuthorAndEditorColumns:$ReportWorkflowAuthorAndEditor.IsPresent -AddPrimaryColumns:$ReportPrimarySiteAdmin.IsPresent -AddListMetadataColumns:$ReportAssociatedListMetadata.IsPresent


        if( $ReportPrimarySiteAdmin.IsPresent )
        {
            Add-PrimaryOwner -ModernizationScannerRows $modernizationScannerRows -ClientId $ClientId -CertificatePath $CertificatePath -CertificatePassword $CertificatePassword -Tenant $Tenant
        }


        # pull out the distinct web URLs from the modernizations scanner output
        $webUrls = Get-UniqueWebUrls -ModernizationScannerRows $modernizationScannerRows


        # enumerate webs
        foreach( $webUrl in $webUrls )
        {
            $count++

            Write-Verbose "$(Get-Date) - $($count)/$($webUrls.Count) - Processing $webUrl"

            $connection = Connect-PnPOnline -Url $webUrl -ClientId $ClientId -CertificatePath $CertificatePath -CertificatePassword $CertificatePassword -Tenant $Tenant -ReturnConnection -WarningAction SilentlyContinue

            if( -not $? -or $connection -eq $null )
            {
                Write-Warning "Failed to connect to web $webUrl, skipping"
                continue
            }

            $web = Get-PnPWeb -Includes LastItemModifiedDate, LastItemUserModifiedDate -Connection $connection

            # to help with perf, filter rows down to specific web first
            $webModernizationScannerRows = Get-WebSpecificRows -ModernizationScannerRows $modernizationScannerRows -WebUrl $webUrl

            if( -not $? -or $web -eq $null )
            {
                Write-Warning "Failed to connect to web $webUrl, skipping"
                continue
            }


            Add-WebMetadata -ModernizationScannerRows $webModernizationScannerRows -Web $web -Connection $connection


            if( $ReportAssociatedListMetadata.IsPresent )
            {
                Add-ListMetadata -ModernizationScannerRows $webModernizationScannerRows -Web $web -Connection $connection
            }

            if( $ReportWorkflowAuthorAndEditor.IsPresent )
            {
                Add-WorkflowOwnership -ModernizationScannerRows $webModernizationScannerRows -Web $web -Connection $connection
            }



            $workflowHistoryLists = Get-WorkflowHistoryLists -Web $web -Connection $connection
            
            foreach( $workflowHistoryList in $workflowHistoryLists )
            {

                $workflowHistoryListItems = @(Get-NormalizedWorkflowHistoryListItems -WorkflowHistoryList $workflowHistoryList -Connection $connection)

                if( $workflowHistoryListItems.Count -eq 0 )
                {
                    Write-Verbose "$(Get-Date) - Skipping $($workflowHistoryList.DefaultViewUrl), Item Count is 0"
                    continue
                }


                if( $PSBoundParameters.ContainsKey("CreatedAfter") )
                {
                    Write-Verbose "$(Get-Date) - Filtering out items created before $($CreatedAfter).  Pre-filter Count: $($workflowHistoryListItems.Count)"
                
                    $workflowHistoryListItems = [Linq.Enumerable]::Where($workflowHistoryListItems, $filterPredicate) | SELECT WorkflowHistoryParentInstance, WorkflowAssociationId 

                    Write-Verbose "$(Get-Date) - Post-filter Count: $($workflowHistoryListItems.Count)"
                }


                if( $workflowHistoryListItems.Count -eq 0)
                {
                    Write-Verbose "$(Get-Date) - Skipping $($workflowHistoryList.DefaultViewUrl), Item Count is 0"
                    continue
                }


                # fitler out duplicate rows, much faster on very large datasets
                $uniqueResults = @(Get-DistinctObjects -Objects $workflowHistoryListItems)

                # group objects by WorkflowAssociationId
                $aggregrates = Get-GroupedObject -Objects $uniqueResults


                Write-Verbose "$(Get-Date) - Merging $($aggregrates.Count) Aggregrates"
                
                # enumerate each aggregerated workflow association                 
                foreach( $aggregrate in $aggregrates )
                {
                    $row = $modernizationScannerRows | ? 'Subscription Id' -eq $aggregrate.Name
                
                    if( $null -ne $row )
                    {
                        $uri = New-Object System.Uri($web.Url)

                        # update column values
                        $row.ExecutionCountLastSixtyDays = $aggregrate.Count
                        $row.WorkflowHistoryListUrl      = "https://$($uri.Host)$($workflowHistoryList.DefaultViewUrl)"
                    }
                    else
                    {
                        Write-Verbose "$(Get-Date) - Subscription not found: $($aggregrate.Name)"
                    }
                }

            } # workflowHistoryLists

            Disconnect-PnPOnline -Connection $connection

        } # webUrls

        # return our updated data set to the pipeline
        $modernizationScannerRows
    }
    end
    {
    }
}


# app principal requires SharePoint > Sites.FullControl (becuase this reads the Site Collection Admins)
$tenant                      = "contoso"
$clientId                    = "8a6b10a8-1234-1234-1234-9b8e49b6f6b7"
$certificatePath             = "E:\_certs\AppPrincipalCert.pfx"
$certificatePassword         = ConvertTo-SecureString -String 'pass@word1' -AsPlainText -Force
$modernizationScannerCsvPath = "E:\_temp\637311193731245094\ModernizationWorkflowScanResults.csv"

$results = Get-WorkflowAssociationAggregations `
                -ClientId            $clientId `
                -CertificatePath     $certificatePath `
                -CertificatePassword $certificatePassword `
                -Tenant              "$tenant.onmicrosoft.com" `
                -CreatedAfter        ([DateTime]::Today).AddDays(-900) `
                -CsvPath             $modernizationScannerCsvPath `
                -ReportWorkflowAuthorAndEditor `
                -ReportPrimarySiteAdmin `
                -ReportAssociatedListMetadata `
                -Verbose

$results | Export-Csv -Path ($modernizationScannerCsvPath -replace ".csv", ".supplement_$(Get-Date -Format FileDateTime).csv") -Force -NoTypeInformation
