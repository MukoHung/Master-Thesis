<#
.Synopsis
   Exports all scripts (discovery and remediation) used in all SCCM Compliance Setting Configuration Items
.DESCRIPTION
   This script connects to the SCCM database to retrieve all Compliance Setting Configuration Items. It then processes each item looking for
   discovery and remediation scripts for the current (latest) version. It will export any script found into a directory structure.
.NOTES
    Requirements - 'db_datareader' permission to the SCCM SQL database with the account running this script.
    Parameters - set the parameters below as required
#>




################
## PARAMETERS ##
################

# Root directory to export the scripts to
$RootDirectory = "C:\temp" 

# Name of the subdirectory to create
$SubDirectory = "Compliance_Settings_CI_Scripts"

# SCCM SQL Server (and instance where applicable)
$SQLServer = 'mysqlserver\inst_sccm'

# SCCM Database name
$Database = 'CM_ABC'




##################
## SCRIPT START ##
##################

# Create the subdirectory if doesn't exist
If (!(Test-Path "$RootDirectory\$SubDirectory"))
{
    New-Item -Path "$RootDirectory" -Name "$SubDirectory" -ItemType container | Out-Null
}

# Define the SQL query
$Query = "
Select * from dbo.v_ConfigurationItems
where CIType_ID = 3
and IsLatest = 'true'"

# Run the SQL query
$connectionString = "Server=$SQLServer;Database=$Database;Integrated Security=SSPI"
$connection = New-Object -TypeName System.Data.SqlClient.SqlConnection
$connection.ConnectionString = $connectionString
$connection.Open()
$command = $connection.CreateCommand()
$command.CommandText = $Query
$reader = $command.ExecuteReader()
$ComplianceItems = New-Object -TypeName 'System.Data.DataTable'
$ComplianceItems.Load($reader)
$connection.Close()

# Process each compliance item returned
$ComplianceItems | foreach {
    
    # Set some variables
    $PackageVersion = "v $($_.SDMPackageVersion)"
    [xml]$Digest = $_.SDMPackageDigest
    $CIName = $Digest.ChildNodes.OperatingSystem.Annotation.DisplayName.Text

    # Create subdirectory structure if doesn't exist: configuration item name > current package version
    If (!(Test-Path "$RootDirectory\$SubDirectory\$CIName"))
    {
        New-Item -Path "$RootDirectory\$SubDirectory" -Name "$CIName" -ItemType container | Out-Null
    }
    
    If (!(Test-Path "$RootDirectory\$SubDirectory\$CIName\$PackageVersion"))
    {
        New-Item -Path "$RootDirectory\$SubDirectory\$CIName" -Name "$PackageVersion" -ItemType container | Out-Null
    }

    # Put each compliance item setting in XML format into an arraylist for quick processing
    $Settings = New-Object System.Collections.ArrayList
    $Digest.DesiredConfigurationDigest.OperatingSystem.Settings.RootComplexSetting.SimpleSetting | foreach {
        [void]$Settings.Add([xml]$_.OuterXml)
        }

    # Process each compliance item setting
    $Settings | foreach {
        
        # Only process if this setting has a script source
        If ($_.SimpleSetting.ScriptDiscoverySource)
        {
            # Set some variables
            $SettingName = $_.SimpleSetting.Annotation.DisplayName.Text
            $DiscoveryScriptType = $_.SimpleSetting.ScriptDiscoverySource.DiscoveryScriptBody.ScriptType
            $DiscoveryScript = $_.SimpleSetting.ScriptDiscoverySource.DiscoveryScriptBody.'#text'
            $RemediationScriptType = $_.SimpleSetting.ScriptDiscoverySource.RemediationScriptBody.ScriptType
            $RemediationScript = $_.SimpleSetting.ScriptDiscoverySource.RemediationScriptBody.'#text'
            
            # Create the subdirectory for this setting if doesn't exist
            If (!(Test-Path "$RootDirectory\$SubDirectory\$CIName\$PackageVersion\$SettingName"))
            {
                New-Item "$RootDirectory\$SubDirectory\$CIName\$PackageVersion" -Name $SettingName -ItemType container -Force | Out-Null
            }
            
            # If a discovery script is found
            If ($DiscoveryScript)
            {
                # Set the file extension based on the script type
                Switch ($DiscoveryScriptType)
                {
                    Powershell { $Extension = "ps1" }
                    JScript { $Extension = "js" }
                    VBScript { $Extension = "vbs" }            
                }
                
                # Export the script to a file
                New-Item -Path "$RootDirectory\$SubDirectory\$CIName\$PackageVersion\$SettingName" -Name "Discovery.$Extension" -ItemType file -Value $DiscoveryScript -Force | Out-Null
            }
            
            # If a remediation script is found
            If ($RemediationScript)
            {
                # Set the file extension based on the script type
                Switch ($RemediationScriptType)
                {
                    Powershell { $Extension = "ps1" }
                    JScript { $Extension = "js" }
                    VBScript { $Extension = "vbs" }  
                }
                
                # Export the script to a file
                New-Item -Path "$RootDirectory\$SubDirectory\$CIName\$PackageVersion\$SettingName" -Name "Remediation.$Extension" -ItemType file -Value $RemediationScript -Force | Out-Null
            }
        }
    }
}

<# For reference: CIType_IDs

1	Software Updates
2	Baseline
3	OS
4	General
5	Application
6	Driver
7	Uninterpreted
8	Software Updates Bundle
9	Update List
10	Application Model
11	Global Settings
13	Global Expression
14	Supported Platform
21	Deployment Type
24	Intend Install Policy
25  DeploymentTechnology
26  HostingTechnology
27  InstallerTechnology
28  AbstractConfigurationItem
60	Virtual Environment

#>