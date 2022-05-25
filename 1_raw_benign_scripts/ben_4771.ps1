# Project: April Fool's Prank

#Requirements:
<#
You need a few files so Powershell can use them during the script.

You need copy the move the extracted folder ("Powershell_April_Fool_Project") to the C:\temp location.

This is a complilation of multiple scripts.
#>

function Gandalf{
#WPF Library for Playing Movie and some components
Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName System.ComponentModel
#XAML File of WPF as windows for playing movie
[xml]$XAML = @"
 
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="PowerShell Video Player" Height="355" Width="553" ResizeMode="NoResize">
    <Grid Margin="0,0,2,3">
        <MediaElement Height="250" Width="525" Name="VideoPlayer" LoadedBehavior="Manual" UnloadedBehavior="Stop" Margin="8,10,10,61" />
        <Button Content="Pause" Name="PauseButton" HorizontalAlignment="Left" Margin="236,283,0,0" VerticalAlignment="Top" Width="75"/>
        <Button Content="Play" Name="PlayButton" HorizontalAlignment="Left" Margin="236,283,0,0" VerticalAlignment="Top" Width="75"/>
    </Grid>
</Window>
"@
 
#Movie Path
[uri]$VideoSource = "C:\temp\Powershell_April_Fool_Project\Gandalf.mp4"
 
#Devide All Objects on XAML
$XAMLReader=(New-Object System.Xml.XmlNodeReader $XAML)
$Window=[Windows.Markup.XamlReader]::Load( $XAMLReader )
$VideoPlayer = $Window.FindName("VideoPlayer")
$PauseButton = $Window.FindName("PauseButton")
$PlayButton = $Window.FindName("PlayButton")
 
#Video Default Setting
$VideoPlayer.Volume = 100;
$VideoPlayer.Source = $VideoSource;
$VideoPlayer.Play()
$PauseButton.Visibility = [System.Windows.Visibility]::Visible
$PlayButton.Visibility = [System.Windows.Visibility]::Hidden
 
#Button click event 
$PlayButton.Add_Click({
    $VideoPlayer.Play()
    $PauseButton.Visibility = [System.Windows.Visibility]::Visible
    $PlayButton.Visibility = [System.Windows.Visibility]::Hidden
})
$PauseButton.Add_Click({
    $VideoPlayer.Pause()
    $PauseButton.Visibility = [System.Windows.Visibility]::Hidden
    $PlayButton.Visibility = [System.Windows.Visibility]::Visible
})
 
#Show Up the Window 
$Window.ShowDialog() | out-null
}

function TonyMontana {
(New-Object -ComObject shell.application).toggleDesktop() #shows-desktop

# Reference: https://devblogs.microsoft.com/scripting/powertip-use-powershell-to-play-wav-files/
# Plays a WAV file - Tony Montana Sound
$PlayWav=New-Object System.Media.SoundPlayer
$PlayWav.SoundLocation=’C:\temp\Powershell_April_Fool_Project\scarface_say_hello.wav’
$PlayWav.playsync()
}

function catMeow {
(New-Object -ComObject shell.application).toggleDesktop() #shows-desktop

start "C:\temp\Powershell_April_Fool_Project\Cat.png" # Opens a cat picture# Opens a cat picture
Start-Sleep -Seconds 1 # waits for n seconds

# Plays a WAV file - Cat sound
$PlayWav=New-Object System.Media.SoundPlayer
$PlayWav.SoundLocation=’C:\temp\Powershell_April_Fool_Project\cat_growl.wav’
$PlayWav.playsync()

Start-Sleep -Seconds 1 # waits for n seconds
taskkill /F /IM Microsoft.Photos.exe # Closes the cat picture
}

function Terminator {
(New-Object -ComObject shell.application).toggleDesktop() #shows-desktop

Start-Sleep -Seconds 1 # waits for n seconds
$PlayWav.SoundLocation=’C:\temp\Powershell_April_Fool_Project\t2_hasta_la_vista.wav’
$PlayWav.playsync()
$PlayWav.SoundLocation=’C:\temp\Powershell_April_Fool_Project\t1_be_back.wav’
$PlayWav.playsync()
$PlayWav.SoundLocation=’C:\temp\Powershell_April_Fool_Project\t2_trust_me.wav’
$PlayWav.playsync()
}

function April_Fools{
Start-Sleep -Seconds 1 # waits for n seconds
start "C:\temp\Powershell_April_Fool_Project\2in1.png" # Opens a 2in1 picture
Start-Sleep -Seconds 3 # waits for n seconds
}

TonyMontana

catMeow

Terminator

April_Fools


#Displays a MessageBox to the user
[System.Windows.MessageBox]::Show('Replace User then try again. :)','User Error', 0,'Error')

Gandalf
