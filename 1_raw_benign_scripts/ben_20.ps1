#
clear-host

$path = "C:\Git\GitHub\Gunnerdata\Template-PowerShellModule"

#Clean and Setup
cd $path 
& "$path\Command\CleanAndCreateSetup.ps1"
& "$path\Command\SetupRepository.ps1"

#Build, Test, Release, Doc, Status
& "$path\Command\TestAndBuild.ps1"
& "$path\Command\Release.ps1" -Versionpart patch
& "$path\Command\Release.ps1" -Versionpart minor
& "$path\Command\Release.ps1" -Versionpart major
& "$path\Command\Status.ps1"

#Cert and Sign Module
& "$path\Command\CreateCertForTest.ps1"
& "$path\Command\Sign-Release.ps1"

#Clean before push template to GitHub
& "$path\Command\CleanBeforePushTemplate.ps1"

#TO BE REMOVED

#TMP - Should be removed
& "$path\Command\UpdateDocStartPage.ps1"
& "$path\Command\CreateManifestFile.ps1" -Version "Release"
& "$path\Command\CreateManifestFile.ps1" -Version "Sign"
