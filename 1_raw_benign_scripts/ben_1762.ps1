using namespace System.Collections.Concurrent

$StartDate = [datetime]::UtcNow
# can be generated with something like
# 1..10 | %{ Get-Credential} | Export-CliXml -path 'C:\reports\InboxRules\Creds.xml'
# Which will prompt for credentials 10 times and store them in the xml file
$CredentialFile = 'C:\reports\InboxRules\Creds.xml'
$RunDate = $StartDate.ToString('o') -replace ':'
# This is the path of the CSV file. It is imperative that this file not be 
# access while the script is running
$ReportPath = 'C:\reports\InboxRules\{0}.csv' -f $RunDate
# The path to the log file where details about the running of the script will be logged
$LogPath = 'C:\reports\InboxRules\{0}.log' -f $RunDate
# Path to store any mailboxes which failed
$FailedPath = 'C:\reports\InboxRules\{0}-failed.xml' -f $RunDate
# Number of errors a consumer thread will encounter before exiting
$ThreadErrorThreshold = 10
# Number of times to retry a mailbox
$RetryThreshold = 3
# Passed to Get-Mailbox -ResultSize
$ResultSize = 'unlimited'
# Number of inbox rules to write to the report at one time
$ReportBatchSize = 100

# Populate a queue of credentials
# This will be consumed by the MailboxProducer and MailboxConsumer Threads
$CredentialQueue = [BlockingCollection[PSCredential]]::new([ConcurrentQueue[PSCredential]]::new())
$Credentials = Import-Clixml -Path $CredentialFile 
$Credentials | ForEach-Object {
    $CredentialQueue.Add($_)
}

# Initialize queues and stacks
# Contains mailboxes produced by the MailboxProducer Thread
# Consumed by MailboxConsumer Threads
$MailboxQueue = [BlockingCollection[PSObject]]::new([ConcurrentQueue[PSObject]]::new())
# Contains Inbox Rules produced by the MailboxConsumer Threads
# Consumed by ReportConsumer thread
$ReportQueue = [BlockingCollection[PSObject]]::new([ConcurrentQueue[PSObject]]::new())
# Contains Mailboxes which had errors retrieving Inbox Rules Produced by MailboxConsumer Threads
# Consumed aty the end of execution
$ErrorQueue = [BlockingCollection[PSObject]]::new([ConcurrentQueue[PSObject]]::new())
# Stack used to count the current running  MailboxConsumer Threads
# Pushed a the beginning of a thread and popped at the end
$MailboxConsumerStack = [ConcurrentStack[Int]]::new()
# Contains Log Messages
# Produced by all threads
# Consumed by LogMessageConsumer
$LogMessageQueue = [BlockingCollection[String]]::new([ConcurrentQueue[String]]::new())

# Log the script environment
$LogMessageQueue.Add("---------------------------------------------------")
$LogMessageQueue.Add("Runstart $StartDate")
$LogMessageQueue.Add("CredentialFile $CredentialFile")
$LogMessageQueue.Add("ReportPath $ReportPath")
$LogMessageQueue.Add("LogPath $LogPath")
$LogMessageQueue.Add("ThreadErrorThreshold $ThreadErrorThreshold")
$LogMessageQueue.Add("RetryThreshold $RetryThreshold")
$LogMessageQueue.Add("ResultSize $ResultSize")
$LogMessageQueue.Add("ReportBatchSize $ReportBatchSize")
$LogMessageQueue.Add("---------------------------------------------------")

# Parameters to pass to MailboxProducer thread
$MailboxProducerParams = [System.Collections.Generic.List[System.Object]]::new()
$MailboxProducerParams.Add($MailboxQueue)
$MailboxProducerParams.Add($CredentialQueue)
$MailboxProducerParams.Add($LogMessageQueue)
$MailboxProducerParams.Add($ResultSize)

# Parameters to pass to MailboxConsumer threads
$MailboxConsumerParams = [System.Collections.Generic.List[System.Object]]::new()
$MailboxConsumerParams.Add($MailboxQueue)
$MailboxConsumerParams.Add($CredentialQueue)
$MailboxConsumerParams.Add($ReportQueue)
$MailboxConsumerParams.Add($MailboxConsumerStack)
$MailboxConsumerParams.Add($LogMessageQueue)
$MailboxConsumerParams.Add($ErrorQueue)
$MailboxConsumerParams.Add($ThreadErrorThreshold)
$MailboxConsumerParams.Add($RetryThreshold)

