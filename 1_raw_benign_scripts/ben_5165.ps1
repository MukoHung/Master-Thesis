
c:\users\rocky\desktop\powershell books examples\windows powershell in action, second edition\finalcode\AdditionalExamples\Addition XAMl examples\Invoke-Xaml.ps1
************************************************************************
param($path, [switch] $show)

set-strictmode -version 2

Add-Type -Assembly PresentationCore,PresentationFrameWork

trap { break }

$mode = [System.Threading.Thread]::CurrentThread.ApartmentState
if ($mode -ne "STA")
{
    throw "This script can only be run when powershell is started with -sta"
}

function Add-ScriptRoot ($file)
{
  $caller = Get-Variable -Value -Scope 1 MyInvocation
  $caller.MyCommand.Definition |
    Split-Path -Parent |
      Join-Path -Resolve -ChildPath $file
}

if (0)
{
      $xrdr =  [System.xml.xmlreader]::Create([System.IO.StringReader] $ui)
      $form = [System.Windows.Markup.XamlReader]::Load($xrdr)
}
else
{
      $stream = [System.IO.StreamReader] (resolve-path $Path).ProviderPath
      $form = [System.Windows.Markup.XamlReader]::Load($stream.BaseStream)
      $stream.Close()
}

if ($show)
{
    $form.ShowDialog()
}
else
{
    $form
}




c:\users\rocky\desktop\powershell books examples\windows powershell in action, second edition\finalcode\AdditionalExamples\Addition XAMl examples\searchex.ps1
************************************************************************
param ($PathToSearch = $PWD)

Add-Type -Assembly PresentationCore,PresentationFrameWork

trap { break }

$mode = [System.Threading.Thread]::CurrentThread.ApartmentState
if ($mode -ne "STA")
{
  throw "This script can only be run when powershell is started with -sta"
}

function Add-ScriptRoot ($file)
{
  $caller = Get-Variable -Value -Scope 1 MyInvocation
  $caller.MyCommand.Definition |
    Split-Path -Parent |
      Join-Path -Resolve -ChildPath $file
}

$xamlPath = Add-ScriptRoot searchex.xaml
$stream = [System.IO.StreamReader] $xamlPath
$form = [System.Windows.Markup.XamlReader]::Load(
      $stream.BaseStream)
$stream.Close()

$Path = $form.FindName("Path")
$Path.Text = Resolve-Path $PathToSearch

$FileFilter = $form.FindName("FileFilter")
$FileFilter.Text = "*.ps1"
"*.ps1", "*.cs", "*.xaml", "*.xml" |
  foreach { $FileFilter.Items.Add($_) } |
    Out-Null

$TextPattern = $form.FindName("TextPattern")
$Recurse = $form.FindName("Recurse")

$UseRegex = $form.FindName("UseRegex")
$UseRegex.IsChecked = $true

$FirstOnly = $form.FindName("FirstOnly")

$ShowPathOnly = $form.FindName("ShowPathOnly")

$Run = $form.FindName("Run")
$Run.add_Click({
    $form.DialogResult = $true
    $form.Close()
  })
  
$Show = $form.FindName("Show")
$Show.add_Click({Write-Host (Get-CommandString)})

$Cancel = $form.FindName("Cancel")
$Cancel.add_Click({$form.Close()})

