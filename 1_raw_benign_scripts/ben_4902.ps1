############################################################################################################
## DISCLAIMER:
## Copyright (c) Microsoft Corporation. All rights reserved. This
## script is made available to you without any express, implied or
## statutory warranty, not even the implied warranty of
## merchantability or fitness for a particular purpose, or the
## warranty of title or non-infringement. The entire risk of the
## use or the results from the use of this script remains with you.
##
##  Aline Tognini (aline.tognini@microsoft.com) - 8/2/2021
##
##  Get-InstalledPSModules - lists info on installed M365 management modules. 
##    This can be helpful to validade if your local environment meets the minimum requirements to
##    perform other maintenance tasks using common PS modules.
##
############################################################################################################

# Checking PS Version:
$PSversionTable

# Install / Uninstall / Update verbs, for Module maintenance:
# https://docs.microsoft.com/en-us/powershell/module/powershellget/install-module?view=powershell-7.1

# SharePoint Online Management Shell
# Documentation      = https://docs.microsoft.com/en-us/powershell/sharepoint/sharepoint-online/connect-sharepoint-online?view=sharepoint-ps
# Minimun PS Version = 2.0
# Install location   = https://www.powershellgallery.com/packages/Microsoft.Online.SharePoint.PowerShell
#  Get Updates: Update-Module -Name Microsoft.Online.SharePoint.PowerShell   
#  Current version: 16.0.21411.12000 (8/2/2021)
#
Get-Module -Name Microsoft.Online.SharePoint.PowerShell -ListAvailable | Select Name,Version


# PnP PowerShell
# Documentation      = https://docs.microsoft.com/en-us/powershell/sharepoint/sharepoint-pnp/sharepoint-pnp-cmdlets?view=sharepoint-ps
# PnP PowerShell is a cross-platform PowerShell Module,
#  and successor of SharePointPnPPowerShellOnline, which is now regarded legacy and not maintained anymore.
#
# Current version = 1.7.0 (8/2/2021)
#
Get-Module -Name PnP.PowerShell -ListAvailable | Select Name,Version

# Exchange Online Management Shell v2
# Documentation      = https://docs.microsoft.com/en-us/powershell/exchange/exchange-online-powershell-v2?view=exchange-ps
# Install location   = https://www.powershellgallery.com/packages/ExchangeOnlineManagement
#  Get Updates: Update-Module -Name ExchangeOnlineManagement   
#  Current version: 2.0.5 (8/2/2021)
#
Get-Module -Name ExchangeOnlineManagement -ListAvailable | Select Name,Version

# Power Platform PowerShell Administration
# Documentation      = https://docs.microsoft.com/en-us/power-platform/admin/powerapps-powershell
# Install location   = https://www.powershellgallery.com/packages/Microsoft.PowerApps.Administration.PowerShell
#  Get Updates: Update-Module -Name Microsoft.PowerApps.Administration.PowerShell   
#  Current version: 2.0.127 (8/2/2021)
#
Get-Module -Name Microsoft.PowerApps.Administration.PowerShell -ListAvailable | Select Name,Version

# Power Platform PowerShell Maker
# Documentation      = https://docs.microsoft.com/en-us/power-platform/admin/powerapps-powershell
# Install location   = https://www.powershellgallery.com/packages/Microsoft.PowerApps.PowerShell
#  Get Updates: Update-Module -Name Microsoft.PowerApps.PowerShell 
#  Current version: 1.0.20 (8/2/2021)
#
Get-Module -Name Microsoft.PowerApps.PowerShell -ListAvailable | Select Name,Version