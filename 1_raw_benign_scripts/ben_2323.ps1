<#
.AUTHER
    CREATED BY: Mark Davis for ITSTG Free Usage.
    DATE: 13.03.2019
.DESCRIPTION
   Checks if network path is valid and map's drive to associated drive letter.
.OUTPUTS
   All logs will be saved under C:\ProgramData\CustomScripts
.NOTES
.FUNCTIONALITY
   1. Check if log folder exists > if not > Create folder and file path for logs.
   2. Checks if drive letters have any existing mapped drives associated > if Yes > Delete cached drive letter associations
   3. Checks if Network drive paths are accessable > If Yes > Map drive to drive letter
   4. If all else fails > Log errors to file 
#>

 $ScriptName = "MapNetworkDrive.ps1"
 $CustomScriptPath = "C:\ProgramData\CustomScripts"

function CreateLogs{
    Write-Output "Creating Log Files"
# Create customscript folder if non-existant
    $path = $(Join-Path $env:ProgramData CustomScripts)
    if (!(Test-Path $path))
    {
        Write-Verbose 'Custom scripts directory non-existant... Creating directory.'
        try{
            New-Item -Path $path -ItemType Directory -Force -Confirm:$false | Out-Null   
            Write-Output 'Custom scripts directory successfully created.'
        } catch {
            Write-Output 'Failed to create Custom Scripts Directory...'
        }             
    } else {
        Write-Output 'Custom Scripts Directory already exists.'
    }
# Creates a log file to monitor installation and execution if non-existent
    if(!(Test-Path($path + "\*$ScriptName*.log"))){
        Write-Output 'Log file non-existant.... Creating file.'
        try{
            $LogFile = New-Item "$CustomScriptPath\Applying_$ScriptName.log" -ItemType File
            Write-Output 'Successfuly created log file'
        }
        catch{
            Write-Output 'Failed to create log file...'
        }
    }else{
        Write-Output 'Log File already exists.'
    }
}

function DeleteOldDrives{  
#This is to clean up drive allocation as sometimes an error occurs if drive letter in use, even when path matches.
    if([System.IO.Directory]::Exists('H:')){
    Write-Output "Old Drve Cache Detected: Removing H:\"
        try{net use H: /delete}catch{Write-Output 'Failed to remove H:\ cache, review event logs.'}
    }
    if([System.IO.Directory]::Exists('O:')){
    Write-Output "Old Drve Cache Detected: Removing O:\"
        try{net use O: /delete}catch{Write-Output 'Failed to remove O:\ cache, review event logs.'}
    }
}

function MapDrives{

    $GetCurrentUser = $env:UserName # Get current user logged into machine (this should be the Azure AD username)
#Define Network Share Paths
    $NetworkShareNSW = Test-Path "\\ITSTG-NEW-FP01.ITSTG.local\homedrivesNSW\$GetCurrentUser"
    $NetworkShareVIC = Test-Path "\\ITSTG-NEW-FP01.ITSTG.local\homedrivesVIC\$GetCurrentUser"
    $NetworkShareQLD = Test-Path "\\ITSTG-NEW-FP01.ITSTG.local\homedrivesQLD\$GetCurrentUser"
    $NetworkShareSA = Test-Path "\\ITSTG-NEW-FP01.ITSTG.local\homedrivesSA\$GetCurrentUser"

#Map Home Drives
    if(!(Test-Path H:) -and ($NetworkShareNSW -eq $true)){
        New-PSDrive -Name "H" -PSProvider FileSystem -Root "\\ITSTG-NEW-FP01.ITSTG.local\homedrivesNSW\$GetCurrentUser" -Persist -Description "HomeDrive" -Scope "Global"
    }elseif(!(Test-Path H:) -and ($NetworkShareVIC -eq $true)){
        New-PSDrive -Name "H" -PSProvider FileSystem -Root "\\ITSTG-NEW-FP01.ITSTG.local\homedrivesVIC\$GetCurrentUser" -Persist -Description "HomeDrive" -Scope "Global"
    }elseif(!(Test-Path H:) -and ($NetworkShareQLD -eq $true)){
        New-PSDrive -Name "H" -PSProvider FileSystem -Root "\\ITSTG-NEW-FP01.ITSTG.local\homedrivesQLD\$GetCurrentUser" -Persist -Description "HomeDrive" -Scope "Global"
    }elseif(!(Test-Path H:) -and ($NetworkShareSA -eq $true)){
        New-PSDrive -Name "H" -PSProvider FileSystem -Root "\\ITSTG-NEW-FP01.ITSTG.local\homedrivesSA\$GetCurrentUser" -Persist -Description "HomeDrive" -Scope "Global"
    }else{
        Write-Output "DEBUG: Either user profile home drive does not exist, or no network paths could be established."
    }
}

function MapDataDrive{
    $NetworkShareData = Test-Path "\\ITSTG-NEW-FP01.ITSTG.local\Data"
# Map Data Drive
    if(!(Test-Path O:) -and $NetworkShareData -eq $true) {
        New-PSDrive -Name "O" -PSProvider FileSystem -Root "\\ITSTG-NEW-FP01.ITSTG.local\Data" -Persist -Description "Data" -Scope "Global"
    }else{
        Write-Host "DEBUG: Could not establish connection to Data drive. Please check connection."
    }
}

CreateLogs
Start-Transcript "$CustomScriptPath\Applying_$ScriptName.log" -Append -Force
DeleteOldDrives
MapDrives
MapDataDrive
Stop-Transcript