function Get-CommandString
{
  $cmd = "Get-ChildItem $($Path.Text) ``
    -Recurse: `$$($Recurse.IsChecked) ``
    -Filter '$($FileFilter.Text)' |
      Select-String -SimpleMatch: `(! `$$($UseRegex.IsChecked)) ``
        -Pattern '$($TextPattern.Text)' ``
        -List: `$$($FirstOnly.IsChecked)"
  if ($ShowPathOnly.IsChecked)
  {
    $cmd += " | foreach { `$_.Path }"
  }
  $cmd

}

if ($form.ShowDialog())
{
  $cmd = Get-CommandString
  Invoke-Expression $cmd
}




c:\users\rocky\desktop\powershell books examples\windows powershell in action, second edition\finalcode\AdditionalExamples\Addition XAMl examples\Show-DocumentExample.ps1
************************************************************************
#
# This script loads a XAML flow document and then adds actions to
# the button contained in that document. A XAML flow document provides
# a lot of default functionality like zooming, changing column styles
# and so on.
#

$doc = ./invoke-xaml .\documentExample.xaml
$button = $doc.FindName("ShowCommands")
$listbox = $doc.FindName("CommandOutput")
$commandCount = $doc.FindName("CommandCount")

$button.add_Click({
    $cmds = Get-Command | Format-Table -Auto | Out-String -Stream
    foreach ($line in $cmds)
    {
        $listbox.Items.Add($line)
    }
    $commandCount.Text = "Found $($cmds.Count) commands."
})

$doc.ShowDialog()





c:\users\rocky\desktop\powershell books examples\windows powershell in action, second edition\finalcode\AdditionalExamples\Addition XAMl examples\Show-Shape.ps1
************************************************************************
#
# Uses Invoke-Xaml to display the shape.xaml file. 
# shape.xaml demonstrates how to use polygons to draw shapes.

./Invoke-Xaml -Show ./shape.xaml



c:\users\rocky\desktop\powershell books examples\windows powershell in action, second edition\finalcode\AdditionalExamples\Addition XAMl examples\Show-Splitter.ps1
************************************************************************
#
# Uses Invoke-Xaml to display the splitter.xaml file. 
# splitter.xaml demonstrates how to use splitters in a XAML IU.

./Invoke-Xaml -Show ./splitter.xaml



c:\users\rocky\desktop\powershell books examples\windows powershell in action, second edition\finalcode\AdditionalExamples\Advanced Language Examples\dynamic_modules_example.ps1
************************************************************************
[Error] - File could not be written...


c:\users\rocky\desktop\powershell books examples\windows powershell in action, second edition\finalcode\AdditionalExamples\Advanced Language Examples\generateFib.ps1
************************************************************************
[Error] - File could not be written...


c:\users\rocky\desktop\powershell books examples\windows powershell in action, second edition\finalcode\AdditionalExamples\Advanced Language Examples\PowerShell Language Quirk Examples.ps1
************************************************************************
[Error] - File could not be written...


c:\users\rocky\desktop\powershell books examples\windows powershell in action, second edition\finalcode\AdditionalExamples\webbrowser\basicWebformExample.ps1
************************************************************************
#
# A simple example of a GUI written using HTML and the web browser control
# available in Windows Forms.
#

# Must be running STA to use the browser control

$mode = [System.Threading.Thread]::CurrentThread.ApartmentState
if ($mode -ne "STA")
{
    throw "This script can only be run when powershell is started with -sta"
}

#
# Uses the Form function from WPIAforms
# module to build the basic frame for the UI
#
Import-Module ./wpiaforms

#
# HTML defining the form
#
$pageText = @'
<html>
<head>
    <title>
        PowerShell Commands
    </title>
</head>
<body bgcolor="lightblue">
    <p>
    <Table style="width: 100%" cellspacing="2" cellpadding="4" border="0">
        <tr>
            <td align="center" colspan="3"> Run PowerShell Commands</td>
        </tr>
        <tr>
            <td>
                <button id="button1">List Processes</button>
            </td>
            <td>
                <button id="button2">List Services</button>
            </td>
            <td>
                <button id="button3">List Files</button>
            </td>
        </tr>
    </Table>
    </p>
    <p>
        <textarea name="OutputArea" Rows=20 style="width: 100%; font-family: consolas">
        </textarea>
    </p>
</body>
</html>
'@

#
# Function to bind event handlers to controls
#
function global:Add-EventHandler
{
    [cmdletbinding()]
    param(
        [parameter(mandatory=$true)]
            $Document,
        [parameter(mandatory=$true)]
            $ControlId,
        [parameter(mandatory=$true)]
            $EventName,
        [parameter(mandatory=$true)]
        [scriptblock]
            $Handler
   )
   
    $control = $Document.Document.GetElementById($ControlId)
    $control.AttachEventHandler($EventName, $handler)
}

#
# Function to load and invoke an HTML form
#
function Invoke-HtmlApplication
{
    param (
        $pageText,
        $initializationScript
    )
 
    # Build the basic form object  
    $global:f = form form @{
	   text = "Browser"
       size = point 800 600
	   controls = {
		  ($global:w = form webbrowser @{
			 Dock = "fill"
             DocumentText = $pageText
          })
       }
    }
    # Load the HTML into the form
    $w.add_DocumentCompleted($initializationScript)
    # Show the form...
    $f.ShowDialog()
}

#
# The actual application: passes the HTML to define the form
# and a scriptblock to bind the event handlers...
#
Invoke-HtmlApplication $pageText {

    Add-EventHandler $w button1 onclick {
        $text = $w.Document.GetElementById("OutputArea")
        $text.InnerText = Get-Process | Format-Table -AutoSize | Out-String
    }
    
    Add-EventHandler $w button2 onclick {
        $text = $w.Document.GetElementById("OutputArea")
        $text.InnerText = Get-Service | Format-Table -AutoSize Status, DisplayName | Out-String
    }
    
    Add-EventHandler $w button3 onclick {
        $text = $w.Document.GetElementById("OutputArea")
        $text.InnerText = dir ~/documents | Format-Table -AutoSize | Out-String
    }
}




c:\users\rocky\desktop\powershell books examples\windows powershell in action, second edition\finalcode\AdditionalExamples\webbrowser\websearch.ps1
************************************************************************
[Error] - File could not be written...


c:\users\rocky\desktop\powershell books examples\windows powershell in action, second edition\finalcode\Appendix B\AD_LDS_examples.ps1
************************************************************************
[Error] - File could not be written...


c:\users\rocky\desktop\powershell books examples\windows powershell in action, second edition\finalcode\Appendix B\association_classes.ps1
************************************************************************
#
# Windows PowerShell in Action, Second Edition
#
# Appendix B - Examples
#
# Using WMI Association classes
#

Get-WmiObject Win32_AssociatedProcessorMemory 
Get-WmiObject Win32_AssociatedProcessorMemory  | gm [a-z]* -type property
$cpu0 = (Get-WmiObject Win32_AssociatedProcessorMemory)[0]
$cpu0
$cpus[0].Antecedent
$cpus[0].Dependent
$ant =[wmi] '\\BRUCEPAYX61\root\cimv2:Win32_Processor.DeviceID="CPU0"'
$ant

$disk = Get-WmiObject Win32_DiskDrive | select -first 1
$disk
$disk.Partitions
$path = $disk.__PATH
$path
Get-WmiObject -query "ASSOCIATORS OF {$($path)} WHERE
 AssocClass = Win32_DiskDriveToDiskPartition"
 
$disk.GetRelated() | foreach { $_.CreationClassName } | sort -Unique
$disk.GetRelated("Win32_DiskPartition") |
  select name, primarypartition,@{n="Size"; e={$_.Size / 1gb }}
  
$disk.GetRelated("Win32_ComputerSystem")



c:\users\rocky\desktop\powershell books examples\windows powershell in action, second edition\finalcode\Appendix B\ComWrappers.ps1xml
************************************************************************
<!--
   PowerShell types extension to make it easier to work
   COM objects when there is no type wrapper.
-->
<Types>
 <Type>
  <Name>System.__ComObject</Name>
   <Members>
    <ScriptMethod>
     <Name>GetProperty</Name> 
     <Script>
       [System.__ComObject].invokeMember($args[0],
          [System.Reflection.BindingFlags]::GetProperty,
          $null, $this, $null)
     </Script>
     </ScriptMethod>
     <ScriptMethod>
     <Name>SetProperty</Name> 
     <Script>
       $name, $propArgs = $args  
       [System.__ComObject].invokeMember($name,
         [System.Reflection.BindingFlags]::GetProperty,
         $null, $this, @($propArgs))
     </Script>
     </ScriptMethod>
     <ScriptMethod>
     <Name>InvokeParamProperty</Name>
     <Script>
       $name, $methodargs=$args
       [System.__ComObject].invokeMember($args[0],
         [System.Reflection.BindingFlags]::GetProperty,
         $null, $this, @($methodargs))
     </Script>
     </ScriptMethod>
     <ScriptMethod>
     <Name>InvokeMethod</Name>
     <Script>
        $name, $methodargs=$args
        [System.__ComObject].invokeMember($name,
          [System.Reflection.BindingFlags]::InvokeMethod,
          $null, $this, @($methodargs))
     </Script>
     </ScriptMethod>
    </Members>
  </Type>
</Types>   
        



c:\users\rocky\desktop\powershell books examples\windows powershell in action, second edition\finalcode\Appendix B\Get-Digg.ps1
************************************************************************
[Error] - File could not be written...


c:\users\rocky\desktop\powershell books examples\windows powershell in action, second edition\finalcode\Appendix B\Get-FilesInMsiPackage.ps1
************************************************************************
#
# Windows PowerShell in Action, Second Edition
#
# Appendix B - Examples
#
# Script to file contents from an MSI package.
#

param($msifile = $(throw "You must specify an MSI file to list"))

# We need to make sure the path is absolute
$msifile = resolve-path $msifile
 
$installer = new-object -com WindowsInstaller.Installer
$database = $installer.InvokeMethod("OpenDatabase",$msifile,0);
$view = $database.InvokeMethod("OpenView","Select FileName FROM File")
$view.InvokeMethod("Execute")
$r = $view.InvokeMethod("Fetch")
$r.InvokeParamProperty("StringData",1)
while($r -ne $null)
{
    $r = $view.InvokeMethod("Fetch")
    if( $r -ne $null)
    {
        $r.InvokeParamProperty("StringData",1)
    }
}



c:\users\rocky\desktop\powershell books examples\windows powershell in action, second edition\finalcode\Appendix B\historygui\removeCdAlias.ps1
************************************************************************
[Error] - File could not be written...


c:\users\rocky\desktop\powershell books examples\windows powershell in action, second edition\finalcode\Appendix B\historygui\snippets.ps1
************************************************************************
[Error] - File could not be written...


c:\users\rocky\desktop\powershell books examples\windows powershell in action, second edition\finalcode\Appendix B\PowerShellCalculator.ps1
************************************************************************
#
# Windows PowerShell in Action
#
# Chapter 11 The PowerShell Graphical Calculator
#
# This script implements a simple WinForm calculator.
#
Import-Module .\wpiaforms.psm1

$script:op = ''
$script:doClear = $false
function clr { $result.text = 0 }
[decimal] $script:value = 0

#
# Event handler scriptblock for calculator digits
#
$handleDigit = {
    if ($doClear)
    {
        $result.text = 0
        $script:doClear = $false
    }

    $key = $this.text
    $current = $result.Text
    if ($current -match '^0$|NaN|Infinity')
    {
        $result.text = $key
    } else {
        if ($key -ne '.' -or $current -notmatch '\.')
        {
            $result.Text += $key
        }
    }
}

#
# Operator button event handler scriptblock
#
$handleOp = {
     $script:value = $result.text
     $script:op = $this.text
     $script:doClear = $true
}

#
# Table defining key/operator bindings
#
$keys = (
    @{name='7'; action=$handleDigit},
    @{name='8'; action=$handleDigit},
    @{name='9'; action=$handleDigit},
    @{name='/'; action = $handleOp},
    @{name='SQRT'; action = {
            trap { $resultl.Text = 0; continue }
            $result.Text = [math]::sqrt([decimal] $result.Text)
        }
    },
    @{name='4'; action=$handleDigit},
    @{name='5'; action=$handleDigit},
    @{name='6'; action=$handleDigit},
    @{name='*'; action = $handleOp},
    @{name='Clr'; action = $function:clr},
    @{name='1'; action=$handleDigit},
    @{name='2'; action=$handleDigit},
    @{name='3'; action=$handleDigit},
    @{name='-'; action = $handleOp},
    @{name='1/x'; action = {
            trap { $resultl.Text = 0; continue }
            $val = [decimal] $result.Text
            if ($val -ne 0)
            {
                $result.Text = 1.0 / $val
            }
        }
    },
    @{name='0'; action=$handleDigit},
    @{name='+/-'; action = {
            trap { $resultl.Text = 0; continue }
            $result.Text = - ([decimal] $result.Text)
        }
    },
    @{name='.'; action=$handleDigit},
    @{name='+'; action = $handleOp},
    @{name='='; action = {
            $key = $this.text
            trap { message "error: $key" "error: $key"; continue }
            $operand = [decimal] $result.text
            $result.text = invoke-expression "`$value $op `$operand"
        }
    },
    @{name='%'; action = $handleOp},
    @{name='sin'; action = {
            trap { $resultl.Text = 0; continue }
            $result.Text = [math]::sin([decimal] $result.Text)
        }
    },
    @{name='cos'; action = {
            trap { $resultl.Text = 0; continue }
            $result.Text = [math]::cos([decimal] $result.Text)
        }
    },
    @{name='tan'; action = {
            trap { $resultl.Text = 0; continue }
            $result.Text = [math]::tan([decimal] $result.Text)
        }
    },
    @{name='int'; action = {
            trap { $resultl.Text = 0; continue }
            $result.Text = [int] $result.Text
        }
    },
    @{name='Sqr'; action = {
            $result.Text = [double]$result.Text * [double]$result.text
        }
    },
    @{name='Quit'; action = {$form.Close()}}
)

$columns = 5

$form = Form Form @{
    Text = "PowerShell Calculator"
    TopLevel = $true
    Padding=5
}

$table = form TableLayoutPanel @{
    ColumnCount = 1
    Dock="fill"
}
$form.controls.add($table)

$menu = new-menustrip $form {
    new-menu File {
	new-menuitem "Clear" { clr }
        new-separator
        new-menuitem Quit { $form.Close() }
    }
}
$table.controls.add($menu)

$cfont = new-object Drawing.Font 'Lucida Console',10.0,Regular,Point,0

$script:result = form TextBox @{
    Dock="fill"
    Font = $cfont
    Text = 0
}
$table.Controls.Add($result)

$buttons = form TableLayoutPanel @{
    ColumnCount = $columns
    Dock = "fill"
}

foreach ($key in $keys) {
    $b = form button @{text=$key.name; font = $cfont; size = size 50 30 }
    $b.add_Click($key.action)
    $buttons.controls.Add($b)
}
$table.Controls.Add($buttons)

$height = ([math]::ceiling($keys.count / $columns)) * 40 + 100
$width = $columns * 58 + 10

$result.size = size ($width - 10) $result.size.height
$form.size = size $width $height
$form.Add_Shown({$form.Activate()})
[void] $form.ShowDialog();



c:\users\rocky\desktop\powershell books examples\windows powershell in action, second edition\finalcode\Appendix B\PwrSpiral.ps1
************************************************************************
#
# Windows PowerShell in Action
#
# Chapter 11 PowerShell Graphics Examples
#
# This script draws a spiral using the GDI+.
#

[CmdletBinding()]
param(
    [double]
        $opacity=1.0,
    $increment=50,
    $numRevs=20,
    [ValidateLength(2,2)]
    [int[]]
        $size=(500,500)
)


Import-Module ./wpiaforms

# A trick to make entering a list of constants easier
$colors = . {$args} red blue yellow green orange black cyan `
    teal white purple gray
$index=0
$color = $colors[$index++]

#
# Create the basic controls
#
$form = Form Form @{
    TopMost=$true
    Opacity=$opacity
    Size=size $size[0] $size[1]
}
$myBrush = Drawing SolidBrush $color
$pen =  Drawing pen black @{Width=3}
$rec = Drawing Rectangle 0,0,200,200

#
# Routine to draw a spiral on in the form
#
function Spiral($grfx)
{
    $cx, $cy =$Form.ClientRectangle.Width,
        $Form.ClientRectangle.Height
    $iNumPoints = $numRevs * 2 * ($cx+$cy)
    $cx = $cx/2
    $cy = $cy/2
    $np = $iNumPoints/$numRevs
    $fAngle = $i*2.0*3.14159265 / $np
    $fScale = 1.0 - $i / $iNumPoints
    $x,$y = ($cx * (1.0 + $fScale * [math]::cos($fAngle))), 
            ($cy * (1.0 + $fScale * [math]::Sin($fAngle)))
    for ($i=0; $i -lt $iNumPoints; $i += 50)
    {
        $fAngle = $i*2.0*[math]::pi / $np
        $fScale = 1.0 - $i / $iNumPoints
        $ox,$oy,$x,$y = $x,$y,
            ($cx * (1.0 + $fScale * [math]::cos($fAngle))), 
            ($cy * (1.0 + $fScale * [math]::Sin($fAngle)))
        $grfx.DrawLine($pen, $ox, $oy, $x, $y)
    }
}

#
# Form event handler...
#
$handler = {
    $rec.width = $form.size.width
    $rec.height = $form.size.height
    $myBrush.Color = $color
    $formGraphics = $form.CreateGraphics()
    $formGraphics.FillRectangle($myBrush, $rec)

    $form.Text = "Color: $color".ToUpper()
    $color = $colors[$index++]
    $index %= $colors.Length

    $pen.Color = $color
    Spiral $formGraphics
    $formGraphics.Dispose();
}

$timer = new-object system.windows.forms.timer
$timer.interval = 5000
$timer.add_Tick($handler)
$timer.Start()

$Form.add_paint($handler)

$form.Add_Shown({$form.Activate()})
[void] $form.ShowDialog()



c:\users\rocky\desktop\powershell books examples\windows powershell in action, second edition\finalcode\Appendix B\Show-Processes.ps1
************************************************************************
[Error] - File could not be written...


c:\users\rocky\desktop\powershell books examples\windows powershell in action, second edition\finalcode\Appendix B\Start-ClickFormDemo.ps1
************************************************************************
#
# Windows PowerShell in Action
#
# Chapter 11 Demo script using the Winform library
#
# This function displays a form and sets up a click
# handler for the form so that anywhere you click, you'll
# see the word "Hello" appear.
# generic list.
#
# This is an additional example that is not discussed in the book.

Import-Module ./wpiaforms

$font = Drawing Font "Consolas", 15
$form = Form Form @{
        text="My First Interactive Action"
        size = size 800 600
    }

$form.Text = "My First Interactive Application"
$count = 0

#
# Click handler will draw a label on the form
# containing the number of the label elemet added.
# The counter variable is captured inside a closure
$click = {
    $script:Count += 1
    $l = Form Label @{
        Text = "$count"
        AutoSize = $True
        Location = $_.Location
        ForeColor = "Red"
        BackColor = "Cyan"
        Font = $font
    }
    $this.Controls.Add($l)
}.GetNewClosure()

$form.add_Click($click)

$form.ShowDialog()



c:\users\rocky\desktop\powershell books examples\windows powershell in action, second edition\finalcode\Appendix B\TicTacToe.ps1
************************************************************************
#
# Windows PowerShell in Action
#
# Chapter 11 PowerShell Graphics Examples
#
# This script implements a simple Tic-Tac-Toe game
# in PowerShell using WinForms.
#
# This is an additional example, not covered in the book.
#

Import-Module .\wpiaforms.psm1

$form = Form Form @{
    Text = "PowerShell TicTacToe"
    StartPosition = "CenterScreen"
}

$Form.SuspendLayout()

$winningMoves =
    (0, 1, 2),
    (3, 4, 5),
    (6, 7, 8),
    (0, 3, 6),
    (1, 4, 7),
    (2, 5, 8),
    (0, 4, 8),
    (2, 4, 6)

#
# Build a hash table to winning moves to try. The key contains
# the pattern to check, the value is where to move...
#
$WinningMovesToTry = @{
    #012345678
    "OO ......" = 2
    "O O......" = 1
    " OO......" = 0
    "...OO ..." = 5
    "...O O..." = 4
    "... OO..." = 3
    "......OO " = 8
    "......O O" = 7
    "...... OO" = 6
    " ...O...O" = 0
    "O... ...O" = 4
    "O...O... " = 8
    "..O. .O.." = 4
    ".. .O.O.." = 2
    "..O.O. .." = 6
    "O..O.. .." = 6
    "O.. ..O.." = 3
    " ..O..O.." = 0
    ".O..O.. ." = 7
    ".O.. ..O." = 4
    ". ..O..O." = 1
    "..O..O.. " = 8
    "..O.. ..O" = 5
    ".. ..O..O" = 2    
}

#
# The blocking move table is the same as the winning move
# table except X instead of O
#
$BlockingMovesToTry = @{}
foreach ($e in $WinningMovesToTry.GetEnumerator())
{
     $BlockingMovesToTry[ $e.key -replace 'O','X' ] = $e.value
}
$StrategicMovesToTry = @{
    '.... ....' = 4
}

#
# Set a button to the initialized state
#
function InitButton ($button, $buttonNumber)
{
    $button.Text = $buttonNumber
    $button.BackColor = $form.Backcolor
    $button.ForeColor = "black"
    $button.Font = $fonts.Normal
    $button.Enabled = $true
}

function MarkButton ($button, $player)
{
    $button.Enabled = $false
    $button.Text = $player
    $button.Font = $fonts.big
    $button.BackColor = "cyan"
    $button.ForeColor = "black"
}

#
# Reset the game board...
#
function NewGame
{
    $buttonNumber = 1
    $buttons | foreach {
        InitButton $_ ($buttonNumber++)
    }
}

#
# Get the board state as a simple string
#
function getBoardAsString
{
    $result = ""
    foreach ($button in $buttons) {
        $result += $( if ($button.Text -match '[XO]') {$button.Text} else {' '} )
    }
    $result
}

#
# Check for a cat's game (no winner)
#
function CatsGame
{
    if ((getBoardAsString) -notmatch ' ')
    {
        message "`n`nCats Game!`n`nClick OK for a new game.`n"
        NewGame
        return $true
    }
    $false
}

