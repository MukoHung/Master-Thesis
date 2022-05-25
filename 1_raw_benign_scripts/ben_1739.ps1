<#

2016-January Scripting Games Puzzle

#>

Function Get-Uptime
    {
    [Alias('gut')]
    [CmdletBinding()]

    Param
        (
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias('c','Comp','Host','Hostname')]
        [String[]] $ComputerName = $env:COMPUTERNAME
        )

    Process
        {
        foreach ($Computer in $ComputerName)
            {
            $Hashtable = [ordered]@{
                ComputerName       = ''
                StartTime          = ''
                'Uptime (Days)'    = ''
                Status             = ''
                MightNeedPatched   = ''
                } 
                
            try
                {
                Write-Verbose -Message "Testing connection to $Computer..."
                if (-not(Test-Connection -ComputerName $Computer -Count 1 -Quiet))
                    {
                    Write-Warning -Message "Failed connection to $Computer" -ErrorAction Continue                    
                    #Build hash properties
                    $Hashtable.ComputerName       = $Computer
                    $Hashtable.Status             = 'OFFLINE'
                    }
                else
                    {
                    <#
                    query for operating system object using wmi
                    convert string properties to datetime and calculate the difference
                    from the last boot time and the current local time (time of query)#>
                    Write-Verbose -Message "Successful connection made to $Computer`n`nGathering info..."
                    $Win32_OperatingSystem = Get-WmiObject -ComputerName $Computer -Class Win32_OperatingSystem
                    $LocalDateTime = $Win32_OperatingSystem.ConvertToDateTime($Win32_OperatingSystem.LocalDateTime)
                    $LastBootUpTime = $Win32_OperatingSystem.ConvertToDateTime($Win32_OperatingSystem.LastBootUpTime)
                    $Uptime = $LocalDateTime - $LastBootUpTime
                    
                    #Build hash properties
                    $Hashtable.ComputerName       = $Computer
                    $Hashtable.StartTime          = $LastBootUpTime | Get-Date -Format g
                    $Hashtable.'Uptime (Days)'    = [Math]::Round($Uptime.TotalDays, 1)
                    $Hashtable.Status             = 'OK'
                    
                    $AvgDaysPerMonth = ((7*31)+(4*30)+28.25)/12
                    if(($Hashtable.'Uptime (Days)' + ($AvgDaysPerMonth * 0.1)) -gt 30)
                        {
                        $Hashtable.MightNeedPatched = $true
                        }
                    else
                        {
                        $Hashtable.MightNeedPatched = $false
                        }
                    }
                #out object
                [pscustomobject]$Hashtable
                }
            catch [exception]
                {
                $_.exception.message
                }
            }
        }


    <#
    .Synopsis
       
       Returns the uptime (measured in days) of one or more remote computers.
    
    .DESCRIPTION
       
       The Get-Uptime function uses Windows Management Instrumentation (WMI) to retrieve
       the last boot time, calculate against the current local time and return the total
       uptime measured in days.

       Get-Uptime will accept pipeline input.

    .PARAMETER 
    
    ComputerName

        Single computer name or an array of computer names are accepted.

    .EXAMPLE
    
        PS C:\WINDOWS\system32> Get-Uptime | ft -AutoSize

        ComputerName StartTime         Uptime (Days) Status MightNeedPatched
        ------------ ---------         ------------- ------ ----------------
        WATZASCHAUER 1/23/2016 5:00 AM           5.8 OK                False

    .EXAMPLE

        PS C:\WINDOWS\system32> 'Server01', 'DC1' | Get-Uptime
        WARNING: Failed connection to Server01


        ComputerName     : Server01
        StartTime        : 
        Uptime (Days)    : 
        Status           : OFFLINE
        MightNeedPatched : 

        WARNING: Failed connection to DC1
        ComputerName     : DC1
        StartTime        : 
        Uptime (Days)    : 
        Status           : OFFLINE
        MightNeedPatched : 

    .EXAMPLE    

        PS C:\WINDOWS\system32> Get-Uptime -Verbose
        VERBOSE: Testing connection to Server01...
        VERBOSE: Successful connection made to Server01

        Gathering info...


        ComputerName     : Server01
        StartTime        : 1/23/2016 5:00 AM
        Uptime (Days)    : 5.8
        Status           : OK
        MightNeedPatched : False

    #>


}#end