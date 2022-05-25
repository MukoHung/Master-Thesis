# statup umbraco, and add some packages if you want
#
# e.g numbraco MyTestSite uSync Jumoo.TranslationManager vendr -NoStarter
#
# extras!!!
#
#   open vscode in the folder as part of the build 
#     numbraco MyTestSite -code 
#
#   don't run the site 
#     numbraco MyTestSite -doNotRun 
#
# Required dbatools powershell scripts and local SQLExpress install.


param(
    [Parameter(Mandatory)]
    [string]
    $sitename,

    [string[]]
    $packages,

    # dont install the starter kit. 
    [switch]
    $NoStarter,

    # open vscode in the folder
    [switch]
    $code, 

    # don't run the site at the end.
    [switch]
    $doNotRun 
)

# check if you don't have DBATools it will still work 
Function Test-CommandExists
{
 Param ($command)
 $oldPreference = $ErrorActionPreference
 $ErrorActionPreference = ‘stop’
 try {if(Get-Command $command){RETURN $true}}
 Catch {Write-Host “$command does not exist”; RETURN $false}
 Finally {$ErrorActionPreference=$oldPreference}
} #end function test-CommandExists

# optional if you don't have dbatools, remove this, Umbraco will create the DB for you (will take 10-15 seconds longer)
if (Test-CommandExists new-dbaDatabase) {
    Write-Host "Creating Database" -ForegroundColor Blue
    new-dbaDatabase -SqlInstance $env:COMPUTERNAME\sqlExpress -name $sitename
}
else {
    Write-Host "DBA Tools not installed, going for auto creation" -ForegroundColor Yellow
}

dotnet new umbraco -n $sitename --connection-string "Server=$env:COMPUTERNAME\SQLExpress;Database=$sitename;Integrated Security=true"
Set-Location $sitename

# you can put username and password here, but if you set UMB_USER, UMB_EMAIL and UMB_PASSWORD on your local pc, then you don't have to.

Set-Item Env:\UMBRACO__CMS__GLOBAL__INSTALLMISSINGDATABASE true
Set-Item Env:\UMBRACO__CMS__UNATTENDED__INSTALLUNATTENDED true
Set-Item Env:\UMBRACO__CMS__UNATTENDED__UNATTENDEDUSERNAME $env:UMB_USER
Set-Item Env:\UMBRACO__CMS__UNATTENDED__UNATTENDEDUSEREMAIL $env:UMB_EMAIL
Set-Item Env:\UMBRACO__CMS__UNATTENDED__UNATTENDEDUSERPASSWORD $env:UMB_PASSWORD

if (!$nostarter) {
    Write-Host "Adding the starter kit" -ForegroundColor Blue
    dotnet add package Umbraco.TheStarterKit -s https://api.nuget.org/v3/index.json
}

foreach($package in $packages) {
    Write-Host "Adding $package" -ForegroundColor Blue
    dotnet add package $package 
}

if ($code) {
    code $sitename
}

if ($doNotRun) {
    dotnet build 
}
else {
    Write-Host "Running Site" -ForegroundColor Blue
    Set-Location ..
    $project = ".\$sitename\$sitename.csproj";
    dotnet run --project $project
}