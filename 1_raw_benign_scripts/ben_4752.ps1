############################################
# Written on 27 JUL 2014                   #
# By: CW2 Dieppa, Phillip A.               #
# This script will perform preventative    #
# maintenance on the Exchange servers by   #
# doing the following:                     #
# 1) Delete the mailbox dumpsters >100MB   #
# 2) Properly restart the Exchange servers #
############################################
cd $PSScriptRoot
#############GLOBAL VARIABLES###############
$configFile = "config.ini"
############################################

#use dot-notation to pull commonly used functions.
. "config\common.ps1"

#get the config file's Fully Qualified name to pass into the setConfigData
$configFQName = Get-ChildItem -Path config\config.ini -ErrorAction SilentlyContinue | Select-Object FullName

#load the config.ini
testConfigFile $configFQName
$configData = @{}
$configData = setConfigData $configFQName.FullName.ToString()

#make the log directory
if (!$(Test-Path $configData.LogDirectory)) { 
    #Write-Host "Making Log Directory"
    mkdir $configData.LogDirectory | Out-Null
}
#check for an update
$versionInfo = @()

Function mainMenuAction ($result) {
    
    switch ($result) {
        1 {
            #AD User Tools
            $directory = Get-Item '.\Active Directory'
            displayToolLauncher $directory $configData
        }
        
        2 {
            #Cyber Security Tools
            $directory = Get-Item '.\Cyber Security'
            displayToolLauncher $directory $configData

        }

        3 {
            if ($choices[2] -eq "Exit") {
                #exit the toolkit
                exit
            }
            #Update
            if ($updateAvailable.Contains("!!!")) {
                #Update Available
                $logName = "Update" + $versionInfo[1].Major + "-" + $versionInfo[1].Minor + "-" + $versionInfo[1].Revision
                $logDir = $configData.LogDirectory + "\$logName.log"

                <#Update Guidelines:
                    Major versions trigger a complete update. The config.ini file is backed up and migrated to the newest version, plus any minor and revision changes are made.
                    Minor versions trigger an update to .ps1 files and their dependencies such as CSV files. If a CSV file changes, it triggers a minor update
                    Revision versions trigger an update to only existing .ps1 files. If the code is corrected without notice to the user, it's a revision
                #>
                Write-Output "Breakpoint!"
                #Determines the type of update that will be performed. Major, Minor, or Revision
                if ($versionInfo[0].Major -lt $versionInfo[1].Major) {
                    #Major Update
                    robocopy $configData.UpdateDirectory.ToString() $configData.ToolRootDirectory.ToString() *.ps1 *.csv *.jpg *.exe /R:3 /W:5 /TEE /ETA /S /LOG:$logDir /XD Development HBSS SharePoint Workstations inactive* /XF config.ini

                    #Schema could have changed during the major revision. Transfer the current config data to the serverConfigData format and update the config.ini file with the changes.
                    Migrate-ConfigData $configData $configFQName.FullName.ToString()

                    #The delay helps ensure the files are not being accessed during the next step
                    delayInSeconds(1)

                    #Update Revision number in config.ini file
                    Update-ConfigVersion $configData $configFQName.FullName.ToString()
           
                } elseif ($versionInfo[0].Minor -lt $versionInfo[1].Minor) {
                    #Minor Update
                    robocopy $configData.UpdateDirectory.ToString() $configData.ToolRootDirectory.ToString() *.ps1 *.csv *.jpg *.exe /R:3 /W:5 /TEE /ETA /S /LOG:$logDir /XD Development HBSS SharePoint Workstations inactive* /XF config.ini

                    #Update Revision number in config.ini file
                    Update-ConfigVersion $configData $configFQName.FullName.ToString()

                } elseif ($versionInfo[0].Revision -lt $versionInfo[1].Revision) {
                    #Revision Update
                    <#
                    /R:3  - Retry limit to 3
                    /W:5  - Wait time between retries (in seconds)
                    /TEE  - Log output to console
                    /ETA  - Display estimated time of arrival
                    /S    - Copy subdirectories but not empty ones
                    /LOG: - Create a log file
                    /XD   - Exclude Directories
                    *.ps1 - Only copy .ps1 files
                    #>
                    robocopy $configData.UpdateDirectory.ToString() $configData.ToolRootDirectory.ToString() *.ps1 *.jpg /R:3 /W:5 /TEE /ETA /S /LOG:$logDir /XD Development HBSS SharePoint Workstations inactive* /XF config.ini

                    #Update Revision number in config.ini file
                    Update-ConfigVersion $configData $configFQName.FullName.ToString()
                } 

            } else {
                #No update Available.
            }
            #Return back to the script
            #& '.\Launcher.ps1' 
        }
        
        4 {
            if ($choices[3] -eq "Exit") {
                #exit the toolkit
                exit
            }

            #Present a menu to update the config.ini file's revision number
            $title = "Upload Wizard"
            $choices = @("Publish Major Version", 
            "Publish Minor Version",
            "Publish Revision", 
            "Cancel")
            $versionText1 = "Clients perform a complete update. The config.ini file is backed up and migrated to the newest version, plus any minor and revision changes are made."
            $versionText2 = "Clients perform an update to .ps1 files and their dependencies such as CSV files. If a CSV file format changes, it should be a minor update"
            $versionText3 = "Revision versions trigger an update to only existing .ps1 files. If the code is corrected without operational impact to the user, it's a revision"
            $info = @("Major Versions", $versionText1, "Minor Versions", $versionText2, "Revisions", $versionText3)

            [int]$result = displayMenu $title $choices $info

            #Only accept data within the bounds of the choices - reject everything else.
            if (($result -le 0) -or ($result -gt $choices.Length)) {
                $result = 0
            }

            #Automatically update the config.ini file
            switch ($result) {
                1 {
                    #Major Versions
                    Increment-ConfigVersion $configData $configFQName.FullName.ToString() 1
                }

                2 {
                    #Minor Versions
                    Increment-ConfigVersion $configData $configFQName.FullName.ToString() 2
                }

                3 {
                    #Revisions
                    Increment-ConfigVersion $configData $configFQName.FullName.ToString() 3
                }

                4 {
                    exit
                }

            }

            #Delete the server directory
            Remove-Item -Path ($configData.UpdateDirectory.ToString() + "\*") -Force -Recurse

            #Upload the toolkit to the server
            $logName = "Update - " + $(Get-Date -Format yyyymmdd)
            $logDir = $configData.ToolRootDirectory.ToString() + "\logs\$logName.log"
            if (!(Test-Path $logDir)) {
                Add-Content $logDir $logName -Force
            }
            robocopy  $configData.ToolRootDirectory.ToString() $configData.UpdateDirectory.ToString() *.ini *.ps1 *.csv *.jpg *.exe *.msc version.txt /R:3 /W:5 /TEE /ETA /S /LOG:$logDir /XD Development HBSS SharePoint Workstations inactive* logs /XF gamesDisctionary.ini

            delayInSeconds(5)

            #Return back to the script
            #& '.\Launcher.ps1' 
        }

        5 {
            #Admin Menu
            $directory = Get-Item '.\Admin'
            displayToolLauncher $directory $configData
        }
        
        6 {
            #Exit the script
            exit
        }
        
        default {
               
        }
    }
}


