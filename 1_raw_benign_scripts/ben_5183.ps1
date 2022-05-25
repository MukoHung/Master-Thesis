# workflow_activity_counter.ps1
# Usage: workflow_activity_counter.ps1 <workflow_file.xml>
# 
# Derek Pascarella <derekp@ayehu.com>
# Ayehu, Inc.
#
# PowerShell implementation of the Perl script "workflow_activity_counter.pl".
# At the PowerShell prompt, this script is executed as follows:
# > C:\folder\workflow_activity_counter.ps1 C:\folder\Workflow.xml
#
# For Windows users, note that a shortcut can be created with the path
# "powershell -file C:\folder\workflow_activity_counter.ps1", after which
# Workflow XML files can be dragged from the file explorer directly onto the
# shortcut.  This would launch a command prompt window and display the
# activity count results.
#
# Windows users may also create a shortcut in their local "SendTo" folder (foud
# at "C:\Users\<user>\AppData\Roaming\Microsoft\Windows\SendTo") which contains
# a target path of "powershell -file C:\folder\workflow_activity_counter.ps1".
# Once created, one can right-click on a Workflow XML file, navigate to the
# "Send To" menu and select the newly created shortcut.  This would launch a
# command prompt window and display the activity count results.
#
# If utilizing either of these shortcut methods, simply uncomment the last line
# of this script.
#
# Sample output:
#    Workflow file: C:\Workflows\SSH - Linux - Service Status.xml
# Total activities: 4
#
# Alternatively, the following single command will print an integer
# representing the total number of activities found in the specified Workflow
# XML file:
# > (Get-Content "C:\folder\Workflow.xml" | Select-String -Pattern 'x:Name=&quot;' -AllMatches).matches.count
#
# Sample output:
# 4

# Store filename passed to script.
$workflow_file = $args[0]

# Store pattern matches to find activities.
$pattern = "x:Name=&quot;"

# Calculate total occurrences of "pattern" in the specified Workflow XML file.
$count = (Get-Content "$workflow_file" | Select-String -Pattern $pattern -AllMatches).matches.count
$count --

# Display results.
Write-Host "   Workflow file: $workflow_file"
Write-Host "Total activities: $count" -nonewline

# Uncomment the next line if using the shortcut method on Windows to ensure
# command prompt doesn't disappear after this script has finished executing.
#$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