#
# Check to see if any body won...
#
function CheckWin ($buttons, $player)
{
    foreach ($move in $winningMoves)
    {
        $win = $true;
        foreach ($index in $move)
        {
            if ($buttons[$index].Text -notmatch $player)
            {
                $win = $false
                break
            }
        }
        if ($win)
        {
            #
            # Blink the winning row for a while
            # then leave it marked...
            #
            $fg, $bg = "red","white"
            for ($i=0; $i -lt 9; $i++)
            {
                foreach ($index in $move)
                {
                    $buttons[$index].BackColor = $fg
                    $buttons[$index].ForeColor = $bg
                }
                $Form.Update()
                start-sleep -milli 200
                $fg, $bg = $bg, $fg
            }
            
            #
            # Disable the remaining buttons so no more play happens...
            #
            foreach ($button in $buttons)
            {
                $button.Enabled = $false
            }
            return $true
        }
    }
    return $false
}

#
# Figure out the computer's next move...
#
$MoveGenerator = new-object random (get-date).millisecond
function ComputersMove
{
    $board = GetBoardAsString

    # look for potential wins first...
    foreach ($e in $WinningMovesToTry.GetEnumerator())
    {
        if ($board -match $e.key)
        {
            MarkButton $buttons[$e.value] O
            return
        }
    }
    
    # Check blocking moves next...
    foreach ($e in $BlockingMovesToTry.GetEnumerator())
    {
        if ($board -match $e.key)
        {
            MarkButton $buttons[$e.value] O
            return
        }
    }
    
    # Check strategic moves next...
    foreach ($e in $StrategicMovesToTry.GetEnumerator())
    {
        if ($board -match $e.key)
        {
            MarkButton $buttons[$e.value] O
            return
        }
    }
    
    # Otherwise just pick a move at random...
    $limit=100
    while ($limit--)
    {
        $move = $MoveGenerator.next(0,8)
        if ($board[$move] -match ' ')
        {
            MarkButton $buttons[$move] O
            return
        }
    }
    message "ERROR - no valid move found!"
}

#
# Define the button click callback...
#
$buttonClick = {
    if ( CatsGame ) { return }
    
    MarkButton $this X
    if (CheckWin $buttons X)
    {
        message "`nCongradulations!`nYou WIN!!!`n`n`n"
        return
    }
    
    if ( CatsGame ) { return }
    
    ComputersMove
    if (CheckWin $buttons O)
    {
        message "`nToo bad!`nYou lost :-(`n`n`n"
        return
    }
        
    CatsGame
}

#
# now build up the form...
#
$buttons = @()
$buttonNumber = 0
$xPos = 12
$yPos = 30
for ($x=0; $x -lt 3; $x++)
{
    for ($j=0; $j -lt 3; $j++)
    {
        $button = Form Button @{
                Location = Point $xPos $yPos
                Size = Size 50 50 
                                BackColor = $form.BackColor
                TabIndex = $buttonNumber++
            }
        $button.Add_Click($buttonClick)
            
        InitButton $button $buttonNumber    
        $xPos = rightEdge $button 12
        $lastControl = $button
        $Form.Controls.Add($button)
        $buttons += $button
    }
    
    $yPos = bottomEdge $lastControl 12
    $xPos = 12
}
    
$menu = new-menustrip $Form {
    new-menu File {
        new-menuitem "New Game" { NewGame }
        new-separator
        new-menuitem Quit { $Form.Close() }
    }
}

$form.controls.add($menu)

# MainForm
$Form.ClientSize = Size (RightEdge $lastControl 12) (BottomEdge $lastControl 12)

$form.Add_Shown({$form.Activate()})
[void] $form.ShowDialog()



c:\users\rocky\desktop\powershell books examples\windows powershell in action, second edition\finalcode\Appendix D\culture_example.ps1
************************************************************************
[Error] - File could not be written...


c:\users\rocky\desktop\powershell books examples\windows powershell in action, second edition\finalcode\Appendix D\transactions_examples.ps1
************************************************************************
[Error] - File could not be written...


c:\users\rocky\desktop\powershell books examples\windows powershell in action, second edition\finalcode\chapter01\chapter01_examples.ps1
************************************************************************
[Error] - File could not be written...


c:\users\rocky\desktop\powershell books examples\windows powershell in action, second edition\finalcode\chapter02\chapter02_examples.ps1
************************************************************************
[Error] - File could not be written...


c:\users\rocky\desktop\powershell books examples\windows powershell in action, second edition\finalcode\chapter03\chapter03_examples.ps1
************************************************************************
[Error] - File could not be written...


c:\users\rocky\desktop\powershell books examples\windows powershell in action, second edition\finalcode\chapter04\chapter04_examples.ps1
************************************************************************
[Error] - File could not be written...


c:\users\rocky\desktop\powershell books examples\windows powershell in action, second edition\finalcode\chapter05\setVariableExample.ps1
************************************************************************
[Error] - File could not be written...


c:\users\rocky\desktop\powershell books examples\windows powershell in action, second edition\finalcode\chapter06\Get-Options.ps1
************************************************************************
#
# Windows PowerShell in Action 2nd Edition
#
# Chapter 6 Switch statement example
#
# This example shows how the switch statement
# can be used to parse a collection of options.
#
# Although this isn't usually needed in PowerShell
# (PowerShell has direct support for argument parsing),
# it illustrates how this might be done if you
# need to parse an option syntax that doesn't match
# PowerShell's.
#

# Set up the collection of options to parse
$options="-a -b Hello -c".split()

# parse the options into variables...
$a=$c=$d=$false
$b=$null
switch ($options)
{
'-a' {$a=$true; continue}
'-b' {[void] $switch.movenext(); $b= $switch.current; continue}
'-c' {$c=$true; continue}
'-d' {$d=$true; continue}
}

# Now display the result...
"a=$a b=$b c=$c d=$d"



c:\users\rocky\desktop\powershell books examples\windows powershell in action, second edition\finalcode\chapter06\Get-WindowsUpdates.ps1
************************************************************************
#
# Windows PowerShell in Action
#
# Chapter 6 Switch statement example
#
# This script searchs through the Windows update
# log counting certain types of updates.
#

$au=$du=$su=0
switch -regex (cat "$env:windir\windowsupdate.log")
{
    'START.*Finding updates.*AutomaticUpdates' {$au++}
    'START.*Finding updates.*Defender' {$du++}
    'START.*Finding updates.*SMS' {$su++}
}

"Automatic Updates:$au Defender Updates:$du SMS Updates:$su"



c:\users\rocky\desktop\powershell books examples\windows powershell in action, second edition\finalcode\chapter07\chapter07_examples.ps1
************************************************************************
[Error] - File could not be written...


c:\users\rocky\desktop\powershell books examples\windows powershell in action, second edition\finalcode\chapter07\UpdateObjectExample.ps1
************************************************************************
[Error] - File could not be written...


c:\users\rocky\desktop\powershell books examples\windows powershell in action, second edition\finalcode\chapter08\doc_comments.ps1
************************************************************************
[Error] - File could not be written...


c:\users\rocky\desktop\powershell books examples\windows powershell in action, second edition\finalcode\chapter08\hello.ps1
************************************************************************
#
# Windows PowerShell in Action Second Edition
#
# Chapter 7 Parameterized Hello World examples
#
# This script takes a name as a single parameter
# defaulted to "world".
#

param($name="world")
"Hello $name!"




c:\users\rocky\desktop\powershell books examples\windows powershell in action, second edition\finalcode\chapter08\OutputTypeExample.ps1
************************************************************************
#
# Windows PowerShell in Action Second Edition
#
# Chapter 8 Example of a function where the output
# type of the function is set for each parameter set.
#
#

#
# This function defines four parameter sets, each of which
# has a different type: asInt, asString, asDouble and finally a type
# that doesn't exist...
function Test-OutputType
{
  [CmdletBinding(DefaultParameterSetName = "1nt")]
  [OutputType("asInt", [int])]
  [OutputType("asString", [string])]
  [OutputType("asDouble", ([double], [single]))]
  [OutputType("lie", [int])]
  param (
    [parameter(ParameterSetName="asInt")] [switch] $asInt,
    [parameter(ParameterSetName="asString")] [switch] $asString,
    [parameter(ParameterSetName="asDouble")] [switch] $asDouble,
    [parameter(ParameterSetName="lie")] [switch] $lie
 )
 Write-Host "Parameter set: $($PSCmdlet.ParameterSetName)"
 switch ($PSCmdlet.ParameterSetName) {
     "asInt" { 1 ; break }
     "asString" { "1" ; break }
     "asDouble" { 1.0 ; break }
     "lie" { "Hello there"; break } }
}

# The first three calls return the expected type
(Test-OutputType -asString).GetType().FullName
(Test-OutputType -asInt).GetType().FullName
(Test-OutputType -asDouble).GetType().FullName

# The last call, which declares a non-existent type
# does not produce an error since the output type attribute
# is only metadata that serves as a form of documentation. It
# doesn't enforce the output type 
(Test-OutputType -lie).GetType().FullName
(Get-Command Test-OutputType).ScriptBlock.Attributes |
  Select-Object typeid, type |
  Format-List

# Since the output type is simply documentation, 
# you need a way to extract the information. The following commands
# show how to do this.
$ct = (Get-Command Get-Command).ImplementingType
$ct.GetCustomAttributes($true) |
  Select-Object typeid, type |
  Format-List


c:\users\rocky\desktop\powershell books examples\windows powershell in action, second edition\finalcode\chapter08\ParameterExamples.ps1
************************************************************************
[Error] - File could not be written...


c:\users\rocky\desktop\powershell books examples\windows powershell in action, second edition\finalcode\chapter08\ShouldContinueExample.ps1
************************************************************************
[Error] - File could not be written...


c:\users\rocky\desktop\powershell books examples\windows powershell in action, second edition\finalcode\chapter09\counter.ps1
************************************************************************
[Error] - File could not be written...


c:\users\rocky\desktop\powershell books examples\windows powershell in action, second edition\finalcode\chapter09\modules_demo_file.ps1
************************************************************************
#
# Windows PowerShell in Action Second Edition
#
# Chapter 9 Example how to use the module cmdlets.
#

# List the module cmdlets
Get-Command -type cmdlet *module* | Format-Table -AutoSize

# List help topics for modules
Get-Help *module* | Format-Table -AutoSize | Out-Host

# What modules are loaded?
Get-Module

# What modules are available? Controlled by the module path
$ENV:PSMODULEPATH
# Let's look at the system modules...
Get-Module -ListAvailable | where { $_.path -match "system32" }

# modules are just stored in directories
dir $PSHOME/modules

# now lets import a module
Import-Module psdiagnostics
Get-Module

# lots of information available from the PSModuleInfo object
Get-Module | Format-List

# now let's remove this module from memory
Remove-Module psdiagnostics


# Creating modules
#
# Let's take a look at a script that implements 
# a simple counter
Get-Content .\counter.ps1

# Now let's dot source it into our environment
. .\counter.ps1

# Let's see what happened
Get-Command *-count

# Try it out
Get-Count
Get-Count
Reset-Count

# What about the increment function? It's also visible from the script
Get-Command setIncrement
setIncrement 7
Get-Count

# As are the variables.
Get-Variable count, increment

# RSo dot sourcing works, but it leaks implementation details
rm -force variable:count,variable:increment,function:Reset-Count,function:Get-Count,function:setIncrement


