#
# ATEM Legato Stream Deck controler
#
# By Ian Morrish
# https://ianmorrish.wordpress.com
#

# Disable display and sleep mode timeouts
function DisableSleepTimeout {
	Write-Host "Disabling display and sleep mode timeouts..."
	powercfg /X monitor-timeout-ac 0
	powercfg /X monitor-timeout-dc 0
	powercfg /X standby-timeout-ac 0
	powercfg /X standby-timeout-dc 0
}
DisableSleepTimeout

# Enable display and sleep mode timeouts
Function EnableSleepTimeout {
	Write-Host "Enabling display and sleep mode timeouts..."
	powercfg /X monitor-timeout-ac 10
	powercfg /X monitor-timeout-dc 5
	powercfg /X standby-timeout-ac 30
	powercfg /X standby-timeout-dc 15
}
#
# assume all DLL's are in documents/windowspowershell directory
Set-Location $env:USERPROFILE\documents
#region ATEM Setup
#Get the ATEM IP from registry key created by ATEM Software Control panel
Try{
$ATEMipAddress = (Get-ItemProperty -path 'HKCU:\Software\Blackmagic Design\ATEM Software Control').ipAddress
add-type -path 'windowspowershell\SwitcherLib.dll'
$Global:atem = New-Object SwitcherLib.Switcher($ATEMipAddress)
$atem.Connect()
}
catch{
write-host "Can't connect to ATEM on $($ATEMipAddrss)."
Write-Host "ATEM controle software must be installed and have connected to switcher at least one time"
Write-Host "switcherlib.dll and StreamDeckSharp.dll must be in [user]\documents\WindowsPowerShell"
}
$me=$atem.GetMEs()
$Global:me1=$me[0]
$Global:activeME = $me1
$Global:Program = $activeME.Program
$Global:Preview = $activeME.Preview

$MediaPlayers = $atem.GetMediaPlayers()
$Global:MP1=$MediaPlayers[0]
$Global:MP2=$MediaPlayers[1]

$USKs = $atem.GetKeys()
$Global:Key1 = $USKs[0]
#endregion

#region Stream Deck setup
add-type -path 'WindowsPowerShell\StreamDeckSharp.dll'
$deckInterface = [StreamDeckSharp.StreamDeck]::OpenDevice()

#$deckInterface | Get-Member
#$deckInterface.KeyCount
#$deckInterface.NumberOfKeys
#$deckInterface.ShowLogo()
#$imgBlack = [StreamDeckSharp.KeyBitmap]::Black # KeyBitmap.FromGraphics
#$imgRed = [StreamDeckSharp.KeyBitmap]::FromRGBColor([byte]255,[byte]0,[byte]0)
#$deckInterface.SetKeyBitmap(2, $imgRed)

$buttonMapping = @(9,8,7,6,14,13,12,11)

