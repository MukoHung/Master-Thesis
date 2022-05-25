
## This script was quickly hacked together in my free time. It's funcional but something like this should just be a c# application instead of a powershell script. 
# Tested only on Windows 10 64bit. Most likely will not work on older versions of windows due to Powershell 4.0 specific commands. 
# Dylan Langston 2019

#Gets/Sets the default parameters. 
Param (
    [System.IO.DirectoryInfo]$Path = "$env:USERPROFILE\Pictures\Screenshots",
    [string]$BorderColor = "Red",
    [string]$File = "Screenshot_$(get-date -Format 'dd-MM-yyyy_hhmmss')",
    [string]$paint = "true"
)
[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")

New-Item -ItemType Directory -Force -Path $Path |  Out-Null

#Thanks, https://devblogs.microsoft.com/scripting/beginning-use-of-powershell-runspaces-part-2/
$ParamList = @{
    Folder = $Path
    BorderColor = $BorderColor
    Name = $File
}

#Thanks, https://learn-powershell.net/2015/11/30/create-a-mouse-cursor-tracker-using-powershell-and-wpf/
$Runspacehash = [hashtable]::Synchronized(@{})
$Runspacehash.host = $Host
$Runspacehash.runspace = [RunspaceFactory]::CreateRunspace()
$Runspacehash.runspace.ApartmentState = “STA”
$Runspacehash.runspace.ThreadOptions = “ReuseThread”
$Runspacehash.runspace.Open() 
$Runspacehash.psCmd = {Add-Type -AssemblyName WindowsBase,PresentationCore,PresentationFramework,WindowsBase,System.Windows.Forms,System.Drawing,System}.GetPowerShell() 
$Runspacehash.runspace.SessionStateProxy.SetVariable("Runspacehash",$Runspacehash)
$Runspacehash.psCmd.Runspace = $Runspacehash.runspace 
$Runspacehash.Handle = $Runspacehash.psCmd.AddScript({ 
Param ($Folder, $BorderColor, $Name)
$global:isopen = $False

# Thanks, https://devblogs.microsoft.com/powershell/image-manipulation-in-powershell/
function Add-CropFilter {    
    <#
        .Synopsis
            Adds a Crop Filter to a list of filters, or creates a new filter
        .Description
            Adds a Crop Filter to a list of filters, or creates a new filter
        .Example
            $image = Get-Image .\Try.jpg            
            $image = $image | Set-ImageFilter -filter (Add-CropFilter -Image $image -Left .1 -Right .1 -Top .1 -Bottom .1 -passThru) -passThru                    
            $image.SaveFile("$pwd\Try2.jpg")
        .Parameter image
            Optional.  If set, allows you to specify the crop in terms of a percentage
        .Parameter left
            The number of pixels to crop from the left (if left is greater than 1) or the percentage of space to crop from the left (if image is provided)
        .Parameter top
            The number of pixels to crop from the top (if top is greater than 1) or the percentage of space to crop from the top (if image is provided)
        .Parameter right
            The number of pixels to crop from the right (if right is greater than 1) or the percentage of space to crop from the right (if image is provided)
        .Parameter bottom
            The number of pixels to crop from the bottom (if bottom is greater than 1) or the percentage of space to crop from the bottom (if image is provided)
        .Parameter passthru
            If set, the filter will be returned through the pipeline.  This should be set unless the filter is saved to a variable.
        .Parameter filter
            The filter chain that the rotate filter will be added to.  If no chain exists, then the filter will be created
    #>
    param(
    [Parameter(ValueFromPipeline=$true)]
    [__ComObject]
    $filter,
    
    [__ComObject]
    $image,
        
    [Double]$left,
    [Double]$top,
    [Double]$right,
    [Double]$bottom,
    
    [switch]$passThru                      
    )
    
    process {
        if (-not $filter) {
            $filter = New-Object -ComObject Wia.ImageProcess
        } 
        $index = $filter.Filters.Count + 1
        if (-not $filter.Apply) { return }
        $crop = $filter.FilterInfos.Item("Crop").FilterId                    
        $isPercent = $true
        if ($left -gt 1) { $isPercent = $false }
        if ($top -gt 1) { $isPercent = $false } 
        if ($right -gt 1) { $isPercent = $false } 
        if ($bottom -gt 1) { $isPercent = $false }
        $filter.Filters.Add($crop)
        if ($isPercent -and $image) {
            $filter.Filters.Item($index).Properties.Item("Left") = $image.Width * $left
            $filter.Filters.Item($index).Properties.Item("Top") = $image.Height * $top
            $filter.Filters.Item($index).Properties.Item("Right") = $image.Width * $right
            $filter.Filters.Item($index).Properties.Item("Bottom") = $image.Height * $bottom
        } else {
            $filter.Filters.Item($index).Properties.Item("Left") = $left
            $filter.Filters.Item($index).Properties.Item("Top") = $top
            $filter.Filters.Item($index).Properties.Item("Right") = $right
            $filter.Filters.Item($index).Properties.Item("Bottom") = $bottom                    
        }
        if ($passthru) { return $filter }         
    }
}
#requires -version 2.0
function Set-ImageFilter {
    <#
        .Synopsis
            Applies an image filter to one or more images
        .Description
            Applies an Windows Image Acquisition filter to one or more Windows Image Acquisition images
        .Example
            $image = Get-Image .\Try.jpg            
            $image = $image | Set-ImageFilter -filter (Add-RotateFlipFilter -flipHorizontal -passThru) -passThru                    
            $image.SaveFile("$pwd\Try2.jpg")
        .Parameter image
            The image or images the filter will be applied to
        .Parameter passThru
            If set, the image or images will be emitted onto the pipeline       
        .Parameter filter
            One or more Windows Image Acquisition filters to apply to the image
    #>
    param(
    [Parameter(ValueFromPipeline=$true)]
    $image,
    
    [__ComObject[]]
    $filter,
    
    [switch]
    $passThru
    )
    
    process {
        if (-not $image.LoadFile) { return }
        $i = $image
        foreach ($f in $filter) {
            $i = $f.Apply($i.PSObject.BaseObject)
        }       
        if ($passThru) { 
            $i
        }
    }
}

$File = "$Folder\" + "$Name"

Add-Type –assemblyName WindowsBase

[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") 
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")  

[void] [System.Reflection.Assembly]::LoadWithPartialName("System.IO.MemoryMappedFiles")
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.IO.MemoryMappedFiles.MemoryMappedFile")
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.IO.MemoryMappedFiles.MemoryMappedViewStream")

$Screen = [System.Windows.Forms.SystemInformation]::VirtualScreen
$bitmap = new-object System.Drawing.Bitmap $Screen.Width, $Screen.Height
$graphic = [System.Drawing.Graphics]::FromImage($bitmap)
$graphic.CopyFromScreen(0, 0, 0, 0, $bitmap.Size)

$tmp = New-TemporaryFile

$bitmap.Save($tmp.FullName)
$bitmap.close()
    #Thanks, https://blogs.technet.microsoft.com/stephap/2012/04/23/building-forms-with-powershell-part-1-the-form/
    #Build the GUI
    [xml]$xaml = @"
    <Window 
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        x:Name="Window" WindowStartupLocation = "0"
        Width = "80" Height = "200" ShowInTaskbar = "true" ResizeMode = "NoResize"
        Topmost = "True" WindowStyle = "None" AllowsTransparency="false" Background="White" >  
            <Border BorderBrush="Black" BorderThickness="1" HorizontalAlignment="Stretch" VerticalAlignment="Stretch" Name="Border" Width = "80" Height = "200" Margin="0" Opacity="0" >
                <Grid ShowGridLines='False'>
                    <Grid.ColumnDefinitions>
                        <ColumnDefinition Width="*"/>
                        <ColumnDefinition Width="*"/>
                    </Grid.ColumnDefinitions>
                    <Grid.RowDefinitions>
                        <RowDefinition Height = '*'/>
                    </Grid.RowDefinitions>
                    <Label x:Name='X_data_lbl' Grid.Column = '0' Grid.Row = '1' FontWeight = 'Bold'
                    HorizontalContentAlignment="Center" />
                    <Label x:Name='Y_data_lbl' Grid.Column = '1' Grid.Row = '1' FontWeight = 'Bold'
                    HorizontalContentAlignment="Center" />    
                </Grid>
            </Border>
    </Window>
"@
 
    $reader=(New-Object System.Xml.XmlNodeReader $xaml)
    $Window=[Windows.Markup.XamlReader]::Load( $reader )

    #region Connect to Controls
    $xaml.SelectNodes("//*[@*[contains(translate(name(.),'n','N'),'Name')]]") | ForEach {
        New-Variable -Name $_.Name -Value $Window.FindName($_.Name) -Force -ErrorAction SilentlyContinue -Scope Global
    }
    #endregion Connect to Controls

        $global:downx = 0
        $global:downy = 0
    #Events
    $Window.Add_SourceInitialized({
        #Set Background
        $imagesource = new-object System.Windows.Media.Imaging.BitmapImage $tmp.FullName
        $imagebrush = new-object System.Windows.Media.ImageBrush  $imagesource
        $imagebrush.Stretch = "none"
        $Window.width = $Screen.Width
        $Border.width = $Screen.Width
        $Window.height = $Screen.height
        $Border.height = $Screen.height
        $Window.left = "0"
        $Window.Top = "0"
        $Window.Cursor = "Cross"
        $window.Background = $imagebrush
        $Border.background = $BorderColor
        #Create Timer object
        Write-Verbose "Creating timer object"
        $Script:timer = new-object System.Windows.Threading.DispatcherTimer 
        #Fire off every 1 minutes
        Write-Verbose "Adding 1 minute interval to timer object"
        $timer.Interval = [TimeSpan]"0:0:0.001"
        #Add event per tick
        Write-Verbose "Adding Tick Event to timer object"
        $timer.Add_Tick({
            if ($global:isopen) {
                Remove-Item "$File.png" -Force
                if ( -NOT $(Test-Path "$File.png")) {
                    $global:isopen = $False
                }
            }

            $Mouse = [System.Windows.Forms.Cursor]::Position
            $x = $Mouse.x
            $y = $Mouse.y
            $bottom = $border.BorderThickness.bottom

            
            if (($x -LT $downx) -and ($y -LT $downy )) {
                $newright = $Window.Width - $downx
                $newbottom = $Window.Height - $downy
                $Border.BorderThickness = "$x,$y,$newright,$newbottom"
            }

            if (($x -LT $downx) -and ($y -GE $downy )) {
                $newright = $Window.Width - $downx
                $newbottom = $Window.Height - $y
                $Border.BorderThickness = "$x,$downy,$newright,$newbottom"
            }

            if (($x -GE $downx) -and ($y -LT $downy )) {
                $newright = $Window.Width - $x
                $newbottom = $Window.Height - $downy
                $Border.BorderThickness = "$downX,$y,$newright,$newbottom"
            }

            if (($x -GE $downx) -and ($y -GE $downy )) {
                $newright = $Window.Width - $x
                $newbottom = $Window.Height - $y
                $Border.BorderThickness = "$downx,$downy,$newright,$newbottom"
            }
            
            #$X_data_lbl.Content = $Window.Width - ($border.BorderThickness.left + $border.BorderThickness.right)

            #$Y_data_lbl.Content = $Window.Height - ($border.BorderThickness.top + $border.BorderThickness.bottom)
        })
        #Start timer
        Write-Verbose "Starting Timer"
        $timer.Start()
        If (-NOT $timer.IsEnabled) {
            $Window.Close()
        }
    }) 
    $Window.Add_Closed({
        $Script:Timer.Stop()    
        [gc]::Collect()
        [gc]::WaitForPendingFinalizers()    
        #$oReturn=[System.Windows.Forms.Messagebox]::Show($tmp.FullName)
        Remove-Item $tmp.FullName -Force
    })
    $Window.Add_MouseRightButtonUp({
        $Window.background = "Black"
        $Window.Height = 0
        $This.close()
    })
    $Window.Add_MouseLeftButtonDown({
        if ( -NOT $(Test-Path "$File.png")) {
            $Border.Opacity = "0.5"
            $Mouse = [System.Windows.Forms.Cursor]::Position
            $global:downx = $Mouse.x
            $global:downy = $Mouse.y
            $newright = $Screen.Width - $downx
            $newbottom= $Screen.height - $downy
            $Border.BorderThickness = "$downx,$downy,$newright,$newbottom"
        }
    })
    $Window.Add_MouseLeftButtonUp({
        $Window.Cursor = "Arrow"
        $Border.Opacity = "0"
        $image = New-Object -ComObject Wia.ImageFile
        $image.LoadFile($tmp.FullName)          
        $image = $image | Set-ImageFilter -filter (Add-CropFilter -Image $image -Left $border.BorderThickness.left -Right $border.BorderThickness.right -Top $border.BorderThickness.top -Bottom $border.BorderThickness.bottom -passThru) -passThru                    
        if ( -NOT $(Test-Path "$File.png")) {
            $image.SaveFile("$File.png")
            $imagesource = new-object System.Windows.Media.Imaging.BitmapImage "$File.png"
            $imagebrush = new-object System.Windows.Media.ImageBrush  $imagesource
            $imagebrush.Stretch = "none"
            $imagebrush.AlignmentX = "Left"
            $Window.background = $imagebrush
        }
    })
    $Window.Add_MouseWheel({
        $imagesource = new-object System.Windows.Media.Imaging.BitmapImage $tmp.FullName
        $imagebrush = new-object System.Windows.Media.ImageBrush  $imagesource
        $imagebrush.Stretch = "none"
        $Window.background = $imagebrush
        $Window.Cursor = "Cross"
        $global:isopen = $True
        Remove-Item "$File.png" -Force
    })

    $Window.Add_KeyDown({
        
        $oReturn=[System.Windows.Forms.Messagebox]::Show( "$File.png")
    })

    [void]$Window.ShowDialog() 
}).AddParameters($ParamList)
$Runspacehash.psCmd.Invoke()
$Runspacehash.psCmd.Dispose()

# check that file exist, if it does check that openScreenshots = true in the config.js file, and if both are true clear clipboard and open image in MSPAINT
if (Test-Path "$path\$file.png") {
if ($paint -eq "true") {
	Add-Type -AssemblyName System.Windows.Forms
	[System.Windows.Forms.Clipboard]::Clear()
	start C:\Windows\System32\mspaint.exe "$path\$file.png"
}
}