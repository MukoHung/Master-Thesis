#requires -Version 5.1


Function Start-PSNap {

<#
.SYNOPSIS
Start a PowerShell napping session.
.DESCRIPTION
Use this command to start a short napping session. The command will alert you when you nap is up with a chime and a message. You have an option of displaying the message on the screen or having it spoken.
.PARAMETER Minutes
The number of minutes for your nap. This command has aliases of: nap and time
.PARAMETER ProgressBar
Indicate if you want to show a progress bar which includes a number of messages.
.PARAMETER Message
The text of the message to be displayed or spoken at the end of your nap.
.PARAMETER Voice
Specify the name of the installed voice to use. More most US desktops this will be David, Zira and perhaps Hazel. If you use this parameter the message will not be written to host. This dynamic parameter is only available in Windows PowerShell.
.PARAMETER Rate
The voice speaking rate. Enter a value between -5 and 5. This dynamic parameter is only available in Windows PowerShell.
.EXAMPLE
PS C:\> Start-PSNap 10 -ProgressBar -message "Get back to work you lazy bum!"
Start a 10 minute nap with the progress bar and display the given message in the console host.
.EXAMPLE
PS C:\> Start-PSNap 15 -message "Wake up you fool and get back to work." -voice "Microsoft Zira Desktop"
Start a 15 minute nap and use the computer voice Zira to speak the wake up message.
.NOTES

Learn more about PowerShell: http://jdhitsolutions.com/blog/essential-powershell-resources/

.LINK
Start-Sleep
.INPUTS
none
.OUTPUTS
none
#>

    [cmdletbinding(DefaultParameterSetName = "host")]
    [alias("psnap")]

    Param (
        [Parameter(Position = 0)]
        [Alias("nap", "time")]
        [ValidateRange(1, 30)]
        [int]$Minutes = 1,

        [switch]$ProgressBar,

        [ValidateNotNullorEmpty()]
        [string]$Message = "Get back to work sleepy head!"

    )
    DynamicParam {
        #create a dynamic parameter if running Windows PowerShell
        if ($psedition -eq 'Desktop' ) {
            #define a parameter attribute object
            $attributes = New-Object -TypeName System.Management.Automation.ParameterAttribute
            $attributes.ParameterSetName = "speech"
            $attributes.HelpMessage = "Select an installed voice"

            #add a dynamic validation set
            #get voices
            try {
                Add-Type -AssemblyName System.speech -ErrorAction Stop
            }
            Catch {
                Throw $_
            }
            [string[]]$installed = [System.Speech.Synthesis.SpeechSynthesizer]::new().GetInstalledVoices().voiceinfo.Name
            # [regex]$rx= "Microsoft\s+(?<name>\w+)\s+"
            #build a list of voices assuming the voice name is something like Microsoft David Desktop
            # $choices = (($rx.Matches($installed)).foreach({$_.groups["name"].value})) -join ","

            $validate = [System.Management.Automation.ValidateSetAttribute]::new($installed)

            #define a collection for attributes
            $attributeCollection = New-Object -TypeName System.Collections.ObjectModel.Collection[System.Attribute]
            $attributeCollection.Add($attributes)
            $attributeCollection.Add($validate)

            #define the dynamic param
            $dynParam1 = New-Object -TypeName System.Management.Automation.RuntimeDefinedParameter("Voice", [string], $attributeCollection)
            #set a default voice
            $dynParam1.Value = $installed[0]

            #create array of dynamic parameters
            $paramDictionary = New-Object -TypeName System.Management.Automation.RuntimeDefinedParameterDictionary
            $paramDictionary.Add("Voice", $dynParam1)

            #create the Rate parameter
            <#
                [Parameter(ParameterSetName = "voice")]
                [ValidateRange(-5, 5)]
                [int]$Rate = -1
            #>
            #re-use the attributes variable
            $attributes.HelpMessage = "Select the speaking rate."
            $validate = [System.Management.Automation.ValidateRangeAttribute]::new(-5,5)

            $attributeCollection = New-Object -TypeName System.Collections.ObjectModel.Collection[System.Attribute]
            $attributeCollection.Add($attributes)
            $attributeCollection.Add($validate)

            $dynParam2 = New-Object -TypeName System.Management.Automation.RuntimeDefinedParameter("Rate", [int32], $attributeCollection)

            $dynParam2.value = 0

            #create array of dynamic parameters
            $paramDictionary.Add("Rate", $dynParam2)
            #use the array
            return $paramDictionary
        }
    }

    Begin {
        $wake = (Get-Date).AddMinutes($Minutes)
        $remainingSeconds = $minutes * 60

        #an array of status messages if using a progress bar
        $ops = @(
            "I'm solving a PowerShell problem",
            "I'm chasing cmdlets",
            "Brilliance at work",
            "Re-initializing my pipeline",
            "Go away",
            "I'm checking eyelid integrity",
            "It can wait...",
            "Don't you dare!",
            "Spawning a new runspace",
            "I'm multitasking",
            "Nothing is that important",
            "Unless you have a glass of [beer|scotch|wine|bourbon] for me, go away",
            "I'm testing the new PSNap provider",
            "I need this",
            "I'm downloading my new matrix",
            "Resource recyling in progress",
            "Life is but a dream",
            "Garbage collection initiated",
            "Nudge me if I'm snoring",
            "I took the red pill",
            "Synaptic synch in progress",
            "Neural network rebooting",
            "Reformatting synapses",
            "There's no place like home. There's no place like home.",
            "If you can read this you should go away",
            "$($env:username) has left the building"
            )

        #hashtable of parameter values to splat to Write-Progress
        $progHash = @{
            Activity         = "Ssssshhh..."
            Status           = $ops[0]
            SecondsRemaining = $remainingSeconds
        }
        Clear-Host
    } #begin

    Process {
        #loop until the time is >= the wake up time
        do {
            if ($ProgressBar ) {
                Write-Progress @proghash
                #tick down $remainingseconds
                $proghash.SecondsRemaining = $remainingSeconds--
                #pick a new random status if remaining seconds is divisible by 10
                if ($remainingSeconds / 10 -is [int]) {
                    $proghash.status = $ops | Get-Random
                }
            } #if
            else {
                Clear-Host
                Write-Host "Ssshhhh...." -ForegroundColor green

                #trim off the milliseconds
                Write-Host ($wake - (Get-Date)).ToString().Substring(0, 8) -NoNewline
            } #else

            Start-Sleep -Seconds 1

        } Until ( (Get-Date) -ge $wake )
    } #process

    End {
        #Play wake up music
        [console]::Beep(392, 950)
        [console]::Beep((329.6*2), 950)
        [console]::Beep(523.2, 950)

        If ($PSBoundParameters.ContainsKey("Voice")) {
            #pause a moment after the wakeup music
            Start-Sleep -Milliseconds 700
            Add-Type -AssemblyName System.speech
            $speech = New-Object System.Speech.Synthesis.SpeechSynthesizer
            $speech.SelectVoice($psboundparameters.Item("Voice"))
            $speech.Rate = $Rate
            $speech.SpeakAsync($message) | Out-Null

            #write a blank line to get a new prompt
            Write-Host "`n"
        }
        else {
            Write-Host "`n$Message" -ForegroundColor Yellow
        }
    } #end

} #end function