# Properties to use in report
# Passed to Select-Object -Properties
$ReportProperties = @(
    'Email'
    'Identity'
    'Enabled'
    'Name'
    'DeleteMessage'
    'DeleteSystemCategory'
    'ForwardTo'
    'ForwardAsAttachmentTo'
    'MoveToFolder'
    'MailboxOwnerId'
    'MarkAsRead'
    @{
        Name = 'Description'
        Expression = {
            $_.Description -replace "`r`n"," "
        }
    }
    'ReportThread'
)

# Parameters to pass to ReportConsumer thread
$ReportConsumerParams = [System.Collections.Generic.List[System.Object]]::new()
$ReportConsumerParams.Add($ReportQueue)
$ReportConsumerParams.Add($ReportPath)
$ReportConsumerParams.Add($ReportProperties)
$ReportConsumerParams.Add($LogMessageQueue)
$ReportConsumerParams.Add($ReportBatchSize)

# Parameters to pass to LogMessageConsumer Thread
$LogMessageConsumerParams = [System.Collections.Generic.List[System.Object]]::new()
$LogMessageConsumerParams.Add($LogMessageQueue)
$LogMessageConsumerParams.Add($LogPath)

# ScriptBlock for the MailboxProduce Thread
# This thread is responsible for producing a list of mailboxes for which
# Inbox Rules will be obtained.
$MailboxProducer = {
    Param(
        [System.Collections.Concurrent.BlockingCollection[PSObject]]
        $MailboxQueue, 

        [System.Collections.Concurrent.BlockingCollection[PSCredential]]
        $CredentialQueue,

        [System.Collections.Concurrent.BlockingCollection[String]]
        $LogMessageQueue,

        [Object]
        $ResultSize
    )
    try {
        $Credential = $CredentialQueue.Take()
    }
    catch {
        Write-Error $_
        return
    }
    $ThreadID = [appdomain]::GetCurrentThreadId()
    $LogMessageQueue.Add("${ThreadID}: MailProducer ThreadStart")
    $LogMessageQueue.Add("${ThreadID}: User $($Credential.UserName)")
    $MailboxCount = 0

    $Params = @{
        ConfigurationName = 'Microsoft.Exchange'
        ConnectionUri     = 'https://outlook.office365.com/powershell-liveid/'
        Credential        = $Credential
        Authentication    = 'Basic'
        AllowRedirection  = $true
    }
    $Session = New-PSSession @Params
    Invoke-Command -Session $Session -ScriptBlock {
        Get-User -RecipientTypeDetails UserMailbox -ResultSize $using:ResultSize
    } | ForEach-Object {
        if ($_.UserAccountControl -match "accountdisabled") { return }
        $Mailbox = $_
        $LogMessageQueue.Add("${ThreadID}: Mailbox Added $($Mailbox.WindowsEmailAddress)")
        $Mailbox | Add-Member -MemberType NoteProperty -Name 'RetryCount' -Value 0
        $MailboxCount++
        $MailboxQueue.Add($Mailbox)
    }
    $LogMessageQueue.Add("${ThreadID}: Mailbox Count $MailboxCount")
    Remove-PSSession $Session
    $StopWatch = [System.Diagnostics.Stopwatch]::new()
    while ($MailboxQueue.Count -gt 0) {
        if ($StopWatch.ElapsedMilliseconds -ge 300000) {
            $LogMessageQueue.Add("MailboxQueue $($MailboxQueue.Count)")
            $StopWatch.Restart()
        }
        Start-Sleep -Milliseconds 500
    }
    $MailboxQueue.CompleteAdding()
    $LogMessageQueue.Add("${ThreadID}: ThreadEnd")
}


