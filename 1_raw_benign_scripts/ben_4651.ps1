Function Shutdown-IPRange {

    <#
    .SYNOPSIS
    Shutdown-IPRange - Shuts down specified floors/sites
    .PARAMETER SiteName
    The site name of Keighley, Stockport or Crosshills - Mandatory
    .PARAMETER Floors
    The floor number of 1 or 2 - Alias "Building". Building 1 is Resolution House, Building 2 is Pinnacle House. Use Floor 1 for Chester.
    .PARAMETER LogFilePath
    The log file path name 
    .PARAMETER TaskLogFile
    If you are running this as a scheduled task. This creates 7 txt files in the "C:\Scripts\PowerShell\WOL\Logs\$LogFileName.txt" directory.
    .EXAMPLE
    Shutdown-IPRange -SiteName Keighley,Stockport -Floors 1,2 -LogfilePath C:\Output.txt
    .EXAMPLE
    Shutdown-IPRange -SiteName Keighley,Crosshills -Floors 1 -TaskLogFile

    #>


    [cmdletbinding()]

    Param (
        [parameter(mandatory=$true, position=1)] 
        [string[]]$SiteName,
        [parameter(mandatory=$true, position=2)] 
        [alias("Building")]
        [string[]]$Floors,
        [parameter(position=3)]
        [string]$LogFilePath,
        [parameter()]
        [switch]$TaskLogFile
    )

    #Define a Boolean value to indicate if no logging is to be setup
    If (($LogFilePath.Length -lt 1 ) -and ($TaskLogFile -eq $False)) {

       $GenerateLogFile = $False

    }
    else {
       $GenerateLogFile = $True
    }

    #check the SiteName parameter
    ForEach($Site in $SiteName) {
        
        If (($Site -ne "Keighley") -and ($Site -ne "Stockport") -and ($Site -ne "Crosshills") -and ($Site -ne "Chester")) {

        Write-Warning "`n`nPlease specify a site name of:`n`nKeighley`nStockport`nChester`nor Crosshills`n`nand try again."
        Return

        }

    }

    #check the floor parameter

    ForEach($floor in $Floors) {
        
        If (($floor -ne 1) -and ($Floor -ne 2)) {

        Write-Warning "`n`nPlease specify a floor number of 1 or 2 and try again."
        Return

        }
    }

    #check to ensure you are not using both the log file and the tasklog file parameters
    If (($LogFilePath.Length -gt 0 ) -and ($TaskLogFile -eq $True)) {
        
        $LogFilePath
        Write-Warning "Please Specify either a log file path OR the TaskLogFile switch"
        Return
    }

    If ($LogFilePath.Length -gt 0) {

         Write-Output "`n`nLog File Created @ $LogFilePath`n"
    }


    #if we are setting up a task log file
    If ($TaskLogFile -eq $true) {
        
        $LogFileName = (get-date).dayofweek #Check day of week
        $LogFilePath = "C:\Scripts\PowerShell\WOL\Logs\$LogFileName.txt"

        New-Item $LogFilePath -type file -force | Out-Null #Create new log file named by day, overwrites existing.

        Write-Output "`n`nLog File Created @ $LogFilePath`n"
        
    }
    
    If (($LogFilePath.Length -gt 0) -or ($TaskLogFile -eq $True)) {
        
        #setup the header if we need a log file
        $CSVHeader = "Start Date/Time, Site, Floor, IP, Shutdown"
        $CSVHeader | Out-File -filepath $LogFilePath -append 
        
    }


    #Output The Data into a PSObject which we can use to compare with the current list
    $NewMacTable = ForEach($Site in $SiteName) {
        
        ForEach($Floor in $Floors) {
        
            $LastOctet = 21 #reset this after each loop

            If(($Site -eq "Keighley") -and ($floor -eq 1)) { $IPPrefix = "10.36.165." }
            elseIf(($Site -eq "Keighley") -and ($floor -eq 2)) { $IPPrefix = "10.36.166." }
            elseIf(($Site -eq "Stockport") -and ($floor -eq 1)) { $IPPrefix = "10.37.21." }
            elseIf(($Site -eq "Stockport") -and ($floor -eq 2)) { $IPPrefix = "10.37.22." }
            elseIf(($Site -eq "Crosshills") -and ($floor -eq 1)) { $IPPrefix = "10.36.149." }
            elseIf(($Site -eq "Crosshills") -and ($floor -eq 2)) { $IPPrefix = "10.36.150." }
            elseIf(($Site -eq "Chester") -and ($floor -eq 1)) { $IPPrefix = "10.37.53." }
            else {
                Write-Warning "Site:$Site and Floor:$Floor Combination Not found"
                Break
            }

            while ($LastOctet -lt 35) {

                $IP = $IPPrefix + $LastOctet
               
               #If the ping returns false (with quiet switch) i.e. the machine is switched off.
                If (-not(test-Connection -ComputerName $IP -Count 1 -Quiet)) {
                     $ShutdownCheck = $False
                     Write-Host "Problem Shutting down: $IP"

                }
                #if there is a response..
                else {
                    $ShutdownCheck = $True

                    #Check if it is a laptop, if so, ignore
                    $Laptop = GWMI -Class "Win32_PhysicalMemory" -comp $IP -Filter "FormFactor <> 12"

                    If ($Laptop -ne $null) {
                        

                        #Search the computer for network cards
                        $NetAdaptor = GWMI -Class "Win32_NetworkAdapterConfiguration" -name "root\CimV2" -comp $IP -filter "IpEnabled = TRUE"
                        
                        #create an object so that we can add this later on. Always adding the first adaptor it finds.
                        [pscustomobject][ordered]@{
                            IP = $IP
                            mac = $NetAdaptor.MacAddress
                        }

                        #This checks to see if there are multiple network adaptors live on the computer.
                        If ($NetAdaptor.Count -gt 1) {
                            
                            Write-Host "$IP has $($NetAdaptor.Count) network cards installed. Please resolve. Skipping for now.."
                        }
                        else {
                            Write-Host "Shutdown Command sent to: $IP"                  
                            #Stop-Computer -ComputerName $IP -Force -ErrorAction Stop | Out-Null
                        }
                    }
                    else {
                        Write-Host "$IP is a Laptop user. Ignoring.."
                    }
                }

               if($GenerateLogFile -eq $True) {

                    $StartDateTime = (get-date).ToString()
                    $LogData = $StartDateTime + "," + $Site + "," + $Floor + "," + $IP + "," + $ShutdownCheck

		            $LogData | Out-File -filepath $LogFilePath -append
                }

                #increment the last octet value
                $LastOctet++

            } #while loop

        } #Floor ForEach
    } #Site ForEach

    If ($TaskLogFile -eq $True) {
        
        #Check if the file exists
        If (Test-Path -Path C:\Scripts\PowerShell\WOL\Logs\MasterMACList.csv) {
            
            #Import the Current Master List
            $CurrentMasterMACList = Import-CSV -LiteralPath C:\Scripts\PowerShell\WOL\Logs\MasterMACList.csv

            #Backup the Current Master List 
            Write-Output "`nBacking Up Current List...."

            #create a directory if one does not exist
            If (-not(Test-Path -Path C:\Scripts\PowerShell\WOL\Logs\MasterListBackup)) {

                Write-Output "Creating Directory to hold Master List..."
                New-Item -Path "C:\Scripts\PowerShell\WOL\Logs\" -ItemType Directory -Name MasterListBackup | Out-Null

            }
            Copy-Item -Path C:\Scripts\PowerShell\WOL\Logs\MasterMACList.csv -Destination "C:\Scripts\PowerShell\WOL\Logs\MasterListBackup\MasterMACList-$(get-date -f dd-MM-yyyy).bak" -Force
        }

        #Check to see if the master list is not empty
        If ($CurrentMasterMACList -ne $Null) {
            
            Write-Output "`nOriginal Master List...."
            Write-Output $CurrentMasterMACList | sort IP | ft -AutoSize

            #Check to see if any machines have been found online at all.
            If ($NewMacTable -ne $Null ) {

                #Get a list of all the differences between the new list and the existing list, where it be the IP has changed or the MAC
                $DifferenceList = Compare-Object -ReferenceObject $CurrentMasterMACList -DifferenceObject $NewMacTable -Property Mac,IP |
                where {$_.SideIndicator -eq "=>"} | Select Mac,IP
            }

            #Check to see if there are any differences to process
            If ($DifferenceList -ne $Null) {

                Foreach ($Diff in $DifferenceList) {
    
                    #This checks each IP address that is in the difference list and removes it, ensuring we have no duplicates.
                    $CurrentMasterMACList = $CurrentMasterMACList | where IP -ne $Diff.IP
                }

                Write-Output "`nMaster List after removing differences...."
                Write-Output $CurrentMasterMACList | sort IP | ft -AutoSize


                Write-Output "`nDifference List...."
                Write-Output $DifferenceList | sort IP | ft -AutoSize

                #with any potential duplicates removed, add the differences back into the existing list
                $FinalList = $CurrentMasterMACList + $DifferenceList

                Write-Output "`nNew Master Mac Table...."
                Write-Output $FinalList | sort IP | ft -AutoSize
            }
            else {
                
                #if there are no differences, then the current list just stays the same
                Write-Output "`nNo Differences Found. Copying current list back to master list...."
                $FinalList = $CurrentMasterMACList
            }

        }
        else {
            
            Write-Output "`nCurrent Master List Empty or Missing. Creating a new one`n`n"
            #If the Current Master list is empty, just put the new mac list in the current mac list
            $FinalList = $NewMacTable
        }
        #write the final list back to file
        $FinalList | select IP, mac | sort IP | Export-Csv -Path "C:\Scripts\PowerShell\WOL\Logs\MasterMACList.csv" -NoTypeInformation -Force

    }
    
}
Shutdown-IPRange -SiteName Stockport -Floors 1 -TaskLogFile