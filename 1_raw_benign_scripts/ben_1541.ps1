# Link: http://www.reddit.com/r/PowerShell/comments/1khn9o/a_fun_script_for_friday_make_your_friends/
# A fun script for Friday - make your friend's computer start talking to him/her (self.PowerShell)
# submitted 1 year ago * by Sinisterly
# A co-worker of mine stumbled upon this nifty blog article on how to make a text-to-speech call using PowerShell.
# The article gives two examples:
# - Call the SAPI.SPVoice COM object
# - Load the reference to System.Speech
# Where can this come in fun? Well, if you throw PSRemoting in, of course! In my testing, if you use the second method (or the pared down script below) you can make your victim's computer start talking to him or her. Here's how you do it:
# 1. Provide a distraction so that your victim leaves their computer unlocked, and make yourself administrator on their workstation (only needed if you aren't already an admin!)
# 2. Enable PSRemoting on their workstation. A method for doing this would be using PSExec:
psexec.exe /acceptEula \\(yourVictimsComputer) -d -h -s powershell.exe ""Enable-PSRemoting -Force"""
# 3. Start a new PSSession connecting to their workstation:
New-PSSession -ComputerName YourVictimsComputer
# 4. Load this function:
function Say-Text {
    param ([Parameter(Mandatory=$true, ValueFromPipeline=$true)] [string] $Text)
    [Reflection.Assembly]::LoadWithPartialName('System.Speech') | Out-Null   
    $object = New-Object System.Speech.Synthesis.SpeechSynthesizer 
    $object.Speak($Text) 
}
# 5. Ensure that their volume is on. (For example, say, "Hey I just found this really funny video!")
# 6. Start speaking to them by calling the function you just made:
Say-Text "I'm afraid I can't do that Dave"