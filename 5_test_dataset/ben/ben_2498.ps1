Import-Function Add-RoleMembers
Import-Function Get-RoleIdentity
Import-Function Add-SiteLanguage
Import-Function Copy-Site
Import-Function Remove-Site 

$root = "master:\content\MyRoot"
$masterSite = Get-Item -Path "$($root)\Websites\MyRoot"

function MyProjectCreateRegion {
    Param ([string]$regionName, [string]$languages)
    
    $regionPath = "$($root)\$($regionName)"
    $regionExists = Test-Path -Path $regionPath 
    $item = $null
    if (!$regionExists) {
        $item = New-Item  -Name $regionName -ItemType  "{GUID}" -Path $root
    }
    else {
        $item = Get-Item -Path $regionPath
    }
    $splitedLanguages = $languages.split(",")  
    foreach ($lang in $splitedLanguages) {
        $item | Add-ItemLanguage -Language "en" -TargetLanguage $lang -IfExist "Skip"
    }
}

function Remove-SiteLanguage {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [Item]$Site,

        [Parameter(Mandatory = $true, Position = 1)]
        [string]$Language
    )

    begin {
        Write-Verbose "Cmdlet Remove-SiteLanguage - Begin"
    }

    process {
        Write-Verbose "Cmdlet Remove-SiteLanguage - Process"

        Get-ChildItem -Path $Site.Paths.Path -Recurse -Language $Language | ForEach-Object {
            Remove-ItemLanguage -Item $_ -Language $Language
        }
        Remove-ItemLanguage -Item $Site -Language $Language
    }

    end {
        Write-Verbose "Cmdlet Remove-SiteLanguage - End"
    }
}


function MyProjectCreateSite {
    Param ([string]$siteName, [string]$regionName, [string]$languages)

    $siteItemPath = "$($root)\$($regionName)\$($siteName)"
    $siteExists = Test-Path -Path $siteItemPath
    if (!$siteExists) {
        $mapping = New-Object -TypeName "System.Collections.Hashtable"
        $mappingValue = $siteName –replace “ “, ”_” 
        $mapping.Add("MyPrefix", $mappingValue) 
        $region = Get-Item -Path "$($root)\$($regionName)"
        Copy-Site $masterSite $region $siteName $mapping
        
    }

    $siteItem = Get-Item -Path $siteItemPath

    $splitedLanguages = $languages.split(",")  
    foreach ($lang in $splitedLanguages) {
        if ($lang -ne "en") {
            Add-SiteLanguage $siteItem "en" $lang | Out-Null
            Remove-SiteLanguage $siteItem "en"
        }
    } 
}

function GetUserName {
    Param([string] $email)
    $userId = $email.Replace("@somedomain.com", "").Replace(".", "")

    $userId
}

function MyProjectSetUsers {
    Param ([System.Object]$row)

    $userNumers = @("1", "2", "3")
    $userNumers | %{
        $accountFieldName = "Account$($_)"
        if ($row."$accountFieldName") {
            $userName = GetUserName -email $row.Account1Email
            if (!(Test-Account -Identity $userName -AccountType "User")) {
                New-User -Identity $userName -Password $row."$($accountFieldName)Password" -Email $row."$($accountFieldName)Email"  -FullName $row."$($accountFieldName)"
            }
            Add-RoleMember -Identity "Author" -Members $userName
            Add-RoleMember -Identity "Designer" -Members $userName
            Add-RoleMember -Identity "ContentAdmin" -Members $userName
            Enable-User -Identity $userName
        } 
    }
}

function SetAccess {
    Param ([System.Object] $groupedUsers)
    
    $userName = GetUserName $groupedUsers.Name 
    
    $allowedSites = $groupedUsers.Group | % { 
        "\$($_.Region)\$($_.Site)"
    }
    $allSitesPath = Get-ChildItem -Path $root | Get-ChildItem | % { "\$($_.Parent.Name)\$($_.Name)" }
    $deniedSites = $allSitesPath | Where-Object { $allowedSites -notcontains $_ }

    $deniedSites | % {
        Add-ItemAcl -Path "$($root)$($_)" -AccessRight "item:read" -PropagationType Any -SecurityPermission DenyAccess -Identity $userName
    }
    $allowedSites | % {
        Add-ItemAcl -Path "$($root)$($_)" -AccessRight "item:read" -PropagationType Any -SecurityPermission AllowAccess -Identity $userName
        Add-ItemAcl -Path "$($root)$($_)" -AccessRight "item:write" -PropagationType Any -SecurityPermission AllowAccess -Identity $userName
        Add-ItemAcl -Path "$($root)$($_)" -AccessRight "item:delete" -PropagationType Any -SecurityPermission AllowAccess -Identity $userName
        Add-ItemAcl -Path "$($root)$($_)" -AccessRight "item:rename" -PropagationType Any -SecurityPermission AllowAccess -Identity $userName
        Add-ItemAcl -Path "$($root)$($_)" -AccessRight "item:create" -PropagationType Any -SecurityPermission AllowAccess -Identity $userName        
    }
     
}