Function main {
    #Main Loop
    while (-1) {
    cd $PSScriptRoot
        #Show the main menu
        $result = 0
        while ($result -eq 0) {
            #Clear the screen
    
            $title = "Server Administration Toolkit"

            $choices = @()
            $choices += "Active Directory Tools"
            $choices += "Cyber Security Tools"

            #Check for an update
    
            $updateAvailable = ""
            if ($configData.EnableUpdates.Contains("true")) {
                $versionInfo = Check-ConfigVersion $configData
                $updateAvailable = " " + $versionInfo[2]
                $choices += "Update$updateAvailable"
                if ($configData.EnableAdminUploader.Equals("true")) {
                    $choices += "Upload Toolkit (Admin Only)"
                }
            }
            $choices += "Admin"
            $choices += "Exit"
  
            <#
            $choices = @("Active Directory Tools",
            "Exchange Server Tools", 
            "Update$updateAvailable",
            "Exit")
    
            #>
            $info = @("Toolkit Version", $configData.Version.Trim(), "Currently Runninng As", $env:USERNAME)
            $result = 0
            $result = displayMenu $title $choices $info

            #Only accept data within the bounds of the choices - reject everything else.
            if (($result -le 0) -or ($result -gt $choices.Length)) {
                $result = 0
            }

        }



        mainMenuAction($result)
    }
}

#Check for admin rights
cls
If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "This toolkit requires either OA or WA rights in order to work properly."
    Write-Host "`nDo you want to try elevating to Local Administrator before proceeding?`nYou are currently running as: $env:username"
    
    #Determine Values for Choice  
    $choice = [System.Management.Automation.Host.ChoiceDescription[]] @("&Elevate Credentials","&Current Credentials")  
  
    #Determine Default Selection  
    [int]$default = 1  
  
    #Present choice option to user  
    $userchoice = $host.ui.PromptforChoice("Notice","Please select a choice to continue.",$choice,$default)  
  
    #Write-Debug "Selection: $userchoice"  
  
    #Determine action to take  
    Switch ($Userchoice) {  
        0 {  
            #Attempt to elevate the user
            $launcher = $PSScriptRoot + "\Launcher.ps1"
            try {
                #Write-Host $launcher
                Start-Process powershell -Verb runas -ArgumentList "-Command `"powershell -file `"`"$launcher`"`"`""
            } catch {
                Write-Warning "Failed to elevate the user. Entering the toolkit as a normal user."
                Sleep 5
                main
            }

        }  
            
        1 {  
            #Continue using current credentials  
            main
        }  
    }  
} else {
    main
}

