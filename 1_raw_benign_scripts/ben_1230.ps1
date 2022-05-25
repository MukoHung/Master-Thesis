<#  
.SYNOPSIS  
       The purpose of this script is to download a set of PowerShell scripts from the technet script repository  
.DESCRIPTION  
       The purpose of this script is to download a set of PowerShell scripts from the technet script repository.  
       The script takes two parameters: a file containing a list of scripts to download, a destination directory to  
       store the downloads. If no parameters are specified the script will act on it's default values and create a file 
       containing the list of scripts to download. 
 
       This is the current list of scripts that are downloaded: 
       Search Management 
         Get-FASTFixml.ps1 
         Set-ImportanceLevelForManagedProperty.ps1 
         Set-RelevancyWeightForManagedProperty.ps1 
         Maintain-FASTSearchMetadataProperties.ps1 
         Export SharePoint Enterprise Crawler Settings.ps1 
         Import SharePoint Enterprise Crawler Settings.ps1 
         Get-ImportanceLevelForManagedProperty.ps1 
         Get-RelevancyWeightForManagedProperty.ps1 
         Import FAST Keywords and User Contexts to Sharepoint 2010 from CSV.ps1 
         View-AllCrawledProperties-PipelineExtensibility.ps1 
         Export FAST Keywords and User Contexts from SharePoint 2010 to CSV.ps1 
         Import SharePoint Enterprise Crawler Settings.ps1 
         Get a list of all available FastSearch crawled properties.ps1 
         Manage-SPEnterpriseSearchCrawlRules.ps1 
         Set-WebPartProperties.ps1 
         RemoveAll-SPEnterpriseSearchCrawlRules.ps1 
       Deployment and Upgrade 
         Set-FarmProperties.ps1 
       Monitoring and Reporting 
         Report-ContentStatus.ps1 
       Database 
         Check-SQLServerUserInRole.ps1 
         
.EXAMPLE  
.\DownloadScripts.ps1 
  
 Downloads the default scripts to the current directory 
 
.EXAMPLE 
.\DownloadScripts.ps1 -crawlurlfile .\DownloadScripts.txt -downloaddir C:\Temp 
 
Downloads the scripts specified in a file to a specific directory 
 
.EXAMPLE 
.\DownloadScripts.ps1 -newDeployPackage -downloadfiles 
 
Downloads the scripts and creates a deployment package 
 
.EXAMPLE 
.\DownloadScripts.ps1 -runDeploy 
 
Runs the deployment package 
 
Does not download the scripts. Only creates a new deployment package 
  
.LINK  
This Script - http://gallery.technet.microsoft.com/scriptcenter/b9fe96c4-9bf1-4d61-903b-5e6c2a65ec66 
.NOTES  
  File Name : DownloadScripts.ps1  
  Author    : Brent Groom, Thomas Svensen   
#>  
  
# TODO - drive from an xml config file   
 
param([string]$crawlurlfile="", [string]$downloaddir=$pwd.Path, [string]$directoryForConfigFile=$pwd.Path, [Switch]$newDeployPackage, [Switch]$downloadfiles=$true,  
 
[Switch]$runDeploy) 
 
$configurationname = $myinvocation.mycommand.name.Substring(0, $myinvocation.mycommand.name.IndexOf('.'))  
 
$tempdir = $Env:temp  
$tempfile = "$tempdir\DownloadScriptsTempfile.htm" 
 
