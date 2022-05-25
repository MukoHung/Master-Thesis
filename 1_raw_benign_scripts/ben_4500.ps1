#############################################################################
# Procedure:	Watch-MoveRequests.PS1		                          
# Author:	Scott Vintinner                                   
# Last Edit:    4/30/2011
# Purpose:      This script will monitor the mailbox move process. Moves should
# 		be added to the queue using the following command:
#
#		new-MoveRequest -Identity $identity -BadItemLimit 5 -Suspend:$true
#
#		Alternately you could use my Start-SuspendedMoveRequests.PS1 script
#
#		This script will display continuously updating output showing the 
#		progress of Exchange 2010 mailbox moves.  If bad items are encountered
#		it will save a copy of the log to the same folder as the script.
#		When the mailbox move has finished, the script will email the user
#		and clear the Move Task from Exchange.
#
#
# PS Notes      Computers must have Powershell scripts enabled by an admin:
#				set-executionpolicy remotesigned
#
# This work is licensed under a Creative Commons Attribution 3.0 Unported License.
# http://creativecommons.org/licenses/by/3.0/
# © 2011 Scott Vintinner 
#############################################################################


#Constants
$smtpserver = '10.1.1.40';
$emailFrom = "youremailaddress@example.com";
$runContinuously = $true;


#---------------------------------------------------------------------------------------------------
# Get the path to the current script so we can put our log files there.
#---------------------------------------------------------------------------------------------------
function Get-ScriptPath {     
    Split-Path $myInvocation.ScriptName 
}
$scriptPath = Get-ScriptPath;


#---------------------------------------------------------------------------------------------------
# This function will watch the mailboxes being moved and display progress.  When a mailbox
# has been moved, it will email a notification to the user and clear the move from Exchange.
# If there were corrupt items in the mailbox, a log file will be created in the same directory
# with the script.
#---------------------------------------------------------------------------------------------------
function Process-Mailboxes {
 	While ($moveRequests = Get-MoveRequest) {
		foreach($moveRequest in $moveRequests) {
			$mailboxIdentity = $moveRequest.Identity;
			$targetDatabase = $moveRequest.TargetDatabase;
			$mailboxAlias = $moveRequest.Alias;
			$displayName = $moveRequest.DisplayName;
			$status = $moveRequest.Status
			
			$results = Get-MoveRequestStatistics -Identity $mailboxIdentity  | select DisplayName, PercentComplete, BadItemsEncountered, TotalMailboxSize, TotalMailboxItemCount, TotalInProgressDuration,TotalSuspendedDuration,TotalQueuedDuration;
			$percentComplete = $results.PercentComplete;
			$badItemsEncountered = $results.BadItemsEncountered;
			$totalMailboxSize = $results.TotalMailboxSize;
			$duration = $results.TotalInProgressDuration;
			$itemCount = $results.TotalMailboxItemCount;
			$timeSuspended = $results.TotalSuspendedDuration;
			$timeQueued = $results.TotalQueuedDuration;
			
			if (($status -eq "InProgress") -or ($status -eq "CompletionInProgress") -or ($status -eq "Completed")) {
				Write-Host "$mailboxAlias	$percentComplete%	duration: $duration	Target: $targetDatabase	BadItems: $badItemsEncountered";			
			} elseif ($status -eq "Suspended")  {
				Write-Host "$mailboxAlias - Suspended for $timeSuspended";
			} elseif ($status -eq "Queued") {
				Write-Host "$mailboxAlias - Queued for $timeQueued";			
			} else {
				Write-Warning "$mailboxAlias - $status";
			}

			# Once the mailbox has finished moving
			if ($status -eq "Completed") {						
				Write-Host "Finished moving $displayName";
				if ($badItemsEncountered -ne 0) { 	# If we encountered errors, create a log report.
					Write-Warning "Found $badItemsEncountered BadItems on $identity! Creating log file to debug.";
					$logFile = $scriptPath + "\$mailboxAlias-errorlog.txt";
					Get-MoveRequestStatistics -Identity $mailboxIdentity -IncludeReport | fl | out-File $logfile;
					Write-Warning "Clearing job with bad items."
					Remove-MoveRequest -Identity $mailboxIdentity -Confirm:$false;
				} else {
					Write-Host "Clearing successful job."				
					Remove-MoveRequest -Identity $mailboxIdentity -Confirm:$false;
				}
				
				Write-Host "Sending email notification to $displayName that their mailbox is now online."
				$emailAddress = (Get-Mailbox -Identity $mailboxidentity | select PrimarySmtpAddress).PrimarySmtpAddress
				
				$subject = "Mailbox move finished";
				$body = "
We have finished moving your mailbox to the new system.

Time in queue     :	$timeQueued
Time to move data :	$duration
Your Mailbox Size :	$totalMailboxSize
Total Items Moved :	$itemCount
Corrupt Items     :	$badItemsEncountered

Although unexpected, if you do experience any problems, please submit a ticket to the Helpdesk via email (helpdesk@example.com) or via the Helpdesk Web Site (http://helpdesk.example.com).   For emergencies this weekend, please call the on-call staff member at 704-555-1212.

Occasionally the move process will encounter items that Outlook has corrupted.  This can occur, for example, as a result of an Outlook crash.  If the report above indicates that corrupt items were found, we have already been notified.  We will investigate and restore the items if possible.

Thanks!					
";
				$smtp = new-object Net.Mail.SmtpClient($smtpServer);
				$smtp.Send($emailFrom, $emailAddress, $subject, $body);											
			}
		}
		Write-Host "------Waiting for 60 seconds------"
		Start-Sleep 60;
	}

}


#---------------------------------------------------------------------------------------------------
# Call the main function
#---------------------------------------------------------------------------------------------------
Do {
	Process-Mailboxes;
	Write-Host "------No Suspended Mailboxes, waiting 60 seconds------"
	Start-Sleep 60;
} Until ($runContinuously -eq $false)