# ScriptBlock for the MailboxConsumer Threads
# These threads are responsible for obtaining Inbox Rules
# The inbox rules will be added tot he ReportQueue
# If a mailbox has errors it will be requeued up to 3 times
# If the thread reaches the ThreadErrorThreshold it will exit
$MailboxConsumer = {
    Param(
        [System.Collections.Concurrent.BlockingCollection[PSObject]]
        $MailboxQueue, 

        [System.Collections.Concurrent.BlockingCollection[PSCredential]]
        $CredentialQueue,

        [System.Collections.Concurrent.BlockingCollection[PSObject]]
        $ReportQueue,

        [System.Collections.Concurrent.ConcurrentStack[Int]]
        $MailboxConsumerStack,

        [System.Collections.Concurrent.BlockingCollection[String]]
        $LogMessageQueue,

        [System.Collections.Concurrent.BlockingCollection[PSObject]]
        $ErrorQueue,

        [int]$ThreadErrorThreshold,

        [int]$RetryThreshold
    )
    $ThreadID = [appdomain]::GetCurrentThreadId()
    $LogMessageQueue.Add("${ThreadID}: MailConsumer ThreadStart")
    $LogMessageQueue.Add("${ThreadID}: ThreadErrorThreshold:$ThreadErrorThreshold RetryThreshold:$RetryThreshold")
    $null = $MailboxConsumerStack.Push($ThreadID)
    try {
        $Credential = $CredentialQueue.Take()
    }
    catch {
        $Err = $_
        $LogMessageQueue.Add("${ThreadID}: CredentialError $($Err.Exception.Message)")
        Write-Error $Err
        $LogMessageQueue.Add("${ThreadID}: ThreadEndError")
        $null = $MailboxConsumerStack.TryPop([ref]$null)
        return
    }    
    $LogMessageQueue.Add("${ThreadID}: User $($Credential.UserName)")

    $StopWatch = [System.Diagnostics.Stopwatch]::new()
    $StopWatch.Start()
    $MailboxCount = 0
    $TotalRuntime = 0
    $ThreadErrors = 0
    [PSObject]$Mailbox =  [PSObject]::new()

    try {
        $Params = @{
            ConfigurationName = 'Microsoft.Exchange'
            ConnectionUri     = 'https://outlook.office365.com/powershell-liveid/'
            Credential        = $Credential
            Authentication    = 'Basic'
            AllowRedirection  = $true
            ErrorAction       = 'Stop'
        }
        $Session = New-PSSession @Params
    }
    catch {
        $Err = $_
        $LogMessageQueue.Add("${ThreadID}: SessionError $($Err.Exception.Message)")
        Write-Error $Err
        $LogMessageQueue.Add("${ThreadID}: ThreadEndError")
        $null = $MailboxConsumerStack.TryPop([ref]$null)
        return
    }

    # Use the count rather than an enumerator so we can requeue items with errors
    foreach ($Mailbox in $MailboxQueue.GetConsumingEnumerable()) {
        $MailboxCount++
        $InboxRules = $null
        $Email = $Mailbox.WindowsEmailAddress
        $LogMessageQueue.Add("${ThreadID}: Processing mailbox $MailboxCount $Email")

        try {
            $StartCommand = $StopWatch.ElapsedMilliseconds
            $InboxRules =  Invoke-Command -Session $Session -ScriptBlock { 
                Get-InboxRule -Mailbox $using:Email -ErrorAction 'Stop'
            } -ErrorAction 'Stop'
            $CommandRunTime = $StopWatch.ElapsedMilliseconds - $StartCommand
            $TotalRuntime += $CommandRunTime

            $LogMessageQueue.Add("${ThreadID}: $Email rules $($InboxRules.count)")
            ForEach ($InboxRule in $InboxRules) {
                $InboxRule | Add-Member -MemberType NoteProperty -Name 'Email' -Value $Email
                $InboxRule | Add-Member -MemberType NoteProperty -Name 'ReportThread' -Value $ThreadID
                $ReportQueue.Add($InboxRule)
            }
        }
        catch {
            $CommandRunTime = $StopWatch.ElapsedMilliseconds - $StartCommand
            $TotalRuntime += $CommandRunTime
            $Err = $_
            $ThreadErrors++
            $LogMessageQueue.Add("${ThreadID}: GetInboxError ThreadErrorThreshold:$ThreadErrorThreshold ThreadErrors:$ThreadErrors RetryThreshold:$RetryThreshold RetryCount:$($Mailbox.RetryCount) Email: $Email $($Err.Exception.Message)")

            $Mailbox.RetryCount++

            # Move Mailbox to Error Queue if Retry Threshold Reached
            if ($Mailbox.RetryCount -ge $RetryThreshold) {
                $LogMessageQueue.Add("${ThreadID}: ErrorQueueAdd $email")
                $Mailbox | Add-Member -MemberType NoteProperty -Name 'Exception' -Value $Err
                $ErrorQueue.Add($Mailbox)
            }
            else {
                $LogMessageQueue.Add("${ThreadID}: ErrorQueueAdd $email")
                $RequeueRes = $MailboxQueue.TryAdd($Mailbox)
                $LogMessageQueue.Add("${ThreadID}: ErrorQueueAdd $email success:$RequeueRes")
            }

            if ($ThreadErrors -ge $ThreadErrorThreshold) {
                $LogMessageQueue.Add("${ThreadID}: ThreadErrorThreshold Reached")
                break
            }
        }

        # Throttle so that Office 365 server time never reaches 80% of Consumer runtime
        $MillisecondPool = $StopWatch.ElapsedMilliseconds * .8
        if ($TotalRuntime -gt $MillisecondPool) {
            $Sleep = $TotalRuntime - $MillisecondPool
            $LogMessageQueue.Add("${ThreadID}: ThreadSleep $Sleep")
            Start-Sleep -Milliseconds $Sleep
            $StopWatch.Restart()
            $TotalRuntime = 0
        }
    }

    $LogMessageQueue.Add("${ThreadID}: MailboxCount $MailboxCount")
    Remove-PSSession $Session
    # if this is the last consumer in the stack, complete the Result Queue
    $null = $MailboxConsumerStack.TryPop([ref]$null)
    if ($MailboxConsumerStack.Count -eq 0) {
        $ReportQueue.CompleteAdding()
        $LogMessageQueue.Add("${ThreadID}: Final Consumer")
    }
    $LogMessageQueue.Add("${ThreadID}: ThreadEnd")
}