#
# Now let's take a look at how modules improve the experience
# We could take our counter script and turn it into a module by
# saving it with a .psm1 extension (don't actually need to do this)
#Copy-Item .\counter.ps1 .\counter.psm1 -Force

# We can import the module by specifying the path to the module file
Import-Module .\counter.psm1

# Let's see what was imported
Get-Command -Module counter

# What about the variables?
Get-Variable count, increment

# Importing a module gives you the most common behavior by default:
# All functions are made public (imported)
# Variables and aliases are kept private (not imported)
# We can use Remove-Module to remove the imported members
Get-Module | Remove-Module

# And Get-Count is no longer accessible
Get-Count

# But really, we don't want to pollute the namespace with the
# setIncrement function, either.
# This should be private to the module.
# We can use Export-ModuleMember within the script module to
# specify what gets exported from the module
Get-Content .\counter1.psm1

# Let's import the revised module
Import-Module .\counter1.psm1

# Now we can still access the *-Count functions, but the 
# setIncrement function is now private to the module
Get-Command *-Count
Get-Command setIncrement
Remove-Module counter1

# Let's take a closer look at Export-ModuleMember in another example
Get-Content .\counter2.psm1

# Import the module
Import-Module .\counter2.psm1

# The count commands are there
Get-Command *-Count

# but setIncrement doesn't work as desired
setIncrement 10

# But now we can access the increment variable directly
# We use the $global modifier to ensure we're accessing the
# 'increment' variable defined in the global scope as opposed
# to redefining 'increment' in the Start-Demo script scope.
$global:increment
# Let's try the alias "reset" we exported
reset
Get-Count
Get-Module | Remove-Module



c:\users\rocky\desktop\powershell books examples\windows powershell in action, second edition\finalcode\chapter10\example1.ps1
************************************************************************
[Error] - File could not be written...


c:\users\rocky\desktop\powershell books examples\windows powershell in action, second edition\finalcode\chapter10\ExampleModuleScript.ps1
************************************************************************

$code = @'
using System.Management.Automation;

[Cmdlet("Write", "InputObject")]
public class MyWriteInputObjectCmdlet : Cmdlet
{
    [Parameter]
    public string Parameter1;

    [Parameter(Mandatory = true, ValueFromPipeline=true)]
    public string InputObject;

    protected override void ProcessRecord()
    {
        if (Parameter1 != null)
                WriteObject(Parameter1 +  ":" +  InputObject);
            else
                WriteObject(InputObject);
    }
}
'@
$bin = Add-Type $code -pass
$bin.Assembly | Import-Module




c:\users\rocky\desktop\powershell books examples\windows powershell in action, second edition\finalcode\chapter10\manifestDemo.ps1
************************************************************************
[Error] - File could not be written...


c:\users\rocky\desktop\powershell books examples\windows powershell in action, second edition\finalcode\chapter10\moduleContextDemo.ps1
************************************************************************
[Error] - File could not be written...


c:\users\rocky\desktop\powershell books examples\windows powershell in action, second edition\finalcode\chapter10\nested.ps1
************************************************************************
#
# Windows PowerShell in Action 2nd Edition
#
# Chapter 10 Advanced modules
#
# This example shows how to work with nested modules
#
Get-Content usesCount.psm1
Import-Module  .\usesCount.psm1
Get-Module
Get-Module usesCount | Format-List
Get-Module -all
Get-Command CountUp | Format-List -force *
Get-Command Get-Count | Format-List
${function:CountUp}.File
${function:Get-Count}.File

cat .\usesCount2.psm1
Import-Module .\usesCount2
get-module
get-command Get-Count | ft name,module
get-command CountUp | ft name,module


c:\users\rocky\desktop\powershell books examples\windows powershell in action, second edition\finalcode\chapter10\setting_module_properties.ps1
************************************************************************
[Error] - File could not be written...


c:\users\rocky\desktop\powershell books examples\windows powershell in action, second edition\finalcode\chapter10\test_binary_modules.ps1
************************************************************************
#
# Windows PowerShell in Action 2nd Edition
#
# Chapter 10 Advanced modules
#
# This example displays the contents of a C# file
# defining a cmdlet. It uses Add-Type to complile the source
# into a binary module

Get-Content ExampleModule.cs
Add-Type -path .\ExampleModule.cs `
    -OutputAssembly .\ExampleModule.dll

dir examplemodule.dll
Import-Module ./examplemodule
Get-Module | Format-List
1,2,3 | write-inputobject -parameter1 "Number"




c:\users\rocky\desktop\powershell books examples\windows powershell in action, second edition\finalcode\chapter11\chapter11_examples.ps1
************************************************************************
[Error] - File could not be written...


c:\users\rocky\desktop\powershell books examples\windows powershell in action, second edition\finalcode\chapter11\CreatingStronglyTypedProperties.ps1
************************************************************************
[Error] - File could not be written...


c:\users\rocky\desktop\powershell books examples\windows powershell in action, second edition\finalcode\chapter11\dynamicModules.ps1
************************************************************************
[Error] - File could not be written...


c:\users\rocky\desktop\powershell books examples\windows powershell in action, second edition\finalcode\chapter11\example1.ps1
************************************************************************
[Error] - File could not be written...


c:\users\rocky\desktop\powershell books examples\windows powershell in action, second edition\finalcode\chapter11\ExampleDefiningAnEnum.ps1
************************************************************************
[Error] - File could not be written...


c:\users\rocky\desktop\powershell books examples\windows powershell in action, second edition\finalcode\chapter12\analyser\doit.ps1
************************************************************************
[Error] - File could not be written...


c:\users\rocky\desktop\powershell books examples\windows powershell in action, second edition\finalcode\chapter12\analyser\doit2.ps1
************************************************************************
[Error] - File could not be written...


c:\users\rocky\desktop\powershell books examples\windows powershell in action, second edition\finalcode\chapter12\analyser\Invoke-Model.ps1
************************************************************************
[Error] - File could not be written...


c:\users\rocky\desktop\powershell books examples\windows powershell in action, second edition\finalcode\chapter12\analyser\models\diskspace\diskspace.ps1
************************************************************************

$computerName = (get-wmiobject win32_computersystem).Name
$drive = get-psdrive c

# construct an XML results document
[xml] @"
<DiskDrive>
   <ComputerName>$computerName</ComputerName>
   <Used>$($drive.Used)</Used>
   <Free>$($drive.Free)</Free>
   <Name>$($drive.Name)</Name>
</DiskDrive>
"@



c:\users\rocky\desktop\powershell books examples\windows powershell in action, second edition\finalcode\chapter12\analyser\models\powershell\ConfigurationProviders.ps1
************************************************************************


add-type -wa silentlycontinue -AssemblyName system.core
add-type -AssemblyName system.xml.linq
function xelement ($name, $body)
{
    if ($body -is [scriptblock]) {$body = & $body}
    ,(new-object system.xml.linq.xelement @(@($name) + $body))
}

function xattribute ($name, $content)
{
    new-object system.xml.linq.xattribute $name,$content
}


$pse = get-itemproperty HKLM:\software\microsoft\powershell\1\PSConfigurationProviders\Microsoft.PowerShell *

[xml] [string] (
    xelement PSConfigurationProviders {
        $pse.psobject.properties | where { $_.name -notmatch "^ps|\(" } | foreach {
            xelement $_.name $_.value
        }
    }
)



c:\users\rocky\desktop\powershell books examples\windows powershell in action, second edition\finalcode\chapter12\analyser\models\powershell\engine.ps1
************************************************************************

add-type -wa silentlycontinue -AssemblyName system.core
add-type -AssemblyName system.xml.linq
function xelement ($name, $body)
{
    if ($body -is [scriptblock]) {$body = & $body}
    ,(new-object system.xml.linq.xelement @(@($name) + $body))
}

function xattribute ($name, $content)
{
    new-object system.xml.linq.xattribute $name,$content
}


$pse = get-itemproperty hklm:\software\microsoft\powershell\1\PowerShellEngine *

[xml] [string] (
    xelement PowerShellEngine {
        $pse.psobject.properties | where { $_.name -notmatch "^ps|\(" } | foreach {
            xelement $_.name $_.value
        }
    }
)



c:\users\rocky\desktop\powershell books examples\windows powershell in action, second edition\finalcode\chapter12\analyser\New-XmlDocument.ps1
************************************************************************
#
# This is a small utility implements a PowerShell DSL for constructing
# XML Documents. It uses commands, scriptblocks and hashtables to build
# and XmlDocument object which it then returns.
#
# The implementation is very limited and not completely general at this
# point. One obvious thing that's missing is schema support. In this case
# the schema would take the form of the list of legal attributes and
# and children for each node type. The syntax would look very much like
# the syntax for the document itself. See the xmltest.ps1 script
# to see what this looks like.
#

param (
    [scriptblock] $sb,
    $doc = [xml] '<?xml version="1.0" encoding="utf-8"?><ns:RoleInstance xmlns:ns="http://namespace.microsoft.com/2007/Whatever"/>'
)

#
# Execute the scriptblock to get the list of element hashtables
$elements = & $sb

# Now iterate over the list construction elements then adding
# the specified attributes. 
foreach ($e in $elements)
{
    $elem = $doc.CreateElement($e.element)
    foreach ($attr in $e.Attributes.GetEnumerator())
    {
        $elem.SetAttribute($attr.name, $attr.value)
    }
    # The next step would be to recursivly construct the
    # of this node but that's not implemented yet...

    # Finally add this element
    [void] $doc.get_ChildNodes().Item(1).AppendChild($elem)
}


#
# Return the constructed document...
#
$doc



c:\users\rocky\desktop\powershell books examples\windows powershell in action, second edition\finalcode\chapter12\implicit-remoting.ps1
************************************************************************
[Error] - File could not be written...


c:\users\rocky\desktop\powershell books examples\windows powershell in action, second edition\finalcode\chapter13\complexconstrainedconfigscript.ps1
************************************************************************
[Error] - File could not be written...


c:\users\rocky\desktop\powershell books examples\windows powershell in action, second edition\finalcode\chapter13\configscript.ps1
************************************************************************
[Error] - File could not be written...


c:\users\rocky\desktop\powershell books examples\windows powershell in action, second edition\finalcode\chapter13\configuring_wsnam.ps1
************************************************************************
[Error] - File could not be written...


c:\users\rocky\desktop\powershell books examples\windows powershell in action, second edition\finalcode\chapter13\constrainedconfigscript.ps1
************************************************************************
[Error] - File could not be written...


c:\users\rocky\desktop\powershell books examples\windows powershell in action, second edition\finalcode\chapter13\install-config.ps1
************************************************************************


$err = $null
$void = [system.management.automation.psparser]::Tokenize( [io.file]::ReadAllText("$pwd/constrainedconfigscript.ps1"), [ref] $err)
if ($err)
{
    $err | % { "parse error at line {0}: {1}" -f $_.token.startline, $_.message }
    return
}

Unregister-PSSessionConfiguration -name wpia1 -force
Register-PSSessionConfiguration -name wpia1 `
    -startupscript $pwd/complexconstrainedconfigscript.ps1 -force
    
"Use:

icm localhost -config wpia1 { ... }

"



c:\users\rocky\desktop\powershell books examples\windows powershell in action, second edition\finalcode\chapter13\newconfig.ps1
************************************************************************
#
# Windows PowerShell in Action 2nd Edition
#
# Chapter 13 Advanced remoting and configuration
#
# Creating and exploring a new PowerShell remoting endpoint configuration
#

@'
function foo { "In new endpoint!" }
'@ > configscript.ps1

