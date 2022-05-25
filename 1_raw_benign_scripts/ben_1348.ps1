### Safety.  Make sure that you don't run the entire file.
BREAK

### Slides - because every presentation needs some sort of obligatory slide.  Two slides
### promise - the rest is VS code or the PS prompt.

### Setup the script environment
$PresentationDirectory = 'C:\scripts\simonsr\Presentation\PSSummit2021'
Push-Location $PresentationDirectory

### Errors
.\example1.ps1 -ComputerName (Get-expServers)
### Red errors all over the place.  End user doesn't know what is going on besides red
### is bad in PS. This is not the right way of doing things!  Although many people think
### of how to handle errors last.  Like documentation?

.\Example2.ps1 -ComputerName (Get-expServers)
### No errors - isn't this much better?  This is the equivalent of 'On error resume next'
### Now the end user thinks that everything is great.  Which it isn't.

.\Example3.ps1 -ComputerName (Get-expServers)
### Ah - we tell the end user that ethey have some issues.  However - this isn't pipeline
### friendly.  I can't go and do something on the servers that had issues!

.\Example4.ps1 -ComputerName (Get-expServers)
### Now I have successes and errors all returning objects into the (potential) pipeline.
### The kicker - all of these scripts are using the same basic code:
### Get-CIMInstance -ClassName Win32_OperatingSystem -ComputerName $ComputerName
###     -OperationTimeoutSec 30

### Introduction <slide>
### Been automating through scripting for over 30 years
### Played around with a whole lot of different technologies in that period of time
### Infrastructure team lead for an engineering company in over 75 points of presence in North
### America and a couple of international locations

### Lets look at the first example
code .\example1.ps1
### The 'improvements' placed into second example
code .\example2.ps1
### Lets throw some warnings at the end
code .\Example3.ps1
### Better error handling
code .\Example4.ps1

### As mentioned above - all of these scripts are using the same base code.

### Where do you find errors messages?
$Error
### Built in variable that contains an array of error objects that represent the errors in
### your session (up to MaximumErrorCount - 256 default).
### The most recent error is the first error object in the array $Error[0].
$Error[0]
### Under PS v7 you can use Get-Error to get error details.  Show this.
### Under PS v5 you need to do a bit more work!  Show this.

### Terminating vs non-terminating errors
### Non-terminating errors.  Throws an error to the error stream but does not terminate the
### current execution.  These are the majority of the errors out there.
code Example5.ps1
.\Example5.ps1
code Arithmetic.ps1
.\Arithmetic.ps1 -Number1 12 -Number2 6
.\Arithmetic.ps1 -Number1 6 -Number2 0

### Terminating error
### Not as common as non-terminating errors.
### Mostly with environmental stuff - like running out of memory.
Code TerminatingPipelineError.ps1
Code TerminatingError.ps1

### $ErrorActionPreference
### Global variable
Get-Childitem Variable:ErrorActionPreference
### How do you handle non-terminating errors - globally.
### You can set this up on cmdlets - which we will talk about in a moment.
$OrgErrorActionPreference = $ErrorActionPreference
$ErrorActionPreference = 'Stop'
.\Arithmetic.ps1 -Number1 6 -Number2 0
$ErrorActionPreference = $OrgErrorActionPreference
Get-Childitem Variable:ErrorActionPreference
### Preferred not to set this globally as people tend to forget to set it back.
### However there are use case scenarios that you'd use it.

### Parameter -ErrorAction
### What you want the to do when a non-terminating error occurs with a cmdlet.
### Multiple different options:  Suspend, Ignore, Inquire, Continue, Stop & SilentlyContinue

### No erroraction parameter
Get-ChildItem C:\NonexistantDirectory

### Suspend. Only available for workflows which aren't supported in PowerShell 6 and beyond.
### Ignore. Supresses the error message and continues executing the command.  Does not add
###    the error message to the $error automatic variable.
Get-ChildItem C:\NonexistantDirectoryTwo -ErrorAction Ignore
Get-Error -Newest 3 | Select-Object @{N = 'Message'; E = { $_.Exception.Message } }

### Inquire.  Displays the error message and prompts you for confirmation before continuing
###    execution. This value is rarely used.
Get-ChildItem C:\NonexistantDirectoryThree -ErrorAction Inquire | Sort-Object LastWriteTime