function SetAltImages {
    Param ([System.Object]$row)

    Get-ChildItem -Path "master:\media library\Project\MyProject\Websites\$($row.Site)" -Recurse -Language * | % {
        if (!$_) { continue }
        if ([string]::IsNullOrEmpty($_.Alt) -and ($_.TemplateId.Guid -ne "GUID") -and ($_.TemplateId.Guid -ne "GUID") -and ($_.TemplateId.Guid -ne "GUID")) {
            $_.Alt = "Alt Tag"
        }
    }
}

function SetLanguageImages {
    Param ([System.Object]$row)

    $path = "master:\media library\Project\MyProject\Websites\$($row.Site)"
    $row.Language.split(",") | % {
        $lang = $_
        Get-Item -Path $path | Add-ItemLanguage -Language "en" -TargetLanguage $lang -IfExist "Skip"
        Get-ChildItem -Path $path -Recurse -Language "en" | % {
            $_ | Add-ItemLanguage -Language "en" -TargetLanguage $lang -IfExist "Skip"
        }
    }
}

function MyProjectRemoveSite {
    Param ([System.Object]$row)

    $row.Language.split(",") | % {
        $_
        $siteItemPath = Get-Item -Path "$($root)\$($row.Region)\$($row.Site)" -Language $_
        
        Remove-Site  $siteItemPath 
    }
}

function SetUsersAccess {
    Param ([System.Object]$csv)
    
    $groupedUsers = $csv | Where-Object { ![string]::IsNullOrEmpty($_.Account1Email) } | Group-Object { $_.Account1Email } 
    $groupedUsers | % { SetAccess -groupedUsers $_ }
    
    $groupedUsers = $csv | Where-Object { ![string]::IsNullOrEmpty($_.Account2Email) } | Group-Object { $_.Account2Email } 
    $groupedUsers | % { SetAccess -groupedUsers $_ }
    
    $groupedUsers = $csv | Where-Object { ![string]::IsNullOrEmpty($_.Account3Email) } | Group-Object { $_.Account3Email } 
    $groupedUsers | % { SetAccess -groupedUsers $_ }
}

function SetPageDesign {
    Get-ChildItem -path "/sitecore/content/MyProject" -Language * | Get-ChildItem -Language * | Get-ChildItem -Language * | % {
        if ($_.TemplateName -eq "Home") {
            $_.Editing.BeginEdit()
            $_["Page Design"] = $_["Page Design"].ToUpper()
            $_.Editing.EndEdit()    
            
            $_ | Get-ChildItem -Language * | % {
                $_["Page Design"]
                if (![string]::IsNullOrEmpty($_["Page Design"]) -and [regex]::Match($_["Page Design"]  , "(\{){0,1}[0-9a-f]{8}\-[0-9a-f]{4}\-[0-9a-f]{4}\-[0-9a-f]{4}\-[0-9a-f]{12}(\}){0,1}").Success) {
                    $_.Paths.Path
                    $_.Editing.BeginEdit()
                    $_["Page Design"] = $_["Page Design"].ToUpper()
                    $_.Editing.EndEdit()
                }
            }
        }
    }
}


function SetFormsLanguage {
    Param ([System.Object]$row)

    Get-ChildItem -path "/sitecore/Forms" -Recurse -Language "en" | % {
        $_ | Add-ItemLanguage -Language "en" -TargetLanguage $row.Language -IfExist "Skip"
    }
}

function SetSiteMediaItem {
    Param ([System.Object]$row)
  
    $row.Language.split(",") | % {
        $lang = $_
        $siteName = $row.Site
        $siteMediaItem = Get-Item "/sitecore/content/MyProject/Europe/$($siteName)/Media" -Language $lang
        $SiteMediaLibraryFolder = Get-Item "/sitecore/media library/Project/MyProject/Websites/$($siteName)" -Language $lang

        $siteMediaItem.Editing.BeginEdit()
        [Sitecore.Data.Fields.MultilistField]$field = $siteMediaItem.Fields["AdditionalChildren"]
        if (!$field.Contains($SiteMediaLibraryFolder.ID.ToString())) {
            $field.Add($SiteMediaLibraryFolder.ID.ToString())
        }
        $somedomainMediaFolder = "{GUID}"
        $field.Remove($somedomainMediaFolder)
        $siteMediaItem.Editing.EndEdit()
    }
}

function main {
    $csv = Import-Csv "C:\temp\tenants-sites-batch.csv"
    $csv | % {
        $row = $_
        MyProjectCreateRegion -regionName $row.Region -languages $row.Language  
        MyProjectCreateSite -siteName $row.Site -regionName $row.Region -languages $row.Language   
        MyProjectSetUsers -row $row 
        
        SetLanguageImages -row $row
        SetAltImages -row $row
        SetFormsLanguage -row $row
        SetSiteMediaItem -row $row
    }
    
    SetUsersAccess -csv $csv
    SetPageDesign
}

main