Register-PSSessionConfiguration -name wpia1 `
  -startupscript $pwd/configscript.ps1 -force

cd  wsman:\localhost\plugin
dir
icm localhost -config wpia1 { foo 13 }
Unregister-PSSessionConfiguration -name wpia1 -force

Get-Date
$gd = get-command Get-Date
$gd.Visibility
$gd.Visibility = "private"
$gd.Visibility
Get-Date
& "get-date"
& { get-date }
function MyGetDate { get-date }
MyGetDate
$gd.Visibility = "public"

$ExecutionContext.SessionState
$ExecutionContext.SessionState.LanguageMode
function restore {
   $ExecutionContext.SessionState.LanguageMode = "FullLanguage"
}

$ExecutionContext.SessionState.LanguageMode = "RestrictedLanguage"
$a=123
function foo {}
set-item function:foo {}
restore
$a=123

$ipp = (get-command ipconfig.exe).Definition
$ExecutionContext.SessionState.Applications.Clear()
$ExecutionContext.SessionState.Applications.Add($ipp)
ipconfig | grep ipv4
expand /? | select-string expand
& { expand /? | select-string expand }
$ExecutionContext.SessionState.Applications.Clear()
$ExecutionContext.SessionState.Applications.Add('*')







c:\users\rocky\desktop\powershell books examples\windows powershell in action, second edition\finalcode\chapter13\serialization_examples.ps1
************************************************************************
[Error] - File could not be written...


c:\users\rocky\desktop\powershell books examples\windows powershell in action, second edition\finalcode\chapter14\eventlog_examples.ps1
************************************************************************
[Error] - File could not be written...


c:\users\rocky\desktop\powershell books examples\windows powershell in action, second edition\finalcode\chapter14\tokenizer_api_examples.ps1
************************************************************************
[Error] - File could not be written...


c:\users\rocky\desktop\powershell books examples\windows powershell in action, second edition\finalcode\chapter15\Add-InvokeInBackgroundTabCommand.ps1
************************************************************************
[Error] - File could not be written...


c:\users\rocky\desktop\powershell books examples\windows powershell in action, second edition\finalcode\chapter15\Add-SnippetsMenuItem.ps1
************************************************************************
[Error] - File could not be written...


c:\users\rocky\desktop\powershell books examples\windows powershell in action, second edition\finalcode\chapter15\Add-SyntaxCheckCustomkMenuItem.ps1
************************************************************************
[Error] - File could not be written...


c:\users\rocky\desktop\powershell books examples\windows powershell in action, second edition\finalcode\chapter15\CommandLineDebuggerExamples.ps1
************************************************************************
[Error] - File could not be written...


c:\users\rocky\desktop\powershell books examples\windows powershell in action, second edition\finalcode\chapter15\snippets.ps1
************************************************************************
#
# Windows PowerShell in Action 2nd Edition
#
# Chapter 15 The PowerShell ISE and debugger
#
# A file of PowerShell "snippet" examples.
#

########################################
#
# String operations
#
$a = 2; "a is $a"                     # variable expansion in double-strings
"The date is $(Get-Date)"             # subexpression evaluation in double-quoted strings
"a`t tab and a `n"                    # escape sequence for tab and newline, escape character is '`'
'a is $a'                             # no expansion in single-quoted strings
"hello" + "there"                     # string concatenation
"hello" -like "he*"                   # string match wildcard
"hello" -match "el"                   # string match regex
"hello" -replace 'ell.*$', "i there"  # string replace regex
"abc" * 10                            # string multiplication
"a, b, c" -split ', *'                # split string using regex
-split "a b c"                        # unary split on whitespace
"abcdefg"[0]                          # indexing, origin 0
"abcdefg"[1..3]                       # indexing with range, returns char array
"abcdefg".Substring(3)                # substring from position to end of string
"abcdefg".Substring(2,3)              # substring from position, n characters

########################################
#
# Array operations
#
$a = 1,2,3,4                          # literal array using comma operator, no brackets required
$a = ,1                               # literal array of one element with unary comma operator
$a = @()                              # empty array
(1,2,3,4,5).Length                    # length of an array
$a = @( dir )                         # force result of command to be an array
$a = 1,2,3,4 + 5,6                    # array concatenation
$a[0]                                 # array index, origin zero
$a[2..3]                              # array range
"one", "two", "three" -match '[nw]'   # array regex match to extract elements
"one", "two", "three" -like 't*'      # array wildcard match to extract elements
@(1,2,3,4,5,6,7 -gt 2) -lt 4          # extract elements from array using comparison operations
-join "a","b","c"                     # unary join without spaces
"a","b","c" -join "+"                 # 


########################################
#
# Conditional statements
#

# statement conditional fi else endif

if ( $x -gt 10 )
{
    # ...
}
elseif ($x -gt 100) # elseif is a keyword
{
    # ...
}
else
{
    # ...
}

########################################
#
# looping statements
#
# statement looping while
while ( $x -lt 10)
{
    # ...
}

# statement looping for
for ($i = 1; $i -lt 10; $i++)
{
    $i * 2
}
#statement looping foreach
foreach ($i in Get-Process)
{
    # ...
}

########################################
#
# Defining functions
#

# statement simple function
function foo ($x)
{
    $x * 2
}

# statement simple function using param statement
function foo
{
    param ($x)
    $x * 2
}

# statement begin/process/end function
function foo ($x)
{
    begin
    {
        # ...
    }
    process
    {
        # ...
    }
    end
    {
        # ...
    }
}

# statement advanced function
function foo
{
  [CmdletBinding(
	DefaultParameterSet="parametersetname",
	ConfirmImpact=$true,
	SupportsShouldProcess=$true,
	)]
    param (
          [Parameter(Mandatory=$true,
                             Position=0,
                             ParameterSetName="set1",
                             ValueFromPipeline=$false,
                             ValueFromPipelineByPropertyName=$true,
                             ValueFromRemainingArguments=$false,
                             HelpMessage="some help this is")]
                             [int] 
                             $p1 = 0
    )
    begin
    {
        # ...
    }
    process
    {
        # ...
    }
    end
    {
        # ...
    }
}

########################################
#
# The format operator <formatString> -f <arrayExpression>
#
"{0}+{1} is {2}, today is {3}" -f 1, 1, 2, (Get-Date).dayofweek
# Format specifiers {0} Display a particular element.	        
"{0} {1}" -f "a","b"	# -> a b
#{0:x}	Display a number in Hexadecimal.
"0x{0:x}" -f 181342 	# -> 0x2c45e
#{0:X}	Display in hex, letters in uppercase
"0x{0:X}" -f 181342	    # -> 0x2C45E
"{0:dn}"	            # Display number left-justified, padded with zeros
?{0:d8}? -f 3	        # -> 00000003
#{0:p}	Display a number as a percentage.
?{0:p}? -f .123	12.30   # -> %
#{0:C}	Display a number as currency
?{0:c}? -f 12.34	    # -> $12.34
#{0,n}	Display with field width n, left aligned.
?|{0,5}|? ?f ?hi?	    # -> |   hi|
#{0,-n)	Display with field width n, right aligned.
?|{0,-5}|? ?f ?hi?	    # -> |hi   |
#{0:hh} {0:mm}	Displays the hours and minutes from a DateTime value.
?{0:hh}:{0:mm}? ?f (Get-Date)	# -> 01:34
#{0:C}	Display using the currency symbol for the current culture.
?|{0,10:C}|? -f 12.4	 # -> | $12.40|

########################################
#
# recursive directory search - file a file name
dir -recurse -filter *name*
dir -recurse -filter *name* c:\users\
# 
# directory search, show directories only
dir -recurse | where {$.PSIsContainer}
# directory search, show files only
dir -recurse | where { -not $.PSIsContainer}
# directory search, recursive, looking for matching strings in text files
dir -recurse -filter *.txt | Select-String 'text.*to.*match' # regex match
dir -recurse -filter *.txt | Select-String -wildcard '*text.*to.*match*' # wildcard match




c:\users\rocky\desktop\powershell books examples\windows powershell in action, second edition\finalcode\chapter15\testscript.ps1
************************************************************************
[Error] - File could not be written...


c:\users\rocky\desktop\powershell books examples\windows powershell in action, second edition\finalcode\chapter15\testscript2.ps1
************************************************************************
[Error] - File could not be written...


c:\users\rocky\desktop\powershell books examples\windows powershell in action, second edition\finalcode\chapter15\testScriptWithVariable.ps1
************************************************************************
[Error] - File could not be written...


c:\users\rocky\desktop\powershell books examples\windows powershell in action, second edition\finalcode\chapter16\basic_xml_operations.ps1
************************************************************************
#
# Windows PowerShell in Action
#
# Chapter 16 Examples showing basic XML operations
#
# This script walks through the basic operations for
# creating and manipulating XML documents in PowerShell
#
# Note the use of Out-String in displaying the results.
# This is necessary because we're mixing multiple
# object types in the output stream which requires
# us to pre-format the output to get the desired results.
# (See the discussion on formatting the book for more
# information.)
#

"Define an XML document and save it in a variable"
$d = [xml] "<top><a>one</a><b>two</b><c>3</c></top>"

""
"Display the object"
$d

""
"Display the top level"
$d.top | ft -auto | Out-String

""
"Display the element a"
$d.top.a

""
"Change the value of element a"
$d.top.a = "Four"
$d.top.a

""
"Create new elements d and e"
$el= $d.CreateElement("d")
$el.set_InnerText("Hello")
$d.top.AppendChild($el)
$ne = $d.CreateElement("e")
$ne.psbase.InnerText = "World"
$d.top.AppendChild($ne)
$d.top | ft -auto | Out-String

""
"Save the document to a file 'new.xml' then display the file"
$d.save("$PWD\new.xml")
type $PWD\new.xml

""
"Add an attribute to the top element and display the result"
$attr = $d.CreateAttribute("BuiltBy")
$attr.psbase.Value = "Windows PowerShell"
$d.psbase.DocumentElement.SetAttributeNode($attr)
$d.top | ft -auto | Out-String

""
"Save the modified document to 'new.xml' then display the file"
$d.save("c:\temp\new.xml")
type c:\temp\new.xml

""
"Create a new XML object from the file and display it"
$nd = [xml] [string]::join("`n", (gc -read 10kb c:\temp\new.xml))
$nd.Top | ft -auto | Out-String

"And finally remove the file 'new.xml'"
Remove-Item new.xml