# ScriptBlock for the ReportConsumer Thread
# This thread is responsible for generating the report
$ReportConsumer = {
    Param(
        [System.Collections.Concurrent.BlockingCollection[PSObject]]
        $ReportQueue,

        [string]
        $ReportPath,

        [Object[]]
        $Properties,

        [System.Collections.Concurrent.BlockingCollection[String]]
        $LogMessageQueue,

        [int]$ReportBatchSize
    )
    $ThreadID = [appdomain]::GetCurrentThreadId()
    $LogMessageQueue.Add("${ThreadID}: ReportConsumer ThreadStart")
    Remove-item $ReportPath -Force -Confirm:$false
    $TotalEntries = 0
    while (-not $ReportQueue.IsAddingCompleted) {
        if ($ReportQueue.Count -ge $ReportBatchSize) {
            $LogMessageQueue.Add("${ThreadID}: ReportQueue $($ReportQueue.Count) Writing $ReportBatchSize entries to report")
            1..$ReportBatchSize | ForEach-Object {
                    $ReportQueue.Take()
                } | 
                Select-Object -Property $Properties | 
                Export-Csv -Path $ReportPath -NoTypeInformation -Append
                $TotalEntries += $ReportBatchSize
        }
        else {
            Start-sleep -Milliseconds 500
        }
    }
    $TotalEntries += $ReportQueue.Count
    While ($ReportQueue.Count -gt 0) {
        $BatchSize = [Math]::Min($ReportQueue.Count,  $ReportBatchSize)
        $LogMessageQueue.Add("${ThreadID}: ReportQueue $($ReportQueue.Count) Writing $BatchSize entries to report")
        if (-le 0) {break}
        1..$ReportBatchSize | ForEach-Object {
                $ReportQueue.Take()
            } | 
            Select-Object -Property $Properties | 
            Export-Csv -Path $ReportPath -NoTypeInformation -Append
    }
    $LogMessageQueue.Add("${ThreadID}: FinalizeReport $($ReportQueue.Count)")
    $ReportQueue | 
        Select-Object -Property $Properties | 
        Export-Csv -Path $ReportPath -NoTypeInformation -Append
    $LogMessageQueue.Add("${ThreadID}: ReportEnd TotalEntries $TotalEntries")
    $LogMessageQueue.Add("${ThreadID}: ThreadEnd")
    $LogMessageQueue.CompleteAdding()
}

# ScriptBlock for the LogMessageConsumer Thread
# This thread is responsible for writing all log messages
# to the log file.
$LogMessageConsumer = {
    Param (
        [System.Collections.Concurrent.BlockingCollection[String]]
        $LogMessageQueue,

        [string]
        $LogPath
    )
    $ThreadID = [appdomain]::GetCurrentThreadId()
    $LogEntries = 0
    $LogMessageQueue.Add("${ThreadID}: LogMessageConsumer ThreadStart")
    foreach ($Message in $LogMessageQueue.GetConsumingEnumerable()) {
        $LogEntries++
        $Output = '{0}: {1}' -f ([datetime]::UtcNow.ToString('o')), $Message
        $Output | Add-Content -Path $LogPath
    }
    $Output = '{0}: {1}: Log Entries: {2}' -f ([datetime]::UtcNow.ToString('o')), $ThreadID, $LogEntries
    $Output | Add-Content -Path $LogPath
    $Output = '{0}: {1}: ThreadEnd' -f ([datetime]::UtcNow.ToString('o')), $ThreadID
    $Output | Add-Content -Path $LogPath
}

