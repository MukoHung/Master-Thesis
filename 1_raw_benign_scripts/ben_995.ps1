#region UX config

Import-Module posh-git

if (Get-Module PSReadLine) {
    Import-Module oh-my-posh
    $ThemeSettings.MyThemesLocation = "~/.config/powershell/oh-my-posh/Themes"
    
    if (Get-Theme | Where-Object Name -eq Sorin-NL) {
        Set-Theme Sorin-NL
    } else {
        Set-Theme Sorin
    }

    Set-PSReadLineKeyHandler -Chord Alt+Enter -Function AddLine
    Set-PSReadLineOption -ContinuationPrompt "  " -Colors @{ Operator = "`e[95m"; Parameter = "`e[95m" }
}

#endregion

#region Helper functions



#endregion

#region Argument completers

Register-ArgumentCompleter -Native -CommandName dotnet -ScriptBlock {
    param($commandName, $wordToComplete, $cursorPosition)
    dotnet complete --position $cursorPosition "$wordToComplete" | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
}

# dotnet suggest shell start

if (Get-Command dotnet-suggest -ErrorAction SilentlyContinue) {
    $availableToComplete = (dotnet-suggest list) | Out-String
    $availableToCompleteArray = $availableToComplete.Split([Environment]::NewLine, [System.StringSplitOptions]::RemoveEmptyEntries)

    Register-ArgumentCompleter -Native -CommandName $availableToCompleteArray -ScriptBlock {
        param($commandName, $wordToComplete, $cursorPosition)
        $fullpath = (Get-Command $wordToComplete.CommandElements[0]).Source

        $arguments = $wordToComplete.Extent.ToString().Replace('"', '\"')
        dotnet-suggest get -e $fullpath --position $cursorPosition -- "$arguments" | ForEach-Object {
            [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
        }
    }
    $env:DOTNET_SUGGEST_SCRIPT_VERSION = "1.0.0"
}
# dotnet suggest script end

#endregion

#region Update PowerShell Daily

$updateJob = Start-ThreadJob -ScriptBlock {
    Invoke-Expression "& {$(Invoke-RestMethod aka.ms/install-powershell.ps1)} -Daily"
}

$eventJob = Register-ObjectEvent -InputObject $updateJob -EventName StateChanged -Action {
    if($Event.Sender.State -eq [System.Management.Automation.JobState]::Completed) {
    	Get-EventSubscriber $eventJob.Name | Unregister-Event
	    Remove-Job $eventJob -ErrorAction SilentlyContinue
    	Receive-Job $updateJob -Wait -AutoRemoveJob -ErrorAction SilentlyContinue
    }
}

#endregion

#startregion Hooks

# Set CurrentDirectory when LocationChangedAction is invoked.
# This allows iTerm2's "Reuse previous session's directory" to work
$ExecutionContext.SessionState.InvokeCommand.LocationChangedAction += {
    [Environment]::CurrentDirectory = $pwd.Path
}

#endregion
