#requires -version 6.1

Function Send-ToPSGridView {

<#
.SYNOPSIS
Send objects to Out-Gridview in Windows PowerShell
.DESCRIPTION
This command is intended as a workaround for PowerShell Core running on a Windows platform, presumably Windows 10. PowerShell Core does not support all of the .NET Framework which means some commands like Out-Gridview are not supported. However, on a Windows desktop you are most likely running Windows PowerShell side by side with PowerShell Core. This command is designed to take objects from a PowerShell expression and send it to an instance of Windows PowerShell running Out-Gridview. You can specify a title and pass objects back to your PowerShell Core session. Note that passed objects will be deserialized versions of the original objects.
.PARAMETER Title
Specify a Title for the Out-Gridview window
.PARAMETER Passthru
Pass selected objects from Out-Gridview back to your PowerShell Core session.
.EXAMPLE
PS C:\> get-childitem c:\scripts\*.ps1 | Send-ToPSGridview -title "My Scripts"
Press Enter to continue...:

Display all ps1 files in Out-Gridview. You must press Enter to continue.
.EXAMPLE
PS C:\>  get-service | where status -eq 'running' | Send-ToPSGridView -Passthru | Restart-service -PassThru
Press Enter to continue...:

Status   Name               DisplayName
------   ----               -----------
Running  BluetoothUserSe... Bluetooth User Support Service_17b710
Running  Audiosrv           Windows Audio

Get all running services and pipe to Out-Gridview where you can select services which will be restarted.
.EXAMPLE
PS C:\> $val = 1..10 | Send-ToPSGridView -Title "Select some numbers" -Passthru
Press Enter to continue...:
PS C:\> $val
4
8
6
PS C:\> $val | Measure-Object -sum

Count             : 3
Average           :
Sum               : 18
Maximum           :
Minimum           :
StandardDeviation :
Property          :

Send the numbers 1 to 10 to Out-Gridview where you can select a few. The results are saved to a variable in the PowerShell Core session where you can use them.
.INPUTS
System.Object
.OUTPUTS
None, Deserialized.System.Object[]
.NOTES
Learn more about PowerShell: http://jdhitsolutions.com/blog/essential-powershell-resources/
#>

    [cmdletbinding()]
    [alias("ogv")]
    [OutputType("None", "Deserialized.System.Object[]")]

    Param(
        [Parameter(Position = 0, ValueFromPipeline, Mandatory)]
        [ValidateNotNullOrEmpty()]
        [object[]]$InputObject,
        [ValidateNotNullOrEmpty()]
        [string]$Title = "Out-GridView",
        [switch]$Passthru
    )
    Begin {
        Write-Verbose "[$((Get-Date).TimeofDay) BEGIN  ] Starting $($myinvocation.mycommand)"
        #validate running on a Windows platform`
        if ($PSVersionTable.Platform -ne 'Win32NT') {
            Throw "This command requires a Windows platform with a graphical operating system like Windows 10."
        }
        #initialize an array to hold pipelined objects
        $data = @()

        #save foreground color
        $fg = $host.ui.RawUI.ForegroundColor

    } #begin

    Process {
        Write-Verbose "[$((Get-Date).TimeofDay) PROCESS] Adding object"
        $data += $InputObject
    } #process

    End {
        Write-Verbose "[$((Get-Date).TimeofDay) END    ] Creating a temporary xml file with the data"
        $tempFile = Join-Path -path $env:temp -ChildPath ogvTemp.xml
        $data | Export-Clixml -Path $tempFile

        Write-Verbose "[$((Get-Date).TimeofDay) END    ] Starting up a PowerShell.exe instance"
        PowerShell.exe -nologo -noprofile -command {
            param([string]$Path, [string]$Title = "Out-Gridview", [bool]$Passthru)
            Import-Clixml -Path $path | Out-Gridview -title $Title -passthru:$Passthru
            #a pause is required because if you don't use -Passthru the command will automatically complete and close
            $host.ui.RawUI.ForegroundColor = "yellow"
            Pause
        } -args $tempFile, $Title, ($passthru -as [bool])

        if (Test-Path -Path $tempFile) {
            Write-Verbose "[$((Get-Date).TimeofDay) END    ] Removing $tempFile"
            Remove-Item -Path $tempFile
        }

        #restore foreground color
        $host.ui.RawUI.ForegroundColor = $fg
        Write-Verbose "[$((Get-Date).TimeofDay) END    ] Ending $($myinvocation.mycommand)"
    } #end

} #close Send-ToPSGridView