$imgCut = [StreamDeckSharp.KeyBitmap]::FromFile(".\Pictures\icon\Cut.png")
$imgFade = [StreamDeckSharp.KeyBitmap]::FromFile(".\Pictures\icon\Fade.png")
$imgCrop = [StreamDeckSharp.KeyBitmap]::FromFile(".\Pictures\icon\Crop.png")
$imgMacro = [StreamDeckSharp.KeyBitmap]::FromFile(".\Pictures\icon\Macro.png")
$imgMedia = [StreamDeckSharp.KeyBitmap]::FromFile(".\Pictures\icon\Media.png")
$imgResize = [StreamDeckSharp.KeyBitmap]::FromFile(".\Pictures\icon\Resize.png")
$1Label = [StreamDeckSharp.KeyBitmap]::FromFile(".\Pictures\icon\1White.png")
$1Active = [StreamDeckSharp.KeyBitmap]::FromFile(".\Pictures\icon\1Red.png")
$1Preview = [StreamDeckSharp.KeyBitmap]::FromFile(".\Pictures\icon\1Green.png")
$2Label = [StreamDeckSharp.KeyBitmap]::FromFile(".\Pictures\icon\2White.png")
$2Active = [StreamDeckSharp.KeyBitmap]::FromFile(".\Pictures\icon\2Red.png")
$2Preview = [StreamDeckSharp.KeyBitmap]::FromFile(".\Pictures\icon\2Green.png")
$3Label = [StreamDeckSharp.KeyBitmap]::FromFile(".\Pictures\icon\3White.png")
$3Active = [StreamDeckSharp.KeyBitmap]::FromFile(".\Pictures\icon\3Red.png")
$3Preview = [StreamDeckSharp.KeyBitmap]::FromFile(".\Pictures\icon\3Green.png")
$4Label = [StreamDeckSharp.KeyBitmap]::FromFile(".\Pictures\icon\4White.png")
$4Active = [StreamDeckSharp.KeyBitmap]::FromFile(".\Pictures\icon\4Red.png")
$4Preview = [StreamDeckSharp.KeyBitmap]::FromFile(".\Pictures\icon\4Green.png")
$5Label = [StreamDeckSharp.KeyBitmap]::FromFile(".\Pictures\icon\5White.png")
$5Active = [StreamDeckSharp.KeyBitmap]::FromFile(".\Pictures\icon\5Red.png")
$5Preview = [StreamDeckSharp.KeyBitmap]::FromFile(".\Pictures\icon\5Green.png")
$6Label = [StreamDeckSharp.KeyBitmap]::FromFile(".\Pictures\icon\6White.png")
$6Active = [StreamDeckSharp.KeyBitmap]::FromFile(".\Pictures\icon\6Red.png")
$6Preview = [StreamDeckSharp.KeyBitmap]::FromFile(".\Pictures\icon\6Green.png")
$7Label = [StreamDeckSharp.KeyBitmap]::FromFile(".\Pictures\icon\7White.png")
$7Active = [StreamDeckSharp.KeyBitmap]::FromFile(".\Pictures\icon\7Red.png")
$7Preview = [StreamDeckSharp.KeyBitmap]::FromFile(".\Pictures\icon\7Green.png")
$8Label = [StreamDeckSharp.KeyBitmap]::FromFile(".\Pictures\icon\8White.png")
$8Active = [StreamDeckSharp.KeyBitmap]::FromFile(".\Pictures\icon\8Red.png")
$8Preview = [StreamDeckSharp.KeyBitmap]::FromFile(".\Pictures\icon\8Green.png")
$POSH = [StreamDeckSharp.KeyBitmap]::FromFile(".\Pictures\icon\PowerShell72x72.png")
#$cmdMode1Buttons
$cmdMode2Switcher = [StreamDeckSharp.KeyBitmap]::FromFile(".\Pictures\icon\switcher.png")
$cmdMode2Pictures = [StreamDeckSharp.KeyBitmap]::FromFile(".\Pictures\icon\Pictures-WF.png")
$cmdMode2Audio = [StreamDeckSharp.KeyBitmap]::FromFile(".\Pictures\icon\Audio-Mixer.png")
$cmdMode2Camera = [StreamDeckSharp.KeyBitmap]::FromFile(".\Pictures\icon\camera-settings.png")

$ButtonInit = @($POSH,$imgMacro,$imgMedia,$imgCrop,$imgResize,`
                $imgFade,$4Label,$3Label,$2Label,$1Label,`
                $imgCut,$8Label,$7Label,$6Label,$5Label
)
$ProgramButtons = @($1Active,$2Active,$3Active,$4Active,$5Active,$6Active,$7Active,$8Active)
$PreviewButtons = @($1Preview,$2Preview,$3Preview,$4Preview,$5Preview,$6Preview,$7Preview,$8Preview)
$BlankButtons = @($1Label,$2Label,$3Label,$4Label,$5Label,$6Label,$7Label,$8Label)
$cmdMode1Buttons =@($POSH,$imgMacro,$imgMedia,$imgCrop,$imgResize)
$cmdMode2Buttons = @($POSH,$cmdMode2Camera,$cmdMode2Audio,$cmdMode2Pictures,$cmdMode2Switcher)

$deckInterface.SetBrightness(90)

#load initial images
for ($i = 0; $i -lt $deckInterface.KeyCount; $i++){
    $deckInterface.SetKeyBitmap($i, $ButtonInit[$i])
}
#endregion