c:\users\rocky\desktop\powershell books examples\windows powershell in action, second edition\finalcode\chapter16\Format-XmlDocument.ps1
************************************************************************
#
# Windows PowerShell in Action
#
# Chapter 16 The Format-XmlDocument function
#
# Defines a function for displaying an XML document.
#
function global:Format-XmlDocument ($doc="$PWD\fancy.xml")
{
  $settings = New-Object System.Xml.XmlReaderSettings
  $doc = (Resolve-Path $doc).ProviderPath
  $reader = [xml.xmlreader]::create($doc, $settings)
  $indent=0
  function indent ($s) { "  "*$indent+$s }
  while ($reader.Read())
  {
    if ($reader.NodeType -eq [Xml.XmlNodeType]::Element)
    {
      $close = $(if ($reader.IsEmptyElement) { "/>" } else { ">" })
      if ($reader.HasAttributes)
      {
        $s = indent "<$($reader.Name) "
        [void] $reader.MoveToFirstAttribute()
        do
        {
          $s += "$($reader.Name) = `"$($reader.Value)`" "
        }
        while ($reader.MoveToNextAttribute())
        "$s$close"
      }
      else
      {
        indent "<$($reader.Name)$close"
      }
      if ($close -ne '/>') {$indent++}
    }
    elseif ($reader.NodeType -eq [Xml.XmlNodeType]::EndElement )
    {
      $indent--
      indent "</$($reader.Name)>"
    }
    elseif ($reader.NodeType -eq [Xml.XmlNodeType]::Text)
    {
      indent $reader.Value
    }
  }
  $reader.close()
}




c:\users\rocky\desktop\powershell books examples\windows powershell in action, second edition\finalcode\chapter16\Get-CheckSum.ps1
************************************************************************
#
# Windows PowerShell in Action
#
# Chapter 16 The Get-CheckSum function
#
# Defines a (not very good) checksum function that simply
# adds up all of the bytes in file file.
#
function global:Get-CheckSum (
    $path=$(throw "You must specify a file to checksum")
)
{
    $sum=0
    get-content -encoding byte -read -1 $path | %{
        foreach ($byte in $_) { $sum += $byte }
    }
    $sum
}




c:\users\rocky\desktop\powershell books examples\windows powershell in action, second edition\finalcode\chapter16\Get-HexDump.ps1
************************************************************************
#
# Windows PowerShell in Action
#
# Chapter 16 The Get-HexDump function
#
# This function will do a structured
# hex dump of the specified path.
#
function global:Get-HexDump (
    $path = $(throw "path must be specified"),
    $width=10,
    $total=-1
)
{
    $OFS=""
    Get-Content -Encoding byte $path -ReadCount $width `
        -totalcount $total | %{
    $record = $_
    if (($record -eq 0).count -ne $width)
    {
        $hex = $record | %{
        " " + ("{0:x}" -f $_).PadLeft(2,"0")}
        $char = $record | %{
        if ([char]::IsLetterOrDigit($_))
            { [char] $_ } else { "." }}
        "$hex $char"
        }
    }
}




c:\users\rocky\desktop\powershell books examples\windows powershell in action, second edition\finalcode\chapter16\Get-MagicNumber.ps1
************************************************************************
#
# Windows PowerShell in Action
#
# Chapter 16 Get-MagicNumber function
#
# This function will get the "magic number"
# from a file.
#
function global:Get-MagicNumber ($path)
{
    $OFS=""
    $mn = Get-Content -encoding byte $path -read 4 -total 4
    $hex1 = ("{0:x}" -f ($mn[0]*256+$mn[1])).PadLeft(4, "0")
    $hex2 = ("{0:x}" -f ($mn[2]*256+$mn[3])).PadLeft(4, "0")
    [string] $chars = $mn| %{ if ([char]::IsLetterOrDigit($_))
        { [char] $_ } else { "." }}
    "{0} {1} '{2}'" -f $hex1, $hex2, $chars
}

# Examples sowing the use of this function:

get-magicnumber $env:windir/Zapotec.bmp
get-magicnumber $env:windir/explorer.exe



c:\users\rocky\desktop\powershell books examples\windows powershell in action, second edition\finalcode\chapter16\Invoke-PSXmlDocument.ps1
************************************************************************
[Error] - File could not be written...


c:\users\rocky\desktop\powershell books examples\windows powershell in action, second edition\finalcode\chapter16\New-XmlFile.ps1
************************************************************************
#
# Windows PowerShell in Action
#
# Chapter 16 Create example XML file.
#
# Create the XML file used in some of the examples.
#

@'
<top BuiltBy = "Windows PowerShell">
    <a pronounced="eh">
        one
    </a>
    <b pronounced="bee">
        two
    </b>
    <c one="1" two="2" three="3">
        <one>
            1
        </one>
        <two>
            2
        </two>
        <three>
            3
        </three>
    </c>
    <d>
        Hello there world
    </d>
</top>
'@ > $PWD\fancy.xml




c:\users\rocky\desktop\powershell books examples\windows powershell in action, second edition\finalcode\chapter16\registry_examples.ps1
************************************************************************
[Error] - File could not be written...


c:\users\rocky\desktop\powershell books examples\windows powershell in action, second edition\finalcode\chapter16\running_exes.ps1
************************************************************************
#
# Windows PowerShell in Action
#
# Chapter 16 Utilities for running programs
#
# External programs don't understand PowerShell's 
# wildcard (globbing) syntax. These wraper functions
# are a way to work around those limitations.
#

function global:notepad {
    $args | %{ notepad.exe (Resolve-Path $_)/ProviderPath
}

function global:run-exe
{
    $cmd, $files = $args
    $cmd = (resolve-pat $path).ProviderPath
    $file | %{ & $cmd (Resolve-Path $_).ProviderPath }
}




c:\users\rocky\desktop\powershell books examples\windows powershell in action, second edition\finalcode\chapter16\Search-Help.ps1
************************************************************************
#
# Windows PowerShell in Action
#
# Chapter 16 The Search-Help function
#
# A function so search all of the PowerShell help doccuments
# looking for a specific pattern.
#

function global:Search-Help
{
    param ($pattern = $(throw "you must specify a pattern"))
    
    select-string -list $pattern $PSHome\about*.txt |
        %{$_.filename -replace '\..*$'}
   
    dir $PShome\*dll-help.*xml |
        %{ [xml] (get-content -read -1 $_) } |
        %{$_.helpitems.command} |
        ? {$_.get_Innertext() -match $pattern} |
        %{$_.details.name.trim()}
}




c:\users\rocky\desktop\powershell books examples\windows powershell in action, second edition\finalcode\chapter16\Select-Help.ps1
************************************************************************
#
# Windows PowerShell in Action
#
# Chapter 16 The Select-Help function
#
# A function that scans through the command file, searching
# for a particular word in either the command name or the short
# help description.
#

function global:Select-Help ($pat = ".")
{
    $cmdHlp="Microsoft.PowerShell.Commands.Management.dll-Help.xml"
    $doc = "$PSHOME\$cmdHlp"
    $settings = new-object System.Xml.XmlReaderSettings
    $settings.ProhibitDTD = $false
    $reader = [xml.xmlreader]::create($doc, $settings)
    $name = $null
    $capture_name = $false
    $capture_description = $false
    $finish_line = $false
    while ($reader.Read())
    {
        switch ($reader.NodeType)
        {
            ([Xml.XmlNodeType]::Element) {
                switch ($reader.Name)
                {
                    "command:name" {
                        $capture_name = $true
                        break
                    }
                    "maml:description" {
                        $capture_description = $true
                        break
                    }
                    "maml:para" {
                        if ($capture_description)
                        {
                            $finish_line = $true;
                        }
                    }
                }
                break
            }
            ([Xml.XmlNodeType]::EndElement) {
                if ($capture_name) { $capture_name = $false }
                if ($finish_description)
                {
                    $finish_line = $false
                    $capture_description = $false
                }
                break
            }
            ([Xml.XmlNodeType]::Text) {
                if ($capture_name)
                {
                    $name = $reader.Value.Trim()
                }
                elseif ($finish_line -and $name)
                {
                    $msg = $name + ": " + $reader.Value.Trim()
                    if ($msg -match $pat)
                    {
                        $msg
                    }
                    $name = $null
                }
                break
            }
        }
    }
    $reader.close()
}




c:\users\rocky\desktop\powershell books examples\windows powershell in action, second edition\finalcode\chapter16\Select-String_examples.ps1
************************************************************************
[Error] - File could not be written...


c:\users\rocky\desktop\powershell books examples\windows powershell in action, second edition\finalcode\chapter16\testscript.ps1
************************************************************************
[Error] - File could not be written...


c:\users\rocky\desktop\powershell books examples\windows powershell in action, second edition\finalcode\chapter16\tokenization.ps1
************************************************************************
#
# Windows PowerShell in Action
#
# Chapter 16 Tokenization example
#
# This code snippet shows how to tokenize and expression using
# the .NET regular expression class.
#

#
# Define a regular expression that matches numbers,
# operators or spaces
$pat = [regex] "[0-9]+|\+|\-|\*|/| +"

# Now start the match
$m = $pat.match("11+2 * 35 -4")

# While there are still matches, loop
# and print out each token...
while ($m.Success)
{
    $m.value
    $m = $m.NextMatch()
}




c:\users\rocky\desktop\powershell books examples\windows powershell in action, second edition\finalcode\chapter16\XML_Cmdlet_Examples.ps1
************************************************************************
[Error] - File could not be written...


c:\users\rocky\desktop\powershell books examples\windows powershell in action, second edition\finalcode\chapter16\xpath_examples.ps1
************************************************************************
[Error] - File could not be written...


c:\users\rocky\desktop\powershell books examples\windows powershell in action, second edition\finalcode\chapter17\Add-Type_examples.ps1
************************************************************************
[Error] - File could not be written...


c:\users\rocky\desktop\powershell books examples\windows powershell in action, second edition\finalcode\chapter17\graphic_user_interface_examples.ps1
************************************************************************
[Error] - File could not be written...


c:\users\rocky\desktop\powershell books examples\windows powershell in action, second edition\finalcode\chapter17\networking_examples.ps1
************************************************************************
[Error] - File could not be written...


c:\users\rocky\desktop\powershell books examples\windows powershell in action, second edition\finalcode\chapter17\search.ps1
************************************************************************
#
# Windows PowerShell in Action
#
# Chapter 17 Extending your reach with .NET
#
# A GUI for searching files. The UI itself is described
# by the file search.xaml.
#

[CmdletBinding()]
param (
   $Template = "search.xaml",
   $DirectoryToSeach = $pwd
)

Import-Module ./XamlTools.psm1

trap { break }
$form = Import-Xaml -Relative $template

if ( -not (Get-ControlContent $form Path))
{
    Set-ControlContent $form Path Text $pwd
}
Add-ControlAction $form Path -event TextChanged {
    $script:Path = $this.Text }
Add-ControlAction $form Browse {
  $fbd = New-Object System.Windows.Forms.FolderBrowserDialog
  $fbd.SelectedPath = $pwd
  if ($fbd.ShowDialog() -eq "OK")
  {
     Set-ControlContent $form Path Text ($fbd.SelectedPath)
  }
}

Set-ControlContent $form FileFilter Text "*.ps1"

Set-ControlContent $form UseRegex IsChecked $true

Add-ControlAction $form Run {
    $form.DialogResult = $true
    $form.Close()
}
  
Add-ControlAction $form Show {
    Write-Host (Get-CommandString)
}

Add-ControlAction $form SaveSearch {
    $dlg = New-Object Microsoft.Win32.SaveFileDialog -Property @{
       FileName = "NewSearchTemplate.xaml"
       InitialDirectory = Add-ScriptRoot ""
       DefaultExt = ".xaml";
       Filter = "Application |*.xaml";
       AddExtension = true;
       CheckFileExists = false;
    }

    if ($dlg.ShowDialog() -eq $true)
    {
        try
        {
            $fileName = $dlg.FileName
            $stream = [System.IO.File]::Open($filename, "OpenOrCreate")
            [System.Windows.Markup.XamlWriter]::Save($form, $stream)
        }
        finally
        {
            $stream.Close()
        }
    }
}

function Get-CommandString
{
  "Get-ChildItem '{0}' ``
    -Recurse: `${1} ``
    -Filter '{2}' |
      Select-String -SimpleMatch: `${3} ``
        -Pattern '{4}' ``
          -List: `${5}" -f 
      (Get-ControlContent $form Path Text),
      (Get-ControlContent $form Recurse IsChecked),
      (Get-ControlContent $form FileFilter Text),
      -not (Get-ControlContent $form UseRegex IsChecked),
      (Get-ControlContent $form TextPattern Text),
      (Get-ControlContent $form FirstOnly IsChecked)
}

if ($form.ShowDialog())
{
  $cmd = Get-CommandString
  Invoke-Expression $cmd
}




c:\users\rocky\desktop\powershell books examples\windows powershell in action, second edition\finalcode\chapter18\browserWindowList.ps1
************************************************************************
#
# Windows PowerShell in Action Second Edition
#
# Chapter 18 Using COM
#
# Script to build a GUI for browsing windows.
#

Add-Type -Assembly PresentationCore,PresentationFrameWork

trap { break }

$mode = [System.Threading.Thread]::CurrentThread.ApartmentState
if ($mode -ne "STA")
{
    throw "This script can only be run when powershell is started with -sta"
}

function Add-ScriptRoot ($file)
{
  $caller = Get-Variable -Value -Scope 1 MyInvocation
  $caller.MyCommand.Definition |
    Split-Path -Parent |
      Join-Path -Resolve -ChildPath $file
}

$xamlPath = Add-ScriptRoot browserWindowList.xaml
$stream = [System.IO.StreamReader] $xamlPath
$form = [System.Windows.Markup.XamlReader]::Load(
      $stream.BaseStream)
$stream.Close()

<#
$Path = $form.FindName("Path")
$Path.Text = $PWD

$FileFilter = $form.FindName("FileFilter")
$FileFilter.Text = "*.ps1"

$TextPattern = $form.FindName("TextPattern")
$Recurse = $form.FindName("Recurse")

$UseRegex = $form.FindName("UseRegex")
$UseRegex.IsChecked = $true

$FirstOnly = $form.FindName("FirstOnly")

$Run = $form.FindName("Run")
$Run.add_Click({
    $form.DialogResult = $true
    $form.Close()
  })
  
$Show = $form.FindName("Show")
$Show.add_Click({Write-Host (Get-CommandString)})

$Cancel = $form.FindName("Cancel")
$Cancel.add_Click({$form.Close()})

function Get-CommandString
{
  "Get-ChildItem $($Path.Text) ``
    -Recurse: `$$($Recurse.IsChecked) ``
    -Filter '$($FileFilter.Text)' |
      Select-String -SimpleMatch: `(! `$$($UseRegex.IsChecked)) ``
        -Pattern '$($TextPattern.Text)' ``
        -List: `$$($FirstOnly.IsChecked)"
}

#>

$BWLisr = $form.FindName("bwList")
foreach ($i in gps | out-string -stream)
{
  $BWLisr.Items.Add($i)
}

if ($form.ShowDialog())
{
  $cmd = Get-CommandString
  Invoke-Expression $cmd
}




c:\users\rocky\desktop\powershell books examples\windows powershell in action, second edition\finalcode\chapter18\Call-JScript.ps1
************************************************************************
#
# Windows PowerShell in Action Second Edition
#
# Chapter 18 Using COM
#
# Demonstrate using COM to call JScript from PowerShell
#

function Call-JScript
{
    $sc = New-Object -ComObject ScriptControl
    $sc.Language = 'JScript'
    $sc.AddCode('
	function getLength(s)
        {
	    return s.length
	}
	function Add(x, y)
        {
	    return x + y
	}
    ')
    $sc.CodeObject
}

$js = Call-JScript
"Length of 'abcd' is " + $js.getlength("abcd")
"2 + 5 is $($js.add(2,5))"



c:\users\rocky\desktop\powershell books examples\windows powershell in action, second edition\finalcode\chapter18\Call-VBScript.ps1
************************************************************************
#
# Windows PowerShell in Action Second Edition
#
# Chapter 18 Using COM
#
# Demonstrate using COM to call VBScript from PowerShell
#

function Call-VBScript
{
    $sc = New-Object -ComObject ScriptControl
    $sc.Language = 'VBScript'
    $sc.AddCode('
	Function GetLength(ByVal s)
	    GetLength = Len(s)
	End Function
	Function Add(ByVal x, ByVal y)
	    Add = x + y
	End Function
    ')
    $sc.CodeObject
}

$vb = Call-VBScript
"Length of 'abcd' is " + $vb.getlength("abcd")
"2 + 5 is $($vb.add(2,5))"



c:\users\rocky\desktop\powershell books examples\windows powershell in action, second edition\finalcode\chapter18\define_Export-Windows_function.ps1
************************************************************************
#
# Windows PowerShell in Action
#
# Chapter 18 Defines a set of functions for saving
#            and loading a set of web pages,
#

Set-Alias gbw Get-BrowserWindow
function Get-BrowserWindow
{
  <#
   .SYNOPSIS
    A function to list and show browser windows
    .DESCRIPTION
    This funciton allows you to get a list of all open
    browser windows. This list can be filtered with a regular
    expression and the matching windows can be shown.
    #>

  [CmdletBinding(DefaultParameterSetName="full")]
  param (
    <#
    .PARAMETER Pattern
    Pattern to search for in the window titles
   #>
   [Parameter(Position=0)]
     $Pattern = ".",
    <# Return the full window object instead of just the title #>
   [Parameter(ParameterSetName="full")]
     [switch] $Full,
   <# Show the window whose title matched the pattern #>
   [Parameter(ParameterSetName="show")]
     [switch] $Show,
   <# Show the window whose title matched the pattern #>
   [Parameter(ParameterSetName="minimize")]
     [switch] $Minimize,
     <# Display the list of matching pages in a GUI #>
   [Parameter(ParameterSetName='gui')]
     [switch] $Gui,
   <# Show the window whose title matched the pattern #>
   [Parameter(ParameterSetName="close")]
     [switch] $Close

  )
     
  Add-Type -Namespace WPIA -Name WindowUtils  `
    -MemberDefinition @'
      [DllImport("user32.dll")]
      public static extern bool ShowWindow(
        IntPtr hWnd, Int32 nCmdShow);
'@
  
  $shell = New-Object -com Shell.Application
  foreach ($window in $shell.Windows())
  {
    if ($window.Name -match 'Internet' -and
      $window.LocationName -match $pattern)
    {
      $hwnd = $window.HWND
      $MinimizeWindow = 6
      $RestoreWindow = 9
      
      if ($Show)
      {
        [void] [WPIA.WindowUtils]::ShowWindow($hwnd,
          $MinimizeWindow)
        [void] [WPIA.WindowUtils]::ShowWindow($hwnd,
          $RestoreWindow)
      }
      elseif ($Minimize)
      {
        [void] [WPIA.WindowUtils]::ShowWindow($hwnd,
          $MinimizeWindow)
      }
      elseif ($Close)
      {
        $window.Quit()
      }
      else
      {
        if ($Full)
        {
          $window
        }
        else
        {
          $window.LocationName
        }
      }
    }
  }
}

function global:Export-Windows
{
    param($file=(Join-Path (Resolve-Path ~/*documents) saved-urls.ps1))

    $shell = New-Object -ComObject Shell.Application

    $title = $null
    $shell.Windows() | % {
        if (! $title)
        {
            $title = $_.LocationName
        }
        else
        {
            @"
@{
    title='$($_.LocationName -replace "'","''")'
    url='$($_.LocationUrl -replace "'","''")'
}

"@
                $title = $null
        }
    } | out-file -width 10kb -filepath $file -encoding unicode
}

function global:Get-Windows
{
    param($file=(Join-Path (Resolve-Path ~/*documents) saved-urls.ps1))

    & $file
}
        
function global:Import-Windows
{
    param(
        $File = (Join-Path (Resolve-Path ~) saved-urls.ps1),
        [switch] $show
    )

    & $file | foreach {
        if ($Show)
        {
            explorer $_.url
        }
        else
        {
            $_
        }
    }
}



c:\users\rocky\desktop\powershell books examples\windows powershell in action, second edition\finalcode\chapter18\Get-ProgID.ps1
************************************************************************
#
# Windows PowerShell in Action Second Edition
#
# Chapter 18 Using COM
#
# This script defines two different functions for
# showing the COM ProgIDs that are available on the
# system.
#
function global:Get-ProgID1 {
    param ($filter = '.')

    $ClsIdPath = "REGISTRY::HKey_Classes_Root\clsid"
    dir -recurse $ClsIdPath |
        % {if ($_.name -match '\\ProgID$') { $_.GetValue("") }} |
        ? {$_ -match $filter}
}

function global:Get-ProgID2 {
    param ($filter = '.')

    Get-WMIObject Win32_ProgIDSpecification |
        select-object ProgID,Description |
        ? {$_.ProgId -match $filter}
}




c:\users\rocky\desktop\powershell books examples\windows powershell in action, second edition\finalcode\chapter18\Get-Spelling.ps1
************************************************************************
#
# Windows PowerShell in Action Second Edition
#
# Chapter 18 Use COM and Word to spell-check a document
#

if ($args.count -gt 0)
{
@"
Usage for Get-Spelling:

Copy some text into the clipboard, then run this script. It
will display the Word spellcheck tool that will let you
correct the spelling on the text you've selected. When you are
done it will put the text back into the clipboard so you can
paste it back into the original document.

"@
    exit 0
}

$shell = new-object -com wscript.shell

# set up Word for our use...
$word = new-object -com word.application
$word.Visible = $false
$doc = $word.Documents.Add()
    
# Copy the contents of the clipboard to Word
$word.Selection.Paste()
    
# See if we need to spell check the text.
# If we do, present the user with the spellcheck dialog,
# otherwise, we do not need to do anything
if ($word.ActiveDocument.SpellingErrors.Count -gt 0)
{
    # Perform the spellcheck
    $word.ActiveDocument.CheckSpelling()
    $word.Visible = $false

    # Select all of the text for copy back to clipboard
    $word.Selection.WholeStory()
    $word.Selection.Copy()
    $shell.PopUp( "The spell check is complete, " +
        "the clipboad holds the corrected text." )
}
else
{
    [void] $shell.Popup("No Spelling Errors were detected.")
}

$x = [ref] 0 
$word.ActiveDocument.Close($x)
$word.Quit()




c:\users\rocky\desktop\powershell books examples\windows powershell in action, second edition\finalcode\chapter18\Get-WordDefinition.ps1
************************************************************************
#
# Windows PowerShell in Action Second Editoin
#
# Chapter 18 Using COM
#
# This script uses COM and Internet Explorer to
# look up a word in the Wiktionary.

param(
    $word = $(throw "You must specify a word to look up."),
    [switch] $visible
)

[void] [Reflection.Assembly]::LoadWithPartialName("System.Web")

$ie = new-object -com "InternetExplorer.Application"

$ie.Visible = $visible

$ie.Navigate2("http://en.wiktionary.org/wiki/" +
    [Web.HttpUtility]::UrlEncode($word))

while($ie.ReadyState -ne 4) 
{ 
     start-sleep 1
} 

$bodyContent = $ie.Document.getElementById("bodyContent").innerHtml

$showText=$false
$lastWasBlank = $true
$gotResult = $false

switch -regex ($bodyContent.Split("`n"))
{
'^\<DIV class=infl-table' {
        $showText = $true
        continue
    }
'^\<DIV|\<hr' {
        $showText = $false
    }
'\[.*edit.*\].*Translations' {
        $showText = $false
    }
{$showText} {
        $line = $_ -replace '\<[^>]+\>', ' '
        $line = ($line -replace '[ \t]{2,}', ' ').Trim()
 
        if ($line.Length)
        {
            $line
            $gotResult = $true
            $lineWasBlank = $false
        }
        else
        {
            if (! $lineWasBlank)
            {
                $line
                $lineWasBlank = $true
            }
        }
    }
}

if (! $gotResult)
{
    "No Answer Found for: $word"
}

if (! $visible)
{
    $ie.Quit()
}




c:\users\rocky\desktop\powershell books examples\windows powershell in action, second edition\finalcode\chapter18\Release-ComObject.ps1
************************************************************************
#
# Windows PowerShell in Action, Second Edition
#
# Chapter 18 Using COM
#
# PowerShell Simple script to release a COM object.
#
# This script illustrates how to explicitly release a COM object.
# Although the memory manager will eventually release
# the object for you when it is garbage-collected, that
# may not happen for some significant amount of time.
# By calling this script on the object, the underlying COM
# object will be released immediately and it's resources
# will be freed.

param ($objectToRelease)
[void][System.Runtime.Interopservices.Marshal]::ReleaseComObject(
    $objectToRelease)



c:\users\rocky\desktop\powershell books examples\windows powershell in action, second edition\finalcode\chapter18\task_scheduler_examples.ps1
************************************************************************
#
# Windows PowerShell in Action Second Editoin
#
# Chapter 18 Using COM
#
# This file contains examples showing how to work with the task
# schedule using its COM interfaces

# Get the scheduler service object...
$ts = New-Object -ComObject Schedule.Service
$ts | Get-Member
$ts.Connect()
$ts.GetRunningTasks(0)

# create a new task
$nt = $ts.NewTask(0)
$ri = $nt.RegistrationInfo
$ri.Description = "Start the calculator in 5 minutes"
$ri.Author = "Bruce Payette"

# Set the logon type to interactive logon
$principal = $nt.Principal
$principal.LogonType = 3

# $settings = $nt.Settings
# $settings.DeleteExpiredTaskAfter = $true

# time trigger is 1
$trigger = $nt.Triggers.Create(1)

function XmlTime ([datetime] $d)
{
  $d.ToUniversalTime().ToString("u") -replace " ","T"
}

$trigger.StartBoundary = XmlTime ((Get-Date).AddSeconds(30))
$trigger.EndBoundary = XmlTime ((Get-Date).AddMinutes(5))
$trigger.ExecutionTimeLimit = "PT1M"    # Five minutes
$trigger.Id = "Trigger in 30 seconds"
$trigger.Enabled = $true

# define the action to perform: start the calculator
$action = $nt.Actions.Create(0)
$action.Path =  @(Get-Command calc)[0].Definition

# root folder that holds registered tasks
$tsFolder = $ts.GetFolder("\")

# get the credentials for the job
$cred = Get-Credential

$tsFolder.RegisterTaskDefinition(
  "PowerShellTimeTriggerTest", $nt, 6,
    $cred.UserName,
      $cred.GetNetworkCredential().PassWord, 3)







c:\users\rocky\desktop\powershell books examples\windows powershell in action, second edition\finalcode\chapter19\codecs1.ps1
************************************************************************
#
# Windows PowerShell in Action
#
# Chapter 19 PowerShell script to list codecs. In this example
# we're going to create a VBScript function to convert the dates
# instead of using the default script method to illustrate using
# VBScript as a callable library from PowerShell
#

$code = @'
Function WMIDateStringToDate(dtmDate)
    WMIDateStringToDate = CDate(Mid(dtmDate, 5, 2) & "/" & _
        Mid(dtmDate, 7, 2) & "/" & Left(dtmDate, 4) _
            & " " & Mid (dtmDate, 9, 2) & ":" & _
                Mid(dtmDate, 11, 2) & ":" & Mid(dtmDate, _
                    13, 2))
End Function
'@

$vbs = new-object -com ScriptControl 
$vbs.language = 'vbscript' 
$vbs.AllowUI = $false
$vbs.addcode($code)
$vdr = $vbs.CodeObject.WMIDateStringToDate

get-wmiobject Win32_CodecFile |
    %{ $_ | fl Manufacturer, Name, Path, Version, Caption,
        Drive, Extension, FileType, Group,
        @{l="Creation Date"
            e={$vdr.Invoke($_.CreationDate)}},
        @{l="Install Date"
            e={$vdr.Invoke($_.InstallDate)}},
        @{l="Last Modified Date"
            e={$vdr.Invoke($_.LastModified)}} }




c:\users\rocky\desktop\powershell books examples\windows powershell in action, second edition\finalcode\chapter19\codecs2.ps1
************************************************************************
#
# Windows PowerShell in Action Second Edition
#
# Chapter 19 PowerShell script to list codecs. Note the use
# of the ConvertToDateTime ScriptMethod on the object 
#

get-wmiobject Win32_CodecFile |
    %{ $_ | fl Manufacturer, Name, Path, Version, Caption,
        Drive, Extension, FileType, Group,
        @{l="Creation Date"
            e={ $_.ConvertToDateTime( $_.CreationDate ) }},
        @{l="Install Date"
            e={ $_.ConvertToDateTime($_.InstallDate )}},
        @{l="Last Modified Date"
            e={ $_.ConvertToDateTime( $_.LastModified ) }} }




c:\users\rocky\desktop\powershell books examples\windows powershell in action, second edition\finalcode\chapter19\wmi_examples.ps1
************************************************************************
#
# Windows PowerShell in Action Second Edition
#
# Chapter 19 WMI and WSMan
#
# THe file contains examples showing how to use WMI from PowerShell
#

Get-WmiObject -Class Win32_BIOS `
     -Namespace "root\cimv2"

Get-WmiObject -ComputerName brucepayx61 `
   -Namespace "root\cimv2" -Class Win32_BIOS `
   -Credential redmond\brucepay

Get-WmiObject Win32_NetworkAdapterConfiguration |
  where { $_.DHCPEnabled } |
    Format-List Description, IPAddress, DHCPLeaseExpires

Get-WmiObject Win32_NetworkAdapterConfiguration |
  where { $_.DHCPEnabled } |
    Format-List Description, IPAddress,
     @{
       n = "DHCPLeaseExpires"
       e = {$_.ConvertToDateTime($_.DHCPLeaseExpires)}}

Get-WmiObject Win32_NetworkAdapterConfiguration `
  -Filter  'DHCPEnabled = TRUE' |
    Format-List Description, IPAddress

Get-WmiObject Win32_NetworkAdapterConfiguration `
  -Filter 'DHCPEnabled = TRUE AND Description LIKE "%wire%"' |
    Format-List Description, IPAddress

Get-WmiObject Win32_NetworkAdapterConfiguration `
  -Filter 'DHCPEnabled = TRUE AND NOT (Description LIKE "%wire%")' |
    Format-List Description, IPAddress
 
Get-WmiObject Win32_NetworkAdapterConfiguration |
 where {$_.DHCPEnabled -eq $true -and -not
   ($_.Description -like "*wire*")} |
     Format-List Description, IPAddress

Get-WmiObject Win32_NetworkAdapterConfiguration |
 where {$_.DHCPEnabled -and ($_.Description -notlike "*wire*")} |
     Format-List Description, IPAddress
     
Get-WmiObject -Namespace root\microsoft  __Namespace |
select name

Get-WmiObject -Query @'
  SELECT Description,IPAddress
  FROM Win32_NetworkAdapterConfiguration
  WHERE DHCPEnabled = TRUE AND NOT (Description LIKE "%wire%")
'@

Get-WmiObject -Query @'
  SELECT *
  FROM Win32_Service
  WHERE Name LIKE "%zune%"
'@ | Format-List Name, StartMode, Status, __PATH

############################################
# Set-WmiInstance examples

$class = Get-WmiObject -list Win32_Process
$p = $class.Properties | where { $_.Name -eq "Handle" }
$p
$p.Qualifiers.Keys
$p.Qualifiers["key"]
$class.Properties |
  where { $_.Qualifiers["key"]} |
    Format-Table -AutoSize name, type

(Get-WmiObject -List Win32_Environment).Properties |
  where { $_.Qualifiers["key"]} |
    Format-Table -AutoSize name, type
  
############################################
# Set-WmiInstance examples

$path = 'HKLM:\System\CurrentControlSet\Control\Session Manager\Environment'
Set-ItemProperty -Path $path `
  -Name 'TestProperty' -Value '3.14'
  
Get-ItemProperty -Path $path -Name TestProperty
Get-WmiObject -Class Win32_Environment `
  -Filter 'Name = "TestProperty"' |
    Format-List Name,VariableValue,__PATH
    
$vPath = 
'\\.\root\cimv2:Win32_Environment.Name="TestProperty",UserName="<SYSTEM>"'

Set-WmiInstance -Path $vPath `
  -Arguments @{VariableValue = "Hello"}
  
Get-WmiObject -Class Win32_Environment `
  -Filter 'Name = "TestProperty"' |
    Format-List Name,VariableValue,__PATH

Set-WmiInstance -Class win32_environment `
  -Arguments @{
    Name="TestProperty"
    VariableValue="Bye!"
    UserName="<SYSTEM>"
  }
  
Set-WmiInstance -Class win32_environment `
  -Arguments @{
    Name="TestProperty2"
    VariableValue="Bye!"
    UserName="<SYSTEM>"
  } | Format-List Name,VariableValue,__PATH


$v2Path = 
'\\.\root\cimv2:Win32_Environment.Name="tp2",UserName="<SYSTEM>"'

Set-WmiInstance -Path $v2Path `
  -Arguments @{VariableValue = "Hello"}

Get-WmiObject Win32_Environment `
  -Filter 'name = "tp2"'

Get-WmiObject Win32_Environment `
  -Filter 'VariableValue = "Bye!"'


###########################
# Invoke-WmiMethod

$result = Invoke-WmiMethod Win32_Process `
  -Name Create -ArgumentList calc

$result.GetType().FullName
$result | Format-Table ProcessId, ReturnValue

$proc = Get-WmiObject -Query @"
SELECT __PATH, Handle
FROM Win32_PROCESS
WHERE ProcessId = $($result.ProcessID)
"@ 

$proc | Get-Member -MemberType Method
$proc | Format-List __PATH

Invoke-WmiMethod -Path $proc.__PATH `
  -Name Terminate -Argument 0

Invoke-WmiMethod -Path $proc.__PATH `
  -Name Terminate -Argument (0) |
     select -First 1 -Property '[a-z]*'

#######################
#
# Remove-WmiObject

calc
$proc = Get-WmiObject -Query @"
SELECT __PATH, Handle
FROM Win32_PROCESS
WHERE Name='calc.exe'
"@ 

Remove-WmiObject -Path $proc.__PATH

Get-WmiObject -Class Win32_Environment `
  -Filter 'Name = "TestProperty"' |
    Format-List Name,VariableValue,__PATH

Get-WmiObject -Class Win32_Environment `
  -Filter 'Name = "TestProperty"' |
    Remove-WmiObject
 
Get-WmiObject -Class Win32_Environment `
 -Filter 'Name = "TestProperty"' |
   Format-List Name,VariableValue,__PATH
    
#######################
# Accelerators
calc
$s = [WmiSearcher] `
'Select * from Win32_Process where Name = "calc.exe"'

$so =  $s.Get() | Write-Output
$proc = [WMI] $so.__PATH
$proc.Name
$proc.HandleCount
$proc.Terminate()

$c = [WMICLASS]"Win32_Process"
$c | Get-Member -MemberType method | Format-List
$c.Create("notepad.exe") |
  Format-Table ReturnValue, ProcessId
  
Get-WmiObject Win32_Process `
  -Filter 'Name = "notepad.exe"' |
    Format-Table Name, Handle


Get-WmiObject -List -Class *datetime*

function Get-WmiCLassInfo ($class)
{
  filter Format-Property
  {
    $prop = $_
    [string] $fs = ""
    $fs = $prop.Type
    if ($prop.IsArray)
    {
      $fs += '[]'
    }
    $fs += " " + $prop.Name
    $fs += ' {'
    if ( $prop.Qualifiers["read"] -and $prop.Qualifiers["read"].Value)
    {
      $fs += ' get;'
    }
    if ( $prop.Qualifiers["write"].Value -and $prop.Qualifiers["write"].Value)
    {
      $fs += ' set;'
    }
    $fs += '}'
    $fs
    $prop.Qualifiers
  }
  $info = Get-WmiObject -Query "SELECT * FROM meta_class WHERE __this ISA '$class'"
  "Name: " + $info.Name | fl -force *
  "Methods:"
  $info.Methods | Format-Table -auto Name,InParameters,OutParameters
  "Properties:"
  $info.Properties | Format-Property
}

Get-WmiCLassInfo Win32_LogicalDisk

Get-WmiObject -Namespace root -Recurse -List `
 -Class *power* | Format-Table __PATH

# Filtering the objects returned

Get-WmiObject -Class Win32_Service `
 -Filter 'Name = "TermService"' |
   Format-Table __PATH
   



c:\users\rocky\desktop\powershell books examples\windows powershell in action, second edition\finalcode\chapter19\WmiCreatestance.ps1
************************************************************************
[Error] - File could not be written...


c:\users\rocky\desktop\powershell books examples\windows powershell in action, second edition\finalcode\chapter19\wsman_examples.ps1
************************************************************************
[Error] - File could not be written...


c:\users\rocky\desktop\powershell books examples\windows powershell in action, second edition\finalcode\chapter20\eventing_examples.ps1
************************************************************************
[Error] - File could not be written...


c:\users\rocky\desktop\powershell books examples\windows powershell in action, second edition\finalcode\chapter20\Remote-EventLogEvent.ps1
************************************************************************
[Error] - File could not be written...


c:\users\rocky\desktop\powershell books examples\windows powershell in action, second edition\finalcode\chapter20\wmi_event_examples.ps1
************************************************************************
[Error] - File could not be written...


c:\users\rocky\desktop\powershell books examples\windows powershell in action, second edition\finalcode\chapter21\Safe_Add-Path_function.ps1
************************************************************************
#
# Windows PowerShell in Action, Second Edition
#
# Chapter 21 Security, security, security
#
# Define a safe AddPath function
#
function global:Add-Path
{
    param (
        [string]$path = (write-error `
            "Usage: add-path [-path] path [[-scope] {System | User}] [-save]"),
        [string]$scope = "User",
        [switch]$save
    )
    
    $AvailScopes = "System", "User"
    if ($AvailScopes -notcontains $scope)
    {
        $OFS=","
        write-error ("$scope is an unknown value for scope. " +
            "Please specify one of these values: $AvailScopes.")
        return
    }
    
    $wsh = new-object -com wscript.shell
    $pathTable = @{}
    $AvailScopes | % {$pathTable[$_] = $wsh.Environment($_).Item("Path")}
    $PathTable[$scope] += ";$path"
    $env:path = "$($pathTable['System']);$($pathTable['User'])"
    
    if ($save)
    {
        $wsh.Environment($scope).Item("Path") = $pathTable[$scope]
    }
} 



c:\users\rocky\desktop\powershell books examples\windows powershell in action, second edition\finalcode\chapter21\Safe-Wheres.ps1
************************************************************************
#
# Windows PowerShell in Action, Second Edition
#
# Chapter 21 Security, security, security
#
# Define a safe Wheres function
#

function global:Wheres
{
    begin {
        if ($args.count -ne 3)
        {
            throw "wheres: syntax <prop> <op> <val>"
        }
        $prop,$op,$y= $args
        $op_fn = $(
            switch ($op)
            {
                eq {{$x.$prop -eq $y}; break}
                ne {{$x.$prop -ne $y}; break}
                gt {{$x.$prop -gt $y}; break}
                ge {{$x.$prop -ge $y}; break}
                lt {{$x.$prop -lt $y}; break}
                le {{$x.$prop -le $y}; break}
                like {{$x.$prop -like $y}; break}
                notlike {{$x.$prop -notlike $y}; break}
                match {{$x.$prop -match $y}; break}
                notmatch {{$x.$prop -notmatch $y}; break}
                default {
                    throw "wh: operator '$op' is not defined"
                }
            }
        )
    }
    process { $x=$_; if( . $op_fn) { $x }}
}