### Continue. Continue display the error message and continues executing the command.
### Continue is the default.
### Stop. Displays the error message and stops executing the command.
Get-ChildItem C:\NonexistantDirectoryFour -ErrorAction Stop

### SilentlyContinue. Suppresses the error message and continues executing the command.
Get-ChildItem C:\NonexistantDirectoryFive -ErrorAction SilentlyContinue
Get-Error -Newest 3 | Select-Object @{N = 'Message'; E = { $_.Exception.Message } }

### NOTE: The cmdlet paramter ErrorAction overrides the global ErrorActionPreference

### NOTE: Some cmdlets don't work well with -ErrorAction.  A common offender is AD cmdlets
### and the keyword SilentlyContinue.
Get-ADUser nonexistentuser -ErrorAction SilentlyContinue
### This doesn't work on PS v5.1 & 7.x
### The way to get around this is to set the global ErrorActionPreference - do your
### command with AD cmdlet and then set it back to the original setting

$OrgErrorActionPreference = $ErrorActionPreference
$ErrorActionPreference = 'SilentlyContinue'
Get-ADUser nonexistentusertwo
$ErrorActionPreference = $OrgErrorActionPreference
Get-Error | Select-Object @{N = 'Message'; E = { $_.Exception.Message } }

### Where to store your errors?  Besides $Error.  We can use another parameter ErrorVariable
### Some things to note.  Don't use $ in front of errorvariable parameter.
Get-ChildItem C:\NonexistantDirectoryFive -ErrorAction SilentlyContinue -ErrorVariable errChildItem
$errChildItem
Get-ChildItem C:\NonexistantDirectorySix -ErrorAction SilentlyContinue -ErrorVariable errChildItem
$errChildItem
Get-ChildItem C:\NonexistantDirectorySeven -ErrorAction SilentlyContinue -ErrorVariable +errChildItem
$errChildItem

### A couple of things that don't fit anywhere else
### Write-Error doesn't actually write a terminating error.  To write a terminating error
### with the cmdlet you need to use ErrorAction Stop.
### If you run a command (exe) how do you determine if it worked or not?  $LastExitCode
Ping Google.com
$LastExitCode
Ping thisreallydoesntexist.com
### Strangely enough thisdoesntexist.com actualy resolves to something!
$LastExitCode

### REVIEW
### How to handle errors:  Handling bad inputs.  Validation!
code .\Arithmetic.ps1
### You can do parameter validation and throw an error when you see a 0.
### You can trap the error and give an warning or error
### Or you can let everything fall on the floor and let the user deal with it.
### The last option is not acceptable!
.\Arithmetic.ps1 -Number1 12 -Number2 6
.\Arithmetic.ps1 -Number1 6 -Number2 0
code .\Arithmetic-Validation.ps1
.\Arithmetic-Validation.ps1 -Number1 6 -Number2 0
code Arithmetic-Validation-Part2.ps1
.\Arithmetic-Validation-Part2.ps1 -Number1 6 -Number2 0

### There are a quite a few blogs out there about doing parameter validation.
### Mike F Robbins did a talk in PSSummit 2018: Writing Award Winning PowerShell Functions and
### Script Modules.  You can find it at YouTube and he talks about parameter validation.

### However would you rather see this as an error message
.\ParameterValidationIPv4.ps1 -IPv4Address 277.277.277.277

### Or this?
Import-Module .\BetterParameterValidationIPv4.psm1
New-IPv4Address -IPv4Address 277.277.277.277
### Cryptic or not cryptic.  Know your audience!
code .\BetterParameterValidationIPv4.psm1
code .\ParameterValidationIPv4.ps1

### Trapping error messages
### Try/Catch
code .\Arithmetic-ErrorHandling.ps1
.\Arithmetic-ErrorHandling.ps1 -Number1 6 -Number2 0

### Try/Catch.  Catching with specific exception types.
code .\Arithmetic-ErrorHandling-Part2.ps1
.\Arithmetic-ErrorHandling.ps1 -Number1 6 -Number2 0

### How did I get that exception type???
### PS v5.1
1 / 0
$error[0].Exception.Gettype().FullName
### PS v7
1 / 0
Get-Error

### Try/Catch.  Multiple error exception types.
### Go from most specific exception type to the least specific.  Exceptions are only matched
### once!
code .\Get-Content-Redux.ps1
.\Get-Content-Redux.ps1 -InputFile '\\FileServer\HRShare\UserList.txt'
.\Get-Content-Redux.ps1 -InputFile (Join-Path $PresentationDirectory 'cantaccessthis.txt')
.\Get-Content-Redux.ps1 -InputFile $PresentationDirectory

