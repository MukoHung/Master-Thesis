
#This basically creates a command whereby we have 2 parameters 1. Computers and 2. the amount of simultaneous computers being tested, default is 10.
workflow Test-Parallel {
    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$computers,
        [Parameter(Mandatory = $false)]
        [int]$GroupSize = 10
    )
    $computerGroups = InlineScript {
        $numberofGroups = [math]::Ceiling($using:Computers.Count / $using:groupSize)
        1..$numberofGroups | ForEach-Object{
            ,($using:computers | Select -Index ((($_ - 1) * $using:GroupSize)..($_ * $using:GroupSize - 1)))
        }
    }
    ForEach -parallel ($computerGroup in $computerGroups) {
        $computerGroup | ForEach-Object{
            $pingable = (Test-Connection $_ -Count 1 -Quiet -ErrorAction SilentlyContinue) -or 
                        (Test-Connection $_ -Count 1 -Quiet -ErrorAction SilentlyContinue)
            if ($pingable -eq $true)
            {
                $ping = (Test-Connection $_ -Count 1 -ErrorAction SilentlyContinue | select *)
                $IP = ($ping | select -ExpandProperty ipv4address | select -ExpandProperty ipaddresstostring)
                $time = ($ping | select -ExpandProperty responsetime)
                $Invoke = [boolean](Invoke-Command $_ {gwmi -class win32_computersystem} -ErrorAction SilentlyContinue)
            }
            else
            {
                $pingable = $false
                $IP = $false
                $time = $false
                $Invoke = $false
            }
            [pscustomobject]@{Name=$_;Online=$pingable;IP=$IP;ResponseTime=$time;InvokePossible=$Invoke}
        }
    }
} 