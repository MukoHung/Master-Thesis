Function Start-Deployment {
    <#
.SYNOPSIS
Start a PDQ Deploy Deployment on a target machine

.DESCRIPTION
Trigger a PDQ Deploy deployment to start locally or on a remote machine with PDQ Deploy installed

.EXAMPLE
Start-Deployment -PackageName "Example Package" -Targets "Wolverine"

.EXAMPLE
Start-Deployment -ScheduleName "Example Schedule" -Targets "Wolverine"

.EXAMPLE
Start-Deployment -ScheduleID 123 -Targets "Wolverine"

.PARAMETER DeployComputerName
The machine with PDQ Deploy installed. This defaults to the local machine

.PARAMETER PackageName
The names of packages on DeployMachine that you wish to use

.PARAMETER ScheduleName
The names of schedules on DeployMachine that you wish to use

.PARAMETER ScheduleID
The schedule IDs on DeployMachine that you wish to use

.PARAMETER Targets
A list of targets that you wish to deploy a package or schedule to. Leave blank if you wish to target the local machine.
#>
    [cmdletbinding(
        SupportsShouldProcess = $True
    )]
    Param(

        [String]$DeployComputerName = $env:COMPUTERNAME,

        [Parameter (ParameterSetName = "Package")]
        [string]$PackageName,

        [Parameter (ParameterSetName = "Package")]
        [String[]]$Targets = $env:COMPUTERNAME,

        [Parameter (ParameterSetName = "Schedule")]
        [string]$ScheduleName,

        [Parameter (ParameterSetName = "ScheduleID")]
        [Int]$ScheduleID

    )

    Process {

        #Build credential for Invoke-Command
        $PasswordFile = "c:\Secure\password.txt"
        $KeyFile = "C:\Secure\aes.key"
        $key = Get-Content $KeyFile

        $Username = "" #Fill this in
        $Password = Get-Content $PasswordFile | ConvertTo-SecureString -Key $key
        $MyCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $Username, $Password




        # Add parameters to a hashtable to easily push into invoke-command as an argument
        $MyParameters = @{
            DeployComputerName = $DeployComputerName
            PackageName        = $PackageName
            Targets            = $Targets
            ScheduleName       = $ScheduleName
            ScheduleID         = $ScheduleID
            DeploymentType     = $PSCmdlet.ParameterSetName
        }

        # This outputs a powershell.log to the root directory of the target machine
        $MyParameters | Out-String | Out-File C:\powershell.log -Append

        # Testing to see if PSRemoting is enabled
        If (Test-WSMan -ComputerName $DeployComputerName) {

            Write-Verbose "Test-WSMan test passed on $DeployComputerName"

            # Added -Whatif capability to script
            If ( $PSCmdlet.ShouldProcess($DeployComputerName, "Starting deployment with the following parameters:`n $($MyParameters | Out-String)") ) {

                # Connect to Deploy machine and attempts to start a deployment
                Invoke-Command -ComputerName $DeployComputerName -ArgumentList ($MyParameters) -Credential $MyCredential -ScriptBlock {
                    Param ($MyParameters)

                    # This outputs a powershell.log to the root directory of the deploy machine
                    $MyParameters | Out-String | Out-File C:\powershell.log

                    # Build command string based on deployment type
                    Switch ($MyParameters.DeploymentType) {

                        "Package" {

                            $PDQDeployCommand = "pdqdeploy deploy -package ""$($MyParameters.PackageName)"" -targets $($MyParameters.Targets)"

                        }

                        "Schedule" {

                            $DB = "$env:ProgramData\Admin Arsenal\PDQ Deploy\Database.db"
                            $SQL = "SELECT ScheduleID FROM Schedules WHERE Name = '$($MyParameters.ScheduleName)' COLLATE NOCASE;"
                            $ScheduleID = $SQL | sqlite3.exe $db
                            $PDQDeployCommand = "pdqdeploy StartSchedule -ScheduleId $ScheduleID"

                        }

                        "ScheduleID" {
                            $DB = "$env:ProgramData\Admin Arsenal\PDQ Deploy\Database.db"
                            $SQL = "UPDATE Targets SET Name = '$($MyParameters.Targets)' WHERE TargetId = '1005';"
                            Write-Output "Executing: $SQL" | Out-File C:\powershell.log -Append
                            $SQL | sqlite3.exe $DB
                            Try {Restart-Service -DisplayName 'PDQ Deploy' -Force}
                            Catch { $_.Exception.Message}
                            Start-Sleep -Seconds 5
                            $PDQDeployCommand = "pdqdeploy StartSchedule -ScheduleId $($MyParameters.ScheduleID)"

                        }
                    }

                    # Append the actual command that will be run to powershell.log
                    "Invoke-command: $PDQDeployCommand" | Out-File C:\powershell.log -Append

                    # Create and invoke scriptblock
                    $PDQDeployCommand = [ScriptBlock]::Create($PDQDeployCommand)
                    $PDQDeployCommand.Invoke()

                }
            }
        }
    }#end process block

}#end function

#region Resize the partition to the correct size. This might take a minute, as it does math.

#Partition resize for UEFI devices
If ((Get-Partition).Count -gt '2') {
    Try {
        $size = Get-PartitionSupportedSize -DiskNumber 0 -PartitionNumber 4

        Resize-Partition -DiskNumber 0 -PartitionNumber 4 -Size $size.SizeMax
    }

    Catch {

        $_.Exception.Message | Out-File C:\powershell.log -Append

    }
}

#Partition resize for BIOS devices
Else {

    Try {

        $size = Get-PartitionSupportedSize -DiskNumber 0 -PartitionNumber 1

        Resize-Partition -DiskNumber 0 -PartitionNumber 1 -Size $size.SizeMax

    }

    Catch {

        $_.Exception.Message | Out-File C:\powershell.log -Append

    }
}#end partition resize
#endregion

#region Driver Injection stuff
<#
 Run pnputil to catch any failed drivers from the SysPrep process.
 Use this block, don't use this block, whatever.
 If you don't do driver injection with Fog, delete it
#>

$DriverPath = "C:\Drivers"
$driversCollection = (Get-ChildItem -Path $DriverPath -Filter "*.inf" `
        -Recurse -ErrorAction SilentlyContinue |
        Select-Object -ExpandProperty Fullname)

foreach ($driver In $driversCollection) {

    # Add and install driver package
    pnputil.exe -i -a $driver | Out-File C:\powershell.log -Append

}#end pnputil loop
#endregion

#region Invocation of actual commands
Start-Deployment -DeployComputerName "" -PackageName "" #fill in to suit
Remove-Item -Recurse -Force C:\Secure #this is where I store the encrypted files on the image. YMMV
#endregion