# Used to house all the running threads
$Runners = [System.Collections.Generic.List[PSObject]]::new()

# Create and open the PowerShell RunSpace
$RunspacePool = [runspacefactory]::CreateRunspacePool(1,($CredentialQueue.Count + 4))
$RunspacePool.Open()

# Determine the number of MailboxConsumer Threads based
# on the number of queued credentials.
$MailboxConsumerThreads = $CredentialQueue.Count - 1
if ($MailboxConsumerThreads -lt 1) {
    $MailboxConsumerThreads = 1
}

# Start the MailboxProducer Thread
$MailboxProducerPS = [PowerShell]::Create()
$MailboxProducerPS.RunspacePool = $RunspacePool
$null = $MailboxProducerPS.AddScript($MailboxProducer)
$null = $MailboxProducerPS.AddParameters($MailboxProducerParams)
$MailboxProducerHandler = $MailboxProducerPS.BeginInvoke()
$Runners.Add([PSCustomObject]@{
    PowerShell = $MailboxProducerPS
    Handler = $MailboxProducerHandler
    Name = 'MailboxProducer'
})

# Start the MailboxConsumer Threads
1..$MailboxConsumerThreads | ForEach-Object {
    $MailboxConsumerPS = [PowerShell]::Create()
    $MailboxConsumerPS.RunspacePool = $RunspacePool
    $null = $MailboxConsumerPS.AddScript($MailboxConsumer)
    $null = $MailboxConsumerPS.AddParameters($MailboxConsumerParams)
    $MailboxConsumerHandler = $MailboxConsumerPS.BeginInvoke()
    $Runners.Add([PSCustomObject]@{
        PowerShell = $MailboxConsumerPS
        Handler = $MailboxConsumerHandler
        Name = 'MailboxConsumer-{0}' -f $_
    })
}

# Start the ReportConsumer Thread
$ReportConsumerPS = [PowerShell]::Create()
$ReportConsumerPS.RunspacePool = $RunspacePool
$null = $ReportConsumerPS.AddScript($ReportConsumer)
$null = $ReportConsumerPS.AddParameters($ReportConsumerParams)
$ReportConsumerHandler = $ReportConsumerPS.BeginInvoke()
$Runners.Add([PSCustomObject]@{
    PowerShell = $ReportConsumerPS
    Handler = $ReportConsumerHandler
    Name = 'ReportConsumer'
})

# Start the LogMessageConsumer Thread
$LogMessageConsumerPS = [PowerShell]::Create()
$LogMessageConsumerPS.RunspacePool = $RunspacePool
$null = $LogMessageConsumerPS.AddScript($LogMessageConsumer)
$null = $LogMessageConsumerPS.AddParameters($LogMessageConsumerParams)
$LogMessageConsumerHandler = $LogMessageConsumerPS.BeginInvoke()
$Runners.Add([PSCustomObject]@{
    PowerShell = $LogMessageConsumerPS
    Handler = $LogMessageConsumerHandler
    Name = 'LogMessageConsumer'
})

# Display the status of the threads while they are running
while ($Runners.Handler.IsCompleted -contains $false) {
    Clear-Host
    $Status = foreach ($Runner in $Runners) {
        [PSCustomObject]@{
            Name = $Runner.Name
            IsCompleted = $Runner.Handler.IsCompleted
        } 
    }
    $Status | Format-Table -AutoSize
    Start-Sleep -Seconds 5
}

# Cleanup the threads
Foreach($Runner in $Runners) {
    $Runner.Name
    $Runner.PowerShell.EndInvoke($Runner.Handler)
    $Runner.PowerShell.Dispose()
}

# Complete the ErrorQueue and log the errors
$ErrorQueue.CompleteAdding()
if ($ErrorQueue.Count -gt 0) {
    $ErrorQueue | Export-Clixml -Path $FailedPath
}

# Cleanup the runspace
$RunspacePool.Dispose()
