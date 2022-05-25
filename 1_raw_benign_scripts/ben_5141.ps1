#Get-InstalledModule

#Verify if MSOnline Module is available
if (Get-Module -ListAvailable -Name Az) {
    uninstall-module Az -Force
}

if (Get-Module -ListAvailable -Name AzureRM) {
    uninstall-module AzureRM -Force
}

if (Get-Module -ListAvailable -Name Microsoft.PowerApps.Administration.Powershell) {
    uninstall-module Microsoft.PowerApps.Administration.Powershell -Force
}

if (Get-Module -ListAvailable -Name Microsoft.PowerApps.PowerShell) {
    #uninstall-module Microsoft.PowerApps.PowerShell -Force
    powershell -NoProfile -NonInteractive -Command "Uninstall-Module Microsoft.PowerApps.PowerShell"
}

#Install-Module -Name Microsoft.PowerApps.Administration.PowerShell
#Install-Module -Name Microsoft.PowerApps.PowerShell -AllowClobber


#close all powershells and run this in administrator command prompt
powershell -NoProfile -Command "Uninstall-Module Microsoft.PowerApps.PowerShell -Force"
powershell -NoProfile -Command "Uninstall-Module Microsoft.PowerApps.PowerShell -Force"

powershell -NoProfile -Command "Install-PackageProvider -Name NuGet -RequiredVersion 2.8.5.201 -Force"
powershell -NoProfile -Command "Install-Module Microsoft.PowerApps.Administration.PowerShell"
powershell -NoProfile -Command "Install-Module Microsoft.PowerApps.PowerShell -AllowClobber"




# SIG # Begin signature block
# MIIFpQYJKoZIhvcNAQcCoIIFljCCBZICAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUAtsyzHfnHccNOToD2XYZNme5
# jW6gggM5MIIDNTCCAh2gAwIBAgIQd4fU+4/9kaFA69GGrZCBpjANBgkqhkiG9w0B
# AQUFADAhMR8wHQYDVQQDDBZhYXJvbi5sZWJsYW5jQFRDLkdDLkNBMB4XDTIxMDcw
# OTA0MTg0N1oXDTIzMDcwOTA0Mjg0N1owITEfMB0GA1UEAwwWYWFyb24ubGVibGFu
# Y0BUQy5HQy5DQTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAJ2jjxuK
# u3KVvRgoP68UqnnoPvWh+REEDIk1Q3YifglLSHKKfDTGfsbzZ2LegOPnIHiUA/bD
# WfNS+aqxCJd2rVYOA6wLiFsNwV/AZjqwPqWqZX4fNJJszDMQBISTB0uYNveTlSRD
# HJa+bvtyO+rvWtMLqPiQo8tlNbV20DQikU+ntDeBxDHwS92oTrGIFQ5feXvQWuHE
# 8c2v+TVJmUOeO9ID6YYxfKF5F/jY0QrnaidaecK0R++DLpozU3ovAAEqkaF8x5F1
# 0Q8a+6sfrFY1omKhHDBHI8U9xpnCjY1tPtz/wsrA+MGzG1OfvMO4nH1GKrC/TdOD
# 5ptS+b8UwVAa3r0CAwEAAaNpMGcwDgYDVR0PAQH/BAQDAgeAMBMGA1UdJQQMMAoG
# CCsGAQUFBwMDMCEGA1UdEQQaMBiCFmFhcm9uLmxlYmxhbmNAVEMuR0MuQ0EwHQYD
# VR0OBBYEFPMyFCNOAIFHYMN12k4N5Hrskj5LMA0GCSqGSIb3DQEBBQUAA4IBAQBK
# +oM4WRRMkgMk/T0wpUDlpHk2wNRlHSGSciUaDPCK7vwdnWKNqWlj4/o7KVs7kpdv
# HThcYeHIvK5LoyVZXmlV00y+F3cLdpXOsxavtnnuz/Q/Hod7RfP2iicAsKlRUG0Z
# mDTy4wyoSPlRfZ3CB1kFo8tN8YwauslZqNHCBF3ChxNm4VWjXHBSwmNp+1Ro+36N
# SWDRfwSN4vEdblePgptEz2to9396cG9b+ivWIjMqAGJEne9xbF5L/L6cIbVLxBcb
# Cm9yn181p1oKRdv/hMf12OAfOu0Mv7qbvFUdJO0sySNCWkBnjjUUqDWQtm6ZDA24
# 68PpIcp+tqNfLzSxjpBsMYIB1jCCAdICAQEwNTAhMR8wHQYDVQQDDBZhYXJvbi5s
# ZWJsYW5jQFRDLkdDLkNBAhB3h9T7j/2RoUDr0YatkIGmMAkGBSsOAwIaBQCgeDAY
# BgorBgEEAYI3AgEMMQowCKACgAChAoAAMBkGCSqGSIb3DQEJAzEMBgorBgEEAYI3
# AgEEMBwGCisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEW
# BBSAFW+kYnkS6M2bc6eUCHLPMtssizANBgkqhkiG9w0BAQEFAASCAQAD/UqbwHM2
# DNflKnAnT3UEuU6nOtWV1kHuJl4MBon0yBJwP6gz/fbfwiOBlPuzZzWn1Wsfv3Fi
# jUetPyauklA3dzyNrIgzeEDs69Z6JD5Gbf53cweb204uMM8PoiOIYkEjWZdZhmW8
# yIrl1b3VVOYz4BoWwPEeCAyya55PHL4aflnFm0DFbwn2mQBYMUZz+sZxzh3+PjVw
# +tx8mEZ5Km3CC/wh+smExC/iYx2QHsinxDsoKu4wjx9eJBeyRy5916Xbs/c2EUlK
# 0rgtXgqXV50EiSPPAWoOXv60d7vIO2r3OuE8b2e1Wve6lhyGM6cFHRA8r5ZkH9DJ
# qNO0GDN0SBWu
# SIG # End signature block
