function say {
    param( [string]$comment = $_ )
    [Reflection.Assembly]::LoadWithPartialName('System.Speech') | Out-Null 
    $object = New-Object System.Speech.Synthesis.SpeechSynthesizer
    $object.SelectVoiceByHints('Female')
    $object.Speak("$comment")
}