Function createScriptListFile()  
{   
  
$defaultfile = @"  
# Get scripts for the root directory. i.e. "SetupSharepoint.ps1" and "SetupFastSearch.ps1"
\scripts\TechNet Script Repository\SharePoint\Search Management
Script-to-get-FAST-Fixml-37aa7173
6c246f1e-75e7-478c-a514-a33a37f353c6
858ff2e3-c391-40f8-a5b7-29da74f54d41
925c4fc5-9102-4600-8f28-fbcf9bbc556e
5ce9297e-90e6-4439-a584-04182b12dd43
3a942068-e84a-4349-8eb7-019cc29542a9
7661f21b-d9cb-4fab-963a-8d49acbc5e95
a30df851-a439-4441-9c0f-e9f8cf08b070
9ad93d90-9ca7-4515-b81e-441eda0390c3
834cd7a8-4e87-4b5a-bef9-a519fd1712ba
6b9b2e1c-7521-4091-b2a0-348bfd213a23
3a942068-e84a-4349-8eb7-019cc29542a9
3690fef8-0abe-4e6d-a642-95d016b4f82a
ba119b0d-19b0-4e4f-8dc6-a34730e876c4
b41f8101-b8bb-40db-a756-16becc57881d
fc0c3ddd-2b3e-4b91-b2d3-5292b06639df
CrawlAllContentSources-8b722858
\scripts\TechNet Script Repository\SharePoint\Deployment and Upgrade
bbd7dc18-3677-45ba-b0c5-933336217a01
FastAllServerSetup-2ab5ee7a
FastAdminOnlyServerSetup-00e0e835
SharePointServerSetup-1f0d0e63
SetupEnvironment-96669798
deploy-fabe1771
RunSmokeTests-9b53e2d6
#Scripts\TechNet Script Center\SharePoint\Monitoring and Reporting
a89e11a0-cbe3-4ac9-b0fb-81cc2837ffbe
\scripts\TechNet Script Repository\Database\SQLServer
07febab1-a142-41d2-b6f1-be723dae71c6
\scripts\TechNet Script Repository\Using the Internet\Downloading files
DownloadScriptsv2-cfbf4342
#Zip files
\
http://gallery.technet.microsoft.com/DownloadScriptsv2-cfbf4342/file/44667/1/SampleConfigShowAllCrawledAndManagedProperties.zip
http://gallery.technet.microsoft.com/DownloadScriptsv2-cfbf4342/file/57574/2/DefaultConfig.zip
"@ | Out-File "$configurationname.txt"
 
$global:urlfile = "$configurationname.txt" 
"Generated file $configurationname.txt" 
}  
     
function Get-ElementText($text, $startTag, $endTag) 
{ 
    #Write-host ("Starting Get-elementText") -foregroundcolor green 
     
     
    #$starttag = "<pre id=""codePreview"" class=""powershell"">" 
    $startindex = $text.IndexOf($starttag)  
    #Write-host ("startindex=$startindex") -foregroundcolor green 
    $startindex = $startindex + $starttag.length -1 
    $substr = $text.Substring($startindex) 
     
    #Write-host ($substr) -foregroundcolor green 
     
    #$endtag = "</pre>" 
    $endindex = $substr.IndexOf($endtag) -1 
    #$endindex 
    $substr = $substr.Substring(1,$endindex) 
    [System.Reflection.Assembly]::LoadWithPartialName("system.web") | out-null 
 
    $substr = [System.Web.HttpUtility]::HtmlDecode($substr) 
     
    return $substr 
 
} 
 
function Get-ScriptCenterScript ([String]$uri){ 
 
    Write-Verbose "" 
     
    $client = (new-object Net.WebClient) 
     
    While ($client.isBusy) { 
        Start-Sleep -Seconds 5 
    }             
     
    $uri = "http://gallery.technet.microsoft.com/scriptcenter/$uri/description"                  
     
    $client.DownloadFile($uri,$tempfile) 
    $client.dispose() 
     
    try { 
        $docHtml = [io.file]::ReadAllText($tempfile) 
        Remove-Item $tempfile 
 
        $scriptText = Get-ElementText $docHtml "<pre class=""hidden"">" "</pre>" 
 
        $scriptTitle = Get-ElementText $docHtml "<title>" "</title>" 
 
        # tidying up scripts with spaces in name 
        if ($scriptTitle.indexOf(" ") -gt 0) 
        { 
            $splitTitle = $scriptTitle.split(" ") 
            $scriptTitle = $splitTitle[0] + "-" + [string]::join("", $splitTitle[1..$splitTitle.length]) 
        } 
 
        $filename = "$scriptTitle.ps1" 
         
    } 
    catch { 
        Write-Error "There was error reading the HTML" 
        $_ 
        return 
    }             
 
    if ($filename) { 
        Try { 
            Set-Content -Value $scriptText -Path "$scriptpath\$filename" 
            "Saved Script $scriptpath\$filename" 
 
        } 
        Catch { 
            Write-Error "Error copying the script to local disk" 
        } 
    } 
     
}  
 