$global:cmdMode = 1
#region set active program and preview
if($Global:Program -gt 0 -And $Global:Program -lt 8){
    #turn on new program led
    $deckInterface.SetKeyBitmap($buttonMapping[$Global:Program-1],$ProgramButtons[$Global:Program-1])
}
if($Global:Preview -gt 0 -And $Global:Preview -lt 8){
      #turn on new Preview led
      $deckInterface.SetKeyBitmap($buttonMapping[$Global:Preview-1],$PreviewButtons[$Global:Preview-1])
}
#endregion
#region Utilities
function USKAutoTransition(){
        $me1.TransitionSelection=2
        Start-Sleep -Milliseconds 1
        $me1.AutoTransition()
        Start-Sleep -Milliseconds 10 #give it a chance to start
        Start-Sleep 2
        #Key is now onair so remove from next transition (Turn on BKGD)
        $me1.TransitionSelection=1 
}
#This changes what the top row does. You can add more modes, and button sets to support them.
function ToggleCommands(){
$global:cmdMode = $global:cmdMode+1
    if($global:cmdMode -eq 3){$global:cmdMode=1}
    switch($global:cmdMode){
        1{
            for ($i = 0; $i -lt 5; $i++){
                $deckInterface.SetKeyBitmap($i, $cmdMode1Buttons[$i])
            }
        }
        2{
            for ($i = 0; $i -lt 5; $i++){
                $deckInterface.SetKeyBitmap($i, $cmdMode2Buttons[$i])
            }
        }
        3{}

    }
}
#endregion
# Key down actions
function inputevent($key){
    if($key.IsDown)
        {
        switch($key.key)
            {
                5{$Global:me1.AutoTransition()}
                10{$Global:me1.Cut()}
                4{
                    if($global:cmdMode -eq 2){
                        [Clicker]::LeftClickAtPoint(1641/2, 1723/2)
                    } 
                    else{
                        if($Global:key1Position -eq "fullScreen"){$Global:Key1.FlyRunToKeyFrame =[SwitcherLib.enumFlyKeyFrameDestination ]::FlyKeyFrameInfinityBottomRight;$Global:key1Position = "offscreen"}
                        else{
                            $Global:Key1Type = "DVE"
                            $Global:Key1.FlyRunToKeyFrame =[SwitcherLib.enumFlyKeyFrameDestination ]::FlyKeyFrameFull
                            $Global:Key1.OnAir = 1
                            $Global:key1Position = "fullScreen"
                        }
                    }
                }
                3{
                    if($global:cmdMode -eq 2){
                        [Clicker]::LeftClickAtPoint(1749/2, 1723/2)
                    } 
                    else{
                        if($Global:Key1.OnAir -eq 1){$Global:Key1.OnAir =0}
                        else{
                            $Global:Key1.Type = "DVE"
                            setPIPWindow $topLeft
                            $Global:Key1.OnAir = 1
                        }
                    }
                }
                2{
                    if($global:cmdMode -eq 2){
                        [Clicker]::LeftClickAtPoint(1862/2, 1725/2)
                    } 
                    else{$me1.Preview=3010}
                }
                1{
                    if($global:cmdMode -eq 2){
                        [Clicker]::LeftClickAtPoint(1973/2, 1723/2)
                    } 
                    else{$atem.RunMacro(0)}
                }
                0{ToggleCommands}
                9{$me1.Preview=1}
                8{$me1.Preview=2}
                7{$me1.Preview=3}
                6{$me1.Preview=4}
                14{$me1.Preview=5}
                13{$me1.Preview=6}
                12{$me1.Preview=7}
                11{$me1.Preview=8}
            }
        }
}

Function Commands($cmdID){

}
#Set up key event

Unregister-Event -SourceIdentifier buttonPress -ErrorAction SilentlyContinue #incase we are re-running the script
$KeyEvent = Register-ObjectEvent -InputObject $deckInterface -EventName KeyStateChanged -SourceIdentifier buttonPress -Action {inputevent($eventArgs)}

# $KeyEvent = Register-ObjectEvent -InputObject $deckInterface -EventName KeyStateChanged -SourceIdentifier buttonPress -Action {write-host $eventArgs.key}
# used to be event KeyPressed
#endregion
#region Timer
$timer = New-Object System.Timers.Timer
$timer.Interval = 100 
$timer.AutoReset = $true
$sourceIdentifier = "TimerJob"
function timerAction() { 
    #update leds
    #Program
    $CurrentProgram = $Global:activeME.Program
    $CurrentPreview = $Global:activeME.Preview
    if($Global:Program -ne $CurrentProgram -OR $Global:Preview -ne $CurrentPreview){
        for($i=0 ; $i -lt 8; $i++){
            if($i -eq $CurrentProgram-1){
                $deckInterface.SetKeyBitmap($buttonMapping[$i],$ProgramButtons[$CurrentProgram-1])
            }
            elseif($i -eq $CurrentPreview-1){
                $deckInterface.SetKeyBitmap($buttonMapping[$i],$PreviewButtons[$CurrentPreview-1])
            }
            else{
                $deckInterface.SetKeyBitmap($buttonMapping[$i],$BlankButtons[$i])
            }

        }
        $Global:Preview = $CurrentPreview
        $Global:Program = $CurrentProgram

    }
    
}

