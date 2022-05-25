# function to test connection

Function test-ping{

    Param
    ( [string] $compName)
        
        Try{ Test-Connection -computername $compName -count 1 -EA stop 
        }catch{
                Write-Warning "$_"
        }
        
    }

# Creates objects for machines it was unable to connect to

Function Make-object{
    
    
    Param(
         [Parameter(Mandatory=$True)]
                    [string] $Computername,
                                   
         [Parameter(Mandatory=$True)]
                    [string] $status,

         [Parameter(Mandatory=$false)]
                    [string] $MNP = ''
)
          $prop = [ordered]@{'ComputerName' = $Computername;'StartTime' = "                  ";
                  'UpTime(Days)' = "         "; 'Status' = $status; 'MightNeedPatched' = $MNP}
          
          New-Object psobject -Property $prop | 
                format-table ComputerName, StartTime, 'UpTime(Days)', status, MightNeedPatched
          
    }
    
<#
.Synopsis
   Establishes the time since the the last reboot in days to the nearest 1/10 of a day.

.DESCRIPTION
   Establishes the time since the last reboot on a single machine or a number of machines 
   this can be supplied as a command line argument or from a pipline input. If no computername 
   is given it will default to 'localhost'

.EXAMPLE
   This example gets the uptime of a single computer
   get-uptime -ComputerName 'Acomputer'

    ComputerName StartTime           UpTime(Days) Status MightNeedPatched
    -------------- ---------           ------------ ------ ----------------
    Acomputer      13/01/2016 02:36:32 0.8          OK                False

.EXAMPLE
   this example shows the contents of names.txt being piped to the command
   get-content c:\scripts\names.txt | get-uptime

    ComputerName StartTime           UpTime(Days) Status MightNeedPatched
    -------------- ---------           ------------ ------ ----------------
    Acomputer      13/01/2016 02:36:32 0.8          OK                False

    ComputerName StartTime           UpTime(Days) Status MightNeedPatched
    -------------- ---------           ------------ ------ ----------------
    Aserver        13/01/2016 02:36:32 0.8          OK                False

.INPUTS
   acceptepts computernames piped in or as arguments from the commandline. 

.OUTPUTS
   Outputs an object for each computer containing the Computer Name, start time, total uptime,
   the status (of either OK, Error or Offline) and if it has been up for more than 30 day that
   it may need patching.
#>
function get-uptime
{
    [CmdletBinding()]
    
    Param
    (
        # Param1 computerNames
        [Parameter(Mandatory=$false,
                    ValueFromPipeline=$true,
                    ValueFromPipelineByPropertyName=$true)]
        [string[]]$ComputerName = 'LocalHost'  
    )

    Begin
    { 

    }
    Process
    {
         # scriptblock: to run wmi query on remote machines and returns an object

         $SB = {Try{$os = Get-WmiObject win32_OperatingSystem -property LastBootUpTime, LocalDateTime, status -EA stop;
                    $status = $os.status; 
                    $lastboot = $os.ConvertToDateTime($os.LastBootUpTime);
                    $now = $os.ConvertToDateTime($os.LocalDateTime);
                    $TDays = "{0:N1}" -f ($now - $lastboot).TotalDays;
                    If($Tdays -as [int] -gt 30){$MNP = $true}else{$MNP = $false};
                         $prop = [ordered]@{'StartTime' = $lastboot;'UpTime(Days)' = $TDays;
                            'Status' = $status;'MightNeedPatched' = $MNP}
                }catch{Write-Warning "$env:COMPUTERNAME : $_"; 
                         $prop = [ordered]@{'StartTime' = "                  ";'UpTime(Days)' = "         ";
                             'Status' = "Error";'MightNeedPatched' = "Unknown"}};
                                New-Object psobject -Property $prop}


        foreach($computer in $ComputerName){
                   
             if (test-ping $computer){        
                      Try{ 
                      $ErrorActionPreference = 'stop'
                          invoke-command -computername $computer -ScriptBlock $SB |
                                format-table @{N = 'Computername'; E = 'PSComputerName'}, StartTime, 'UpTime(Days)', status, MightNeedPatched
                 }catch{
                        Write-Warning "$_";            
                           Make-object -ComputerName $computer -status "Error"
                        }
                    }
       
              else{Make-object -ComputerName $computer -status "Offline"}   
             
        } 
         
    }
   
    End
    {
         
    }
}