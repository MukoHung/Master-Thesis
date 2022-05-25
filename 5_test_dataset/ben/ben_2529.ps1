#requires -version 5.0
#requires -module nettcpip,cimcmdlets

<#
This script will generate a WPF form to display network adapter
information. It will automatically refresh every 30 seconds.
You can change the interval then click the Update button.
I don't recommend refreshing any faster than 10 seconds. It can take almost
5 seconds to get all the network adapter information.

Run with default interval of 30 seconds
PS C:\> <path>\netadaptermonitor.ps1

Or specify a value between 10 and 60 in 5 second intervals
PS C:\> <path>\netadaptermonitor.ps1 15

The performance data is not a cumulative result but rather the most
recent values from performance counters.

If you close your PowerShell session the form will also close.

The current version includes a -Interactive parameter which will display 
a number of trace messages along with the form. This is intended to be used
for debugging and troubleshooting so that any error messages can also 
be displayed.

This script is **far** from complete as a polished tool.
It is offered as-is with no guarantees and should be considered
a work in progress.

Updated 21 April 2018
    removed InterfaceIndex from output
    Added error handling for public IP
    Added test for adapters before displaying the form
    Moved the "Last Updated" to a status bar
    Moved buttons to a grid for better layout
    Moved Public IP code to a function which can be called during each refresh
    Added an -Interactive parameter to the script to display trace messages
    Fixed display bug when there is only a single network adapter

Updated 20 April 2018
    Added user defined refresh interval as a parameter
    Added option to manually refresh
    Fixed performance counter bug for wireless adapters
    Moved public IP address to title bar

#>

[cmdletbinding()]
Param(
    [Parameter(Position = 0, HelpMessage = "The number of seconds between refresh intervals")]
    [ValidateScript( {$_ -ge 10 -AND $_ -le 60 -AND (-not ($_ % 5 -as [bool])) })]
    [int32]$RefreshInterval = 30,
    [Parameter(HelpMessage = "Run the form interactively instead of the background. This makes it easier to see errors.")]
    [switch]$Interactive
)

#verify there are detected adapters before trying to run the form
Try {
    $test = Get-Netadapter -Physical -ErrorAction Stop | Measure-Object
    if ($test.count -lt 1) {
        Throw "No adapters found"
    }
}
Catch {
    Write-Warning "There was a problem detecting adapters. Aborting."
    Throw $_
}


Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase

#define the scriptblock to execute in the runspace
$sb = {
    Param(
        [Parameter(Position = 0, HelpMessage = "The number of seconds between refresh intervals")]
        [ValidateScript( { ($_ -ge 10) -AND ($_ -le 60) -AND (-not ($_ % 5 -as [bool])) })]
        [int32]$RefreshInterval = 30
    )

    Function GetNetData {
        [cmdletbinding()]
        Param()

        Write-Host "$(Get-Date) [NETDATA] Getting adapter details"
        #filter out loopback and non-assigned addresses
        $addresses = (Get-netipaddress -AddressFamily IPv4).where( { $_.IPv4Address -notmatch "^(127)|(169)"})

        Foreach ($item in $addresses) {
            $adapter = Get-NetAdapter -InterfaceIndex $item.InterfaceIndex
            $config = Get-CimInstance -ClassName Win32_NetworkAdapterConfiguration -filter "description='$($adapter.InterfaceDescription)'"
    
            #fix description for counter
            $a = $adapter.interfacedescription.replace('#', '_').replace('(', '[').replace(')', ']')
            #performance counters to get
            $counters = "\Network Adapter($a)\Bytes Total/sec", "\Network Adapter($a)\Bytes Sent/sec",
            "\Network Adapter($a)\Bytes Received/sec"
            $perf = Get-Counter -counter $counters 
    
            #create a custom object for each address/interface
            [PSCustomObject]@{
                Interface     = $Adapter.InterfaceAlias
                Description   = $adapter.InterfaceDescription
                #Index         = $adapter.InterfaceIndex
                IPAddress     = $item.IPAddress
                Subnet        = $config.IPsubnet[0]
                Gateway       = ($config.DefaultIPGateway -join ",")
                Speed         = $adapter.LinkSpeed
                MAC           = $adapter.macaddress
                BytesTotalSec = $perf.CounterSamples[0].cookedvalue
                BytesSentSec  = $perf.CounterSamples[1].cookedvalue
                BytesRcvdSec  = $perf.CounterSamples[2].cookedvalue
            }
        } 

    } #close GetNetData function

    Function GetPublicIP {
        write-Host "$(Get-Date) [PUBLICIP] Getting public IP address" -ForegroundColor cyan
        Try {
            $request = Invoke-WebRequest http://icanhazip.com/ -DisableKeepAlive -UseBasicParsing -ErrorAction Stop
            $myIP = $request.content.trim()
        }
        Catch {
            $myIP = "Unknown"
        }
        $myIP
    } #close GetPublicIP

    Function UpdateData {
        Write-Host "$(Get-Date) [UPDATE] Updating" -foreground green
        $timer.Stop()
        $timer.IsEnabled = $False
        $form.Title = "Network Adapter Report: $($env:Computername)  Public IP: $(GetPublicIP)"

        <#
        #this code is not working yet to clear the datatable on manual update
        #probably need to be using some sort of data binding on the datagrid
        $datagrid.ItemsSource = [System.Collections.IEnumerable]@()
        $datagrid.items.Refresh()
        $datagrid.Clear()
        $form.InvalidateVisual()
        $form.UpdateLayout()
        #>
        Write-Host "$(Get-Date) [UPDATE] Getting data" -foreground green

        [System.Collections.IEnumerable]$results = @(GetNetData)
        $datagrid.ItemsSource = $results
        $status.text = "Last Update: $(Get-Date)"

        $timer.Interval = New-Timespan -Seconds ($refresh.SelectedValue -as [int32])
        write-host "$(Get-Date) [UPDATE] Next update in $($timer.Interval)" -ForegroundColor green
        $timer.IsEnabled = $True
        $timer.start()
    }

    $form = New-Object System.Windows.Window
    #define what it looks like
    $form.Height = 275
    $form.Width = 1150
    $form.WindowStartupLocation = "CenterScreen"

    $stack = New-object System.Windows.Controls.StackPanel
    $stack.CanVerticallyScroll = $True

    $stack.Width = $form.Width - 50
    $stack.Height = $form.Height - 50

    $label2 = New-Object System.Windows.Controls.Label
    $label2.HorizontalAlignment = "Left"
    $label2.Content = "Network Adapter Summary"
    $stack.AddChild($label2)
       
    $datagrid = New-Object System.Windows.Controls.datagrid
    $datagrid.HorizontalAlignment = "left"
    $datagrid.VerticalScrollBarVisibility = "Auto"
    $datagrid.Width = $form.width - 10
    $datagrid.CanUserSortColumns = $True
    $datagrid.CanUserResizeColumns = $True
    $datagrid.IsReadOnly = $True
    
    $datagrid.AutoGenerateColumns = $True

    $stack.AddChild($datagrid)

    #navigation button grid
    $grid = new-object System.Windows.Controls.Grid
    $grid.Width = $form.Width - 50
    $grid.Height = 45

    $refresh = New-Object System.Windows.Controls.ComboBox
    $refresh.Width = 50
    $refresh.Height = 25
    $refresh.HorizontalAlignment = "left"
    $refresh.allowDrop = $True

    for ($i = 10; $i -le 60; $i += 5) {
        $refresh.items.add($i) | out-null
    } 

    $refresh.SelectedValue = $RefreshInterval
    $refresh.ToolTip = "Refresh interval in seconds"
    $grid.addchild($refresh)

    $Update = new-object System.Windows.Controls.Button
    $Update.Content = "_Update"
    $Update.Width = 60
    $Update.Height = 25
    $Update.HorizontalAlignment = "left"
    $update.Margin = "60,0,0,0"
    $Update.add_click( {
            UpdateData
        })

    $grid.AddChild($Update)

    $Quit = new-object System.Windows.Controls.Button
    $quit.Content = "_Quit"
    $Quit.Width = 60
    $quit.Height = 25
    $quit.HorizontalAlignment = "left"
    $quit.Margin = "130,0,0,0"
    $quit.add_click( {
            Write-Host "$(Get-Date) [QUIT] Closing the form" -ForegroundColor Magenta
            $form.close()
        })

    $grid.AddChild($quit)
       
    #$grid.Background = "lightgray"

    $stack.addchild($grid)

    $border = new-object System.Windows.Controls.Border
    $border.BorderThickness = "0,1,0,0"
    $border.BorderBrush = "black"

    $status = new-object System.Windows.Controls.TextBlock
    $status.VerticalAlignment = "bottom"
    $status.Text = "Ready"
    #$status.Background = "lightgray"

    $border.AddChild($status)
    $stack.AddChild($border)
    $form.AddChild($stack)

    $timer = New-Object System.Windows.Threading.DispatcherTimer
    $timer.Interval = New-Timespan -Seconds ($refresh.SelectedValue -as [int32])
    $timer.IsEnabled = $False
    $timer.add_tick( {
            write-host "$(Get-Date) [TICK] Refresh data"
            UpdateData
            write-host "$(Get-Date) [TICK] Next update in $($timer.Interval)"
        })
       
    #get initial data into the form
    UpdateData
    $form.Add_Loaded( {
            write-host "$(Get-Date) [LOAD] Displaying form"
            $form.Activate()
        })

    $form.ShowDialog() | Out-Null

} #close $sb

If ($Interactive) {
    Invoke-command -ScriptBlock $sb -ArgumentList $RefreshInterval
} else {
    $run = [runspacefactory]::CreateRunspace()
    $run.ApartmentState = "STA"
    $run.ThreadOptions = "ReUseThread"
    $run.Open()

    $psCmd = [PowerShell]::Create().AddScript($sb)
    $psCmd.AddParameter("RefreshInterval", $RefreshInterval) | Out-Null
    $psCmd.runspace = $run
    $pscmd.beginInvoke() | Out-Null
}