function mainwork 
{ 
    if($global:urlfile.length -eq 0) 
    { 
        "Creating default download file to retrieve scripts" 
        createScriptListFile 
    } 
 
    $scriptpath = $downloaddir 
 
    if($runDeploy) 
    { 
        "As a saftey precaution downloadfiles and newDeployPackage are disabled with the runDeploy option" 
        $downloadfiles = $false 
        $newDeployPackage = $false 
    } 
         
    # Iterate all lines in the file 
    if($downloadfiles) 
    { 
      "Default behavior is to download all files. If you do not wish to download use the flag -downloadfiles:$false" 
      Get-Content $global:urlfile |% {  
         
        $_ = $_.Trim()
        # Create a directory based on comment line and put all files into this dir until the next comment line 
        if ($_.StartsWith('\') ) 
        { 
            $_ = $_.substring(1) 
            new-item  -path $downloaddir -name $_ -type directory -force  | out-null 
            $scriptpath = "$downloaddir\$_" 
        } 
        # Skip blank lines and comment lines 
        elseif ($_.StartsWith('#') -OR $_.Trim().Length -eq 0 ) 
        { 
        } 
        elseif ($_.EndsWith('zip')  ) 
        { 
           "Downloading zip $_"
           (New-Object Net.WebClient).DownloadFile($_,"$downloaddir\temp.zip") 
           (new-object -com shell.application).namespace("$downloaddir").CopyHere((new-object -com shell.application).namespace("$downloaddir\temp.zip").Items(),16) 
           del $downloaddir\temp.zip 
        } 
 
        # Download the script listed in the file 
        else 
        { 
            Get-ScriptCenterScript -uri $_ 
        } 
      } # end Get-Content 
      "Finished downloading files" 
    } 
     
    if($newDeployPackage) 
    { 
        #.\deploy.ps1 -newDeployPackage # todo-move this out 
     
        "Creating deployment package" 
        #copy-item   
        # Create the deployment package directory structure 
        new-item  -path $downloaddir -name "SampleConfigStarterPackage" -type directory -force  | out-null 
        new-item  -path $downloaddir -name "SampleConfigStarterPackage\SharePoint" -type directory -force  | out-null 
        new-item  -path $downloaddir -name "SampleConfigStarterPackage\Fastsearch" -type directory -force  | out-null 
        new-item  -path $downloaddir -name "SampleConfigStarterPackage\Fastsearch\keywords\csv" -type directory -force  | out-null 
        new-item  -path $downloaddir -name "SampleConfigStarterPackage\Fastsearch\overlay\bin" -type directory -force  | out-null 
        new-item  -path $downloaddir -name "SampleConfigStarterPackage\Fastsearch\overlay\etc" -type directory -force  | out-null    
        $scriptdir = "$downloaddir\scripts\TechNet Script Repository\SharePoint\Search Management" 
        cd $scriptdir 
        .\Maintain-FASTSearchMetadataProperties.ps1 -directoryForConfigFile "$downloaddir\SampleConfigStarterPackage\Fastsearch" -GenerateSampleConfigurationFile   
        .\Import-FASTKeywordsandUserContextstoSharepoint2010fromCSV.ps1 -directoryForConfigFile "$downloaddir\SampleConfigStarterPackage\Fastsearch\keywords\csv" -GenerateSampleConfigurationFile   
        .\Export-SharePointEnterpriseCrawlerSettings.ps1 -directoryForConfigFile "$downloaddir\SampleConfigStarterPackage\SharePoint" -GenerateSampleConfigurationFile   
        .\Set-WebPartProperties.ps1 -outputconfig 
     
        cd $downloaddir 
        copy-item ".\scripts\TechNet Script Repository\SharePoint\Search Management\Set-WebPartProperties.xml" .\SampleConfigStarterPackage\SharePoint -force 
        copy-item ".\scripts\TechNet Script Repository\SharePoint\Deployment and Upgrade\FastAllServerSetup.ps1" . -force 
        copy-item ".\scripts\TechNet Script Repository\SharePoint\Deployment and Upgrade\SetupEnvironment.ps1" . -force 
        copy-item ".\scripts\TechNet Script Repository\SharePoint\Deployment and Upgrade\FastAdminOnlyServerSetup.ps1" . -force 
        copy-item ".\scripts\TechNet Script Repository\SharePoint\Deployment and Upgrade\SharePointServerSetup.ps1" . -force 
        copy-item ".\scripts\TechNet Script Repository\SharePoint\Deployment and Upgrade\deploy.ps1" . -force 
        copy-item ".\scripts\TechNet Script Repository\SharePoint\Deployment and Upgrade\RunSmokeTests.ps1" . -force 
        copy-item ".\scripts\TechNet Script Repository\SharePoint\Search Management\View-AllCrawledProperties-PipelineExtensibility.ps1" "$downloaddir\SampleConfigStarterPackage\Fastsearch\overlay\bin" -force 
        "Finished creating deployment package" 
    } 
     
    if($runDeploy) 
    { 
          .\deploy.ps1 -SampleConfigStarterPackage 
    }     
   
     
} 
 
$global:urlfile = $crawlurlfile 
 
mainwork 

# SIG # Begin signature block
# MIINGAYJKoZIhvcNAQcCoIINCTCCDQUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU9tjOw8UhAQfZDWIjm/bQ4UCz
# ASigggpaMIIFIjCCBAqgAwIBAgIQAupQIxjzGlMFoE+9rHncOTANBgkqhkiG9w0B
# AQsFADByMQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYD
# VQQLExB3d3cuZGlnaWNlcnQuY29tMTEwLwYDVQQDEyhEaWdpQ2VydCBTSEEyIEFz
# c3VyZWQgSUQgQ29kZSBTaWduaW5nIENBMB4XDTE0MDcxNzAwMDAwMFoXDTE1MDcy
# MjEyMDAwMFowaTELMAkGA1UEBhMCQ0ExCzAJBgNVBAgTAk9OMREwDwYDVQQHEwhI
# YW1pbHRvbjEcMBoGA1UEChMTRGF2aWQgV2F5bmUgSm9obnNvbjEcMBoGA1UEAxMT
# RGF2aWQgV2F5bmUgSm9obnNvbjCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoC
# ggEBAM3+T+61MoGxUHnoK0b2GgO17e0sW8ugwAH966Z1JIzQvXFa707SZvTJgmra
# ZsCn9fU+i9KhC0nUpA4hAv/b1MCeqGq1O0f3ffiwsxhTG3Z4J8mEl5eSdcRgeb+1
# jaKI3oHkbX+zxqOLSaRSQPn3XygMAfrcD/QI4vsx8o2lTUsPJEy2c0z57e1VzWlq
# KHqo18lVxDq/YF+fKCAJL57zjXSBPPmb/sNj8VgoxXS6EUAC5c3tb+CJfNP2U9vV
# oy5YeUP9bNwq2aXkW0+xZIipbJonZwN+bIsbgCC5eb2aqapBgJrgds8cw8WKiZvy
# Zx2qT7hy9HT+LUOI0l0K0w31dF8CAwEAAaOCAbswggG3MB8GA1UdIwQYMBaAFFrE
# uXsqCqOl6nEDwGD5LfZldQ5YMB0GA1UdDgQWBBTnMIKoGnZIswBx8nuJckJGsFDU
# lDAOBgNVHQ8BAf8EBAMCB4AwEwYDVR0lBAwwCgYIKwYBBQUHAwMwdwYDVR0fBHAw
# bjA1oDOgMYYvaHR0cDovL2NybDMuZGlnaWNlcnQuY29tL3NoYTItYXNzdXJlZC1j
# cy1nMS5jcmwwNaAzoDGGL2h0dHA6Ly9jcmw0LmRpZ2ljZXJ0LmNvbS9zaGEyLWFz
# c3VyZWQtY3MtZzEuY3JsMEIGA1UdIAQ7MDkwNwYJYIZIAYb9bAMBMCowKAYIKwYB
# BQUHAgEWHGh0dHBzOi8vd3d3LmRpZ2ljZXJ0LmNvbS9DUFMwgYQGCCsGAQUFBwEB
# BHgwdjAkBggrBgEFBQcwAYYYaHR0cDovL29jc3AuZGlnaWNlcnQuY29tME4GCCsG
# AQUFBzAChkJodHRwOi8vY2FjZXJ0cy5kaWdpY2VydC5jb20vRGlnaUNlcnRTSEEy
# QXNzdXJlZElEQ29kZVNpZ25pbmdDQS5jcnQwDAYDVR0TAQH/BAIwADANBgkqhkiG
# 9w0BAQsFAAOCAQEAVlkBmOEKRw2O66aloy9tNoQNIWz3AduGBfnf9gvyRFvSuKm0
# Zq3A6lRej8FPxC5Kbwswxtl2L/pjyrlYzUs+XuYe9Ua9YMIdhbyjUol4Z46jhOrO
# TDl18txaoNpGE9JXo8SLZHibwz97H3+paRm16aygM5R3uQ0xSQ1NFqDJ53YRvOqT
# 60/tF9E8zNx4hOH1lw1CDPu0K3nL2PusLUVzCpwNunQzGoZfVtlnV2x4EgXyZ9G1
# x4odcYZwKpkWPKA4bWAG+Img5+dgGEOqoUHh4jm2IKijm1jz7BRcJUMAwa2Qcbc2
# ttQbSj/7xZXL470VG3WjLWNWkRaRQAkzOajhpTCCBTAwggQYoAMCAQICEAQJGBtf
# 1btmdVNDtW+VUAgwDQYJKoZIhvcNAQELBQAwZTELMAkGA1UEBhMCVVMxFTATBgNV
# BAoTDERpZ2lDZXJ0IEluYzEZMBcGA1UECxMQd3d3LmRpZ2ljZXJ0LmNvbTEkMCIG
# A1UEAxMbRGlnaUNlcnQgQXNzdXJlZCBJRCBSb290IENBMB4XDTEzMTAyMjEyMDAw
# MFoXDTI4MTAyMjEyMDAwMFowcjELMAkGA1UEBhMCVVMxFTATBgNVBAoTDERpZ2lD
# ZXJ0IEluYzEZMBcGA1UECxMQd3d3LmRpZ2ljZXJ0LmNvbTExMC8GA1UEAxMoRGln
# aUNlcnQgU0hBMiBBc3N1cmVkIElEIENvZGUgU2lnbmluZyBDQTCCASIwDQYJKoZI
# hvcNAQEBBQADggEPADCCAQoCggEBAPjTsxx/DhGvZ3cH0wsxSRnP0PtFmbE620T1
# f+Wondsy13Hqdp0FLreP+pJDwKX5idQ3Gde2qvCchqXYJawOeSg6funRZ9PG+ykn
# x9N7I5TkkSOWkHeC+aGEI2YSVDNQdLEoJrskacLCUvIUZ4qJRdQtoaPpiCwgla4c
# SocI3wz14k1gGL6qxLKucDFmM3E+rHCiq85/6XzLkqHlOzEcz+ryCuRXu0q16XTm
# K/5sy350OTYNkO/ktU6kqepqCquE86xnTrXE94zRICUj6whkPlKWwfIPEvTFjg/B
# ougsUfdzvL2FsWKDc0GCB+Q4i2pzINAPZHM8np+mM6n9Gd8lk9ECAwEAAaOCAc0w
# ggHJMBIGA1UdEwEB/wQIMAYBAf8CAQAwDgYDVR0PAQH/BAQDAgGGMBMGA1UdJQQM
# MAoGCCsGAQUFBwMDMHkGCCsGAQUFBwEBBG0wazAkBggrBgEFBQcwAYYYaHR0cDov
# L29jc3AuZGlnaWNlcnQuY29tMEMGCCsGAQUFBzAChjdodHRwOi8vY2FjZXJ0cy5k
# aWdpY2VydC5jb20vRGlnaUNlcnRBc3N1cmVkSURSb290Q0EuY3J0MIGBBgNVHR8E
# ejB4MDqgOKA2hjRodHRwOi8vY3JsNC5kaWdpY2VydC5jb20vRGlnaUNlcnRBc3N1
# cmVkSURSb290Q0EuY3JsMDqgOKA2hjRodHRwOi8vY3JsMy5kaWdpY2VydC5jb20v
# RGlnaUNlcnRBc3N1cmVkSURSb290Q0EuY3JsME8GA1UdIARIMEYwOAYKYIZIAYb9
# bAACBDAqMCgGCCsGAQUFBwIBFhxodHRwczovL3d3dy5kaWdpY2VydC5jb20vQ1BT
# MAoGCGCGSAGG/WwDMB0GA1UdDgQWBBRaxLl7KgqjpepxA8Bg+S32ZXUOWDAfBgNV
# HSMEGDAWgBRF66Kv9JLLgjEtUYunpyGd823IDzANBgkqhkiG9w0BAQsFAAOCAQEA
# PuwNWiSz8yLRFcgsfCUpdqgdXRwtOhrE7zBh134LYP3DPQ/Er4v97yrfIFU3sOH2
# 0ZJ1D1G0bqWOWuJeJIFOEKTuP3GOYw4TS63XX0R58zYUBor3nEZOXP+QsRsHDpEV
# +7qvtVHCjSSuJMbHJyqhKSgaOnEoAjwukaPAJRHinBRHoXpoaK+bp1wgXNlxsQyP
# u6j4xRJon89Ay0BEpRPw5mQMJQhCMrI2iiQC/i9yfhzXSUWW6Fkd6fp0ZGuy62ZD
# 2rOwjNXpDd32ASDOmTFjPQgaGLOBm0/GkxAG/AeB+ova+YJJ92JuoVP6EpQYhS6S
# kepobEQysmah5xikmmRR7zGCAigwggIkAgEBMIGGMHIxCzAJBgNVBAYTAlVTMRUw
# EwYDVQQKEwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20x
# MTAvBgNVBAMTKERpZ2lDZXJ0IFNIQTIgQXNzdXJlZCBJRCBDb2RlIFNpZ25pbmcg
# Q0ECEALqUCMY8xpTBaBPvax53DkwCQYFKw4DAhoFAKB4MBgGCisGAQQBgjcCAQwx
# CjAIoAKAAKECgAAwGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQwHAYKKwYBBAGC
# NwIBCzEOMAwGCisGAQQBgjcCARUwIwYJKoZIhvcNAQkEMRYEFCJbRAMfPD112ktN
# FzV0O8I23LzkMA0GCSqGSIb3DQEBAQUABIIBAMo66YouBl2gAqd1MjaSxuXyXmkD
# +uIUdFJ1p1b+T9j8WLvvdblyyf5T8hUgTxbJL46csIbwi/YVXLR62PFcSHKrPopI
# pg9HO3o3JocJ3yGm4+7z2Fg1f8VJesccf1C0Xo3gr92gOPdCHzpUJcVzHpV+NHjN
# OLKJK1hegu8fq5aIbW5f83Sye4Vcr67TVBH0qx7Bll9pzSqN0TPSkWi8o0QQyoAv
# PUFsfWkpLGovsnoI8TaQzdlYdk4cgj3msWpGUWQQl3H1a5rfnUFWcFbjEkbrOJQe
# tQkJ7il7W1FP0kc0Ss676s2RnBilIsN3dJJJG5/NOhjRXk0Szh7ae1Q27+s=
# SIG # End signature block