### Try/Catch.  Multiple error exceptions types in one catch.
code .\Get-Content-Redux-Part2.ps1
.\Get-Content-Redux-Part2.ps1 -InputFile '\\FileServer\HRShare\UserList.txt'
.\Get-Content-Redux-Part2.ps1 -InputFile (Join-Path $PresentationDirectory 'cantaccessthis.txt')

### Try/Catch.  You can nest these!
code Get-Content-Redux-Part3.ps1
.\Get-Content-Redux-Part3.ps1 -InputFile (Join-Path $PresentationDirectory 'cantaccessthis.txt')
.\Get-Content-Redux-Part3.ps1 -InputFile (Join-Path $PresentationDirectory 'users.txt')

### Try/Catch/Finally.
### Finally ALWAYS runs (well - there are some edge cases ...)
### This is utilized for mostly resource cleanup that you want to happen even if the script
### went off the rails.  Example:  Clean up the connections to a DB you are connecting to.
code .\Example6.ps1
.\Example6.ps1

### What are those edge cases?  What happens if in your catch statement you rebooted the
### computer running the script?  Do you think that the finally scriptblock will run???
### Theoretical - No I am not rebooting my workstation
Try {
    1 / 0
}
Catch {
    Restart-Computer -whatif
}
Finally {
    Start-Sleep -Seconds 10
    Add-Content -Value "This won't show up in the log file" -Path "C:\TEmp\TryCatchFinallyExample.txt"
    Write-Output "This won't run - if the computer was rebooted."
}
### Actually, I tried this on a VM.  And the Finally block did not stop the restart.

### These are the basics of error handling or mitigation.  You have the choice of providing
### good information to your customers when things go wrong.  Or let everything fall onto the
### floor.  Choose wisely!

### Contact information slide.














### Additional items

### More information about errors.  Talk about $_/$PSItem

Function Start-Something {
    Throw 'Bad thing happened'
}

Start-Something

### Inside of a catch block there is an automatic variable:  $_ or $PSItem.  This is
### confusing but they are the same.  I will be using $PSItem.
### $PSItem is an object (ErrorRecord) - althought if $PSItem is contained in a string
### the exception message is expanded and used.
Try {
    Start-Something
} #Try
Catch {
    $PSItem.GetType()
    Write-Output "Ran into an issue: $PSItem"
} #Catch

### The errorrecord $PSItem contains a lot of information.  InvocationInfo contains
### additional information where the exception was throw.

### The wonderful world of throw....
### We have used thrown a couple of times in this presentation without really explaining it.
### Throw creates a terminating error - that is either dealt with a catch or exits the
### function that it is throw in.

### Logging
### Before we get into error handling - a side discussion about logging.
### Recommendations:  Log EVERYTHING!
### When you are dealing with things that go wrong - the error message to your customer
### (whether that be you, someone in your organization, or in the world) using your script
### or your module is important.  However - knowing what was happening and where that error
### message was actually tripped is vital to troubleshooting and resolving that error.

### Get in the habit of writing out information to a log.
### Minimum.  Indicate what function you are in.  We all write functions to do one thing -
### and one thing only right?  Get into the habit of doing this.  It will save you a TON of
### grief when you get to Pester testing.  We all do Pester testing - don't we???

### I use Fred's Weinmann's PowerShell Framework (PSFramework) to handle logging.  Could you
### write your own?  Sure.  However Fred's is multi-threaded aware (and safe), writes
### everything into one location.  Automatically grooms the old log files out. And a lot of
### other neat nifty features.  His GitHub repo is here
### (FriedrichWeinmann (Friedrich Weinmann) · GitHub).
### His tool can be installed by running Install-Module PSFramework.
### He did a presentation at Summit 2019 called "Logging in a DevOps World"  I would suggest
### you go review it.

### How modules handle errors
### Side conversation that we need to have here.  If you are distributing a module in your
### organization then making a dependency on your logging solution (whether it is home grown
### or not) is an easy decision that you can enforce.  However - when you make your module
### generally available to everyone - then this is a bigger decision that you need to think
### about more.  More about this later.
### <<<Look at get-kbhotfix module for how to do place in dependencies on other modules>>>