# Start the timer
Unregister-Event $sourceIdentifier -ErrorAction SilentlyContinue
$timer.stop()
$start = Register-ObjectEvent -InputObject $timer -SourceIdentifier $sourceIdentifier -EventName Elapsed -Action {timeraction}
$timer.start()
#endregion
#PiP window locations
$topLeft = @(-8,4.5,.5,.5)
$topRight = @(8,4.5,.5,.5)
$bottomRight = @(8,-4.5,.5,.5)
$bottomLeft = @(-8,-4.5,.5,.5)
function setPIPWindow{
    param([double[]]$window)
    $Global:Key1.FlyPositionX = $window[0]
    $Global:Key1.FlyPositionY = $window[1]
    $Global:Key1.FlySizeX = $window[2]
    $Global:Key1.FlySizeY = $window[3]
}

function GetMousePosition(){
    start-sleep 5
    [System.Windows.Forms.Cursor]::Position
}
# I used this to jump to Blackmagic ATEM softwre audio tab with hot key
# credit http://stackoverflow.com/questions/39353073/how-i-can-send-mouse-click-in-powershell
$cSource = @'
using System;
using System.Drawing;
using System.Runtime.InteropServices;
using System.Windows.Forms;
public class Clicker
{
//https://msdn.microsoft.com/en-us/library/windows/desktop/ms646270(v=vs.85).aspx
[StructLayout(LayoutKind.Sequential)]
struct INPUT
{ 
    public int        type; // 0 = INPUT_MOUSE,
                            // 1 = INPUT_KEYBOARD
                            // 2 = INPUT_HARDWARE
    public MOUSEINPUT mi;
}

//https://msdn.microsoft.com/en-us/library/windows/desktop/ms646273(v=vs.85).aspx
[StructLayout(LayoutKind.Sequential)]
struct MOUSEINPUT
{
    public int    dx ;
    public int    dy ;
    public int    mouseData ;
    public int    dwFlags;
    public int    time;
    public IntPtr dwExtraInfo;
}

//This covers most use cases although complex mice may have additional buttons
//There are additional constants you can use for those cases, see the msdn page
const int MOUSEEVENTF_MOVED      = 0x0001 ;
const int MOUSEEVENTF_LEFTDOWN   = 0x0002 ;
const int MOUSEEVENTF_LEFTUP     = 0x0004 ;
const int MOUSEEVENTF_RIGHTDOWN  = 0x0008 ;
const int MOUSEEVENTF_RIGHTUP    = 0x0010 ;
const int MOUSEEVENTF_MIDDLEDOWN = 0x0020 ;
const int MOUSEEVENTF_MIDDLEUP   = 0x0040 ;
const int MOUSEEVENTF_WHEEL      = 0x0080 ;
const int MOUSEEVENTF_XDOWN      = 0x0100 ;
const int MOUSEEVENTF_XUP        = 0x0200 ;
const int MOUSEEVENTF_ABSOLUTE   = 0x8000 ;

const int screen_length = 0x10000 ;

//https://msdn.microsoft.com/en-us/library/windows/desktop/ms646310(v=vs.85).aspx
[System.Runtime.InteropServices.DllImport("user32.dll")]
extern static uint SendInput(uint nInputs, INPUT[] pInputs, int cbSize);

public static void LeftClickAtPoint(int x, int y)
{
    //Move the mouse
    INPUT[] input = new INPUT[3];
    input[0].mi.dx = x*(65535/System.Windows.Forms.Screen.PrimaryScreen.Bounds.Width);
    input[0].mi.dy = y*(65535/System.Windows.Forms.Screen.PrimaryScreen.Bounds.Height);
    input[0].mi.dwFlags = MOUSEEVENTF_MOVED | MOUSEEVENTF_ABSOLUTE;
    //Left mouse button down
    input[1].mi.dwFlags = MOUSEEVENTF_LEFTDOWN;
    //Left mouse button up
    input[2].mi.dwFlags = MOUSEEVENTF_LEFTUP;
    SendInput(3, input, Marshal.SizeOf(input[0]));
}
}
'@
Add-Type -TypeDefinition $cSource -ReferencedAssemblies System.Windows.Forms,System.Drawing
#Send a click at a specified point
function clickMouse($xpos, $ypos){
[Clicker]::LeftClickAtPoint($xpos,$ypos)
}

# If running in the console, wait for input before closing. 
if ($Host.Name -eq "ConsoleHost") {
     Write-Host "Press any key to continue..."
     $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyUp") > $null
}