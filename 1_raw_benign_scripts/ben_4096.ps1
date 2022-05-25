<#-----------------------------------------------------------------------------
  Testing PowerShell with Pester

  Author: Robert C. Cain | @ArcaneCode | arcane@arcanetc.com
          http://arcanecode.com
 
  This module is Copyright (c) 2016 Robert C. Cain. All rights reserved.
  The code herein is for demonstration purposes. No warranty or guarentee
  is implied or expressly granted. 
  This module may not be reproduced in whole or in part without the express
  written consent of the author. 
-----------------------------------------------------------------------------#>

<#
   Note in addition to the Podcast-NoAgenda and Podcast-Database folders, 
   you'll want to create a Podcast-Data folder where the module will download
   the images and audio files to. 

   Also, you'll have to do the minimal amount of modifications to the code
   if you just create the same folder structure used in the demo, namely:
   C:\PS\Pester-course\demo\completed-final-module\Podcast-NoAgenda
   C:\PS\Pester-course\demo\completed-final-module\Podcast-Database
   C:\PS\Pester-course\demo\completed-final-module\Podcast-Data
#>

$host.ui.RawUI.WindowTitle = 'Pester Course Completed Demo'


# Pester
Import-Module Pester

$testsFolder = 'C:\PS\Pester-course\demo\completed-final-module\Podcast-NoAgenda'
Set-Location  $testsFolder 

# Run tests for each file
Invoke-Pester "$testsFolder\Podcast-NoAgenda.Module.Tests.ps1" 

Invoke-Pester "$testsFolder\function-Get-PodcastData.tests.ps1" 
Invoke-Pester "$testsFolder\function-Get-PodcastData.tests.ps1" -Tag 'Unit'
Invoke-Pester "$testsFolder\function-Get-PodcastData.tests.ps1" -Tag 'Acceptance'

Invoke-Pester "$testsFolder\function-Get-PodcastImage.tests.ps1"
Invoke-Pester "$testsFolder\function-Get-PodcastImage.tests.ps1" -Tag 'Unit'
Invoke-Pester "$testsFolder\function-Get-PodcastImage.tests.ps1" -Tag 'Acceptance'


Invoke-Pester "$testsFolder\function-Get-PodcastMedia.tests.ps1" 
Invoke-Pester "$testsFolder\function-Get-PodcastMedia.tests.ps1" -Tag 'Unit'
Invoke-Pester "$testsFolder\function-Get-PodcastMedia.tests.ps1" -Tag 'Acceptance'


Invoke-Pester "$testsFolder\function-ConvertTo-PodcastHtml.tests.ps1"
Invoke-Pester "$testsFolder\function-ConvertTo-PodcastHtml.tests.ps1" -Tag 'Unit'
Invoke-Pester "$testsFolder\function-ConvertTo-PodcastHtml.tests.ps1" -Tag 'Acceptance'

Invoke-Pester "$testsFolder\function-ConvertTo-PodcastXML.tests.ps1"
Invoke-Pester "$testsFolder\function-ConvertTo-PodcastXML.tests.ps1" -Tag 'Unit'
Invoke-Pester "$testsFolder\function-ConvertTo-PodcastXML.tests.ps1" -Tag 'Acceptance'

Invoke-Pester "$testsFolder\function-Write-PodcastHTML.tests.ps1" 
Invoke-Pester "$testsFolder\function-Write-PodcastHTML.tests.ps1" -Tag 'Unit'
Invoke-Pester "$testsFolder\function-Write-PodcastHTML.tests.ps1" -Tag 'Acceptance'

Invoke-Pester "$testsFolder\function-Write-PodcastXML.tests.ps1" 

Invoke-Pester "$testsFolder\function-Write-PodcastXML.tests.ps1" -Tag 'Unit'
Invoke-Pester "$testsFolder\function-Write-PodcastXML.tests.ps1" -Tag 'Acceptance'
Invoke-Pester "$testsFolder\function-Write-PodcastXML.tests.ps1" 

Invoke-Pester "$testsFolder\function-Get-NoAgenda.tests.ps1" 
Invoke-Pester "$testsFolder\function-Get-NoAgenda.tests.ps1" -Tag 'Unit'
Invoke-Pester "$testsFolder\function-Get-NoAgenda.tests.ps1" -Tag 'Acceptance'


# Run all the tests
Invoke-Pester 
Invoke-Pester -Tag 'Unit'           # Call just Unit Tests
Invoke-Pester -Tag 'Acceptance'     # Call just Acceptance Tests
Invoke-Pester -TestName 'Write-PodcastXML Unit Tests'  # Call a specific test






#region Advanced Invoke-Pester options ----------------------------------------
# Create test output compatible with NUnit
Invoke-Pester "$dbPath\function-New-PodcastTable.Tests.ps1" `
              -OutputFile "$dbPath\nunit.xml" `
              -OutputFormat NUnitXml

psedit "$dbPath\nunit.xml"

# Code Coverage
Invoke-Pester "$dbPath\function-New-PodcastTable.Tests.ps1" `
              -CodeCoverage "$dbPath\function-New-PodcastTable.ps1"


# PassThru
$testResults = Invoke-Pester "$dbPath\function-New-PodcastTable.Tests.ps1" 
$testResults

$testResults = Invoke-Pester "$dbPath\function-New-PodcastTable.Tests.ps1" -PassThru
$testResults 

# Strict

# Without strict, any skipped or pending tests are just listed, but don't fail
Invoke-Pester "$dbPath\function-New-PodcastTable.Tests.ps1"

# With Strict, skipped or pending tests generate a failure
Invoke-Pester "$dbPath\function-New-PodcastTable.Tests.ps1" -Strict


# EnableExit
# Note, don't run this in the ISE or it will close it!
# This is used to cause PowerShell to exit with a return code
Invoke-Pester "$dbPath\function-New-PodcastTable.Tests.ps1" -EnableExit

# Instead, open up a new PowerShell command window and enter (or copy/paste)
# the line below.
$x = powershell.exe 'Invoke-Pester C:\PS\Pester-course\demo\completed-final-module\Podcast-Database\function-New-PodcastTable.Tests.ps1 -EnableExit'

# then print out the value of $x
$x

#endregion Advanced Invoke-